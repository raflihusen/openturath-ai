"""Real DMG/launch/rollback tests, confined to disposable application bundles."""
import hashlib
import os
import pathlib
import plistlib
import subprocess
import tempfile
import time
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
HELPER = ROOT / 'assets/updater/macos_update.sh'

@unittest.skipUnless(os.uname().sysname == 'Darwin', 'macOS integration test')
class MacUpdateTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp = tempfile.TemporaryDirectory(prefix='ot native update tests ')
        cls.base = pathlib.Path(cls.temp.name).resolve()
        source = cls.base / 'fixture.c'
        source.write_text(r'''
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <dirent.h>
#include <libgen.h>
#include <limits.h>
int main(int argc, char **argv) {
  char executable[PATH_MAX], app[PATH_MAX], parent[PATH_MAX], file[PATH_MAX];
  if (!realpath(argv[0], executable)) return 3;
  strcpy(app, executable); for(int i=0;i<3;i++){char *slash=strrchr(app,'/');if(!slash)return 4;*slash=0;}
  strcpy(parent, app); char *slash=strrchr(parent,'/');if(!slash)return 4;*slash=0;
  snprintf(file,sizeof(file),"%s/Contents/Resources/behavior",app);
  FILE *f=fopen(file,"r"); char behavior[32]={0}; if(f){fgets(behavior,32,f);fclose(f);}
  if (!strcmp(behavior,"crash")) return 23;
  if (!strcmp(behavior,"old")) {snprintf(file,sizeof(file),"%s/old-started",parent);f=fopen(file,"w");if(f)fclose(f);return 0;}
  DIR *dir=opendir(parent); struct dirent *entry;
  while(dir && (entry=readdir(dir))) {
    if(strncmp(entry->d_name,".ot-update.",11)) continue;
    snprintf(file,sizeof(file),"%s/%s/target",parent,entry->d_name);
    f=fopen(file,"r");char expected[PATH_MAX]={0};if(f){fgets(expected,sizeof(expected),f);fclose(f);}
    if(strcmp(expected,app)) continue;
    snprintf(file,sizeof(file),"%s/%s/confirmed",parent,entry->d_name);
    f=fopen(file,"w");if(f){fputs("2",f);fclose(f);}
  }
  if(dir)closedir(dir);return 0;
}
''')
        cls.binary = cls.base / 'fixture'
        subprocess.run(['clang', str(source), '-o', str(cls.binary)], check=True, capture_output=True)

    @classmethod
    def tearDownClass(cls):
        cls.temp.cleanup()

    def setUp(self):
        self.case = pathlib.Path(tempfile.mkdtemp(dir=self.base, prefix='case '))
        self.target = self.app(self.case / "Installed App's Name.app", 1, 'old')
        self.user_data = self.case / 'user session data'
        self.user_data.write_text('preserve me')

    def app(self, path, build, behavior, identity='com.openturath.ota.fixture'):
        (path / 'Contents/MacOS').mkdir(parents=True)
        (path / 'Contents/Resources').mkdir()
        import shutil
        shutil.copy2(self.binary, path / 'Contents/MacOS/Fixture')
        (path / 'Contents/Resources/behavior').write_text(behavior)
        (path / 'Contents/Info.plist').write_bytes(plistlib.dumps({
            'CFBundleIdentifier': identity, 'CFBundleExecutable': 'Fixture',
            'CFBundleVersion': str(build), 'CFBundleShortVersionString': f'1.{build}',
            'CFBundlePackageType': 'APPL'}))
        subprocess.run(['codesign', '--force', '--sign', '-', str(path)], check=True, capture_output=True)
        return path

    def package(self, behavior='confirm', identity='com.openturath.ota.fixture'):
        payload = self.case / 'payload'; payload.mkdir()
        self.app(payload / 'New.app', 2, behavior, identity)
        dmg = self.case / 'candidate.dmg'
        subprocess.run(['hdiutil', 'create', '-quiet', '-srcfolder', str(payload),
            '-format', 'UDZO', str(dmg)], check=True, capture_output=True)
        return dmg, hashlib.sha256(dmg.read_bytes()).hexdigest()

    def prepare(self, dmg, digest, adhoc=True):
        return subprocess.run(['/bin/sh', str(HELPER), 'prepare', str(dmg),
            str(self.target), '2', digest, '1' if adhoc else '0'], capture_output=True, text=True)

    def build(self):
        return plistlib.loads((self.target / 'Contents/Info.plist').read_bytes())['CFBundleVersion']

    def test_bad_hash_keeps_original(self):
        dmg, _ = self.package()
        self.assertNotEqual(self.prepare(dmg, 'a'*64).returncode, 0)
        self.assertEqual(self.build(), '1')

    def test_wrong_identity_keeps_original(self):
        dmg, digest = self.package(identity='com.example.other')
        self.assertNotEqual(self.prepare(dmg, digest).returncode, 0)
        self.assertEqual(self.build(), '1')

    def test_distribution_refuses_adhoc(self):
        dmg, digest = self.package()
        self.assertNotEqual(self.prepare(dmg, digest, adhoc=False).returncode, 0)
        self.assertEqual(self.build(), '1')

    def run_install(self, behavior):
        dmg, digest = self.package(behavior)
        prepared = self.prepare(dmg, digest)
        self.assertEqual(prepared.returncode, 0, prepared.stderr)
        stage = pathlib.Path(prepared.stdout.strip())
        old = subprocess.Popen(['sleep', '30'])
        helper = subprocess.Popen(['/bin/sh', str(HELPER), 'install', str(stage),
            str(self.target), str(old.pid), '2'], stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            text=True, env={**os.environ, 'OT_UPDATER_HEALTH_TIMEOUT': '5'})
        try:
            deadline = time.time()+10
            while not (stage/'ready').exists() and time.time()<deadline: time.sleep(.05)
            self.assertTrue((stage/'ready').exists())
            self.assertEqual(self.build(), '1', 'Must wait for old application to exit')
            old.terminate(); old.wait()
            stdout, stderr = helper.communicate(timeout=25)
            return helper.returncode, stage, stderr
        finally:
            if old.poll() is None: old.terminate(); old.wait()
            if helper.poll() is None: helper.kill(); helper.wait()

    def test_cancelled_handoff_keeps_original_running(self):
        dmg, digest = self.package()
        prepared = self.prepare(dmg, digest)
        self.assertEqual(prepared.returncode, 0, prepared.stderr)
        stage = pathlib.Path(prepared.stdout.strip())
        old = subprocess.Popen(['sleep', '30'])
        helper = subprocess.Popen(['/bin/sh', str(HELPER), 'install', str(stage),
            str(self.target), str(old.pid), '2'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        try:
            deadline = time.time()+10
            while not (stage/'ready').exists() and time.time()<deadline: time.sleep(.05)
            self.assertTrue((stage/'ready').exists())
            (stage/'cancelled').write_text('cancelled')
            helper.communicate(timeout=10)
            self.assertNotEqual(helper.returncode, 0)
            self.assertEqual(self.build(), '1')
            self.assertIsNone(old.poll())
            self.assertTrue((stage/'handoff_failed').exists())
        finally:
            old.terminate(); old.wait()
            if helper.poll() is None: helper.kill(); helper.wait()

    def test_changed_staged_bundle_fails_before_handoff(self):
        dmg, digest = self.package()
        prepared = self.prepare(dmg, digest)
        self.assertEqual(prepared.returncode, 0, prepared.stderr)
        stage = pathlib.Path(prepared.stdout.strip())
        (stage/'next.app/Contents/Resources/behavior').write_text('changed')
        result = subprocess.run(['/bin/sh', str(HELPER), 'install', str(stage),
            str(self.target), str(os.getpid()), '2'], capture_output=True, timeout=10)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((stage/'ready').exists())
        self.assertTrue((stage/'handoff_failed').exists())
        self.assertEqual(self.build(), '1')

    def test_real_install_and_relaunch(self):
        code, stage, error = self.run_install('confirm')
        self.assertEqual(code, 0, error)
        self.assertEqual(self.build(), '2')
        self.assertEqual((stage/'status').read_text().strip(), 'confirmed')
        self.assertTrue((stage/'previous.app').exists())
        self.assertEqual(self.user_data.read_text(), 'preserve me')

    def test_crashing_candidate_rolls_back(self):
        code, stage, error = self.run_install('crash')
        self.assertNotEqual(code, 0)
        self.assertEqual(self.build(), '1', error)
        self.assertEqual((stage/'status').read_text().strip(), 'rolled_back')
        self.assertEqual(self.user_data.read_text(), 'preserve me')

if __name__ == '__main__': unittest.main(verbosity=2)
