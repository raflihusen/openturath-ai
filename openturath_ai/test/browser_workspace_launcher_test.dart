import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/services/browser_workspace_launcher.dart';

void main() {
  test('all native launchers use a browser URL without credentials', () {
    final uri = BrowserWorkspaceLauncher.workspaceUri(agentId: 'fiqh_syafii');
    expect(uri.scheme, 'https');
    expect(uri.host, 'open-turath.firebaseapp.com');
    expect(uri.path, '/workspace/');
    expect(uri.queryParameters, {'agent': 'fiqh_syafii'});
    expect(uri.fragment, isEmpty);
  });
  for (final base in [
    'http://open-turath.firebaseapp.com/workspace/',
    'https://open-turath.firebaseapp.com.evil.test/workspace/',
    'https://user@open-turath.firebaseapp.com/workspace/',
    'https://open-turath.firebaseapp.com:8443/workspace/',
    'https://open-turath.firebaseapp.com/workspace/?idToken=token',
    'https://open-turath.firebaseapp.com/workspace/#auth=token',
  ]) {
    test('rejects unsafe workspace override $base', () {
      expect(() => BrowserWorkspaceLauncher.workspaceUri(base: base),
          throwsA(isA<WorkspaceLaunchException>()));
    });
  }
  test('rejects attempts to encode another destination into the agent ID', () {
    expect(
        () => BrowserWorkspaceLauncher.workspaceUri(
            agentId: '../?continue=https://evil.test'),
        throwsA(isA<WorkspaceLaunchException>()));
  });
}
