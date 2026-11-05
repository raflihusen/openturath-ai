import unittest
from check_android_google_signin import validate


def client(package, cert, web=True):
    oauth = [{'client_type': 1, 'android_info': {'package_name': package, 'certificate_hash': cert}}]
    if web:
        oauth.append({'client_type': 3, 'client_id': 'web-client'})
    return {'client_info': {'android_client_info': {'package_name': package}}, 'oauth_client': oauth}


class GoogleConfigurationTest(unittest.TestCase):
    def test_current_package_and_certificate_match(self):
        self.assertIsNone(validate({'client': [client('current.app', 'aabb')]}, 'current.app', 'AA:BB'))

    def test_certificate_on_legacy_package_is_not_enough(self):
        config = {'client': [client('legacy.app', 'debug'), client('current.app', 'release')]}
        self.assertIn('not configured', validate(config, 'current.app', 'debug'))

    def test_nested_android_package_must_also_match(self):
        entry = client('current.app', 'debug')
        entry['oauth_client'][0]['android_info']['package_name'] = 'legacy.app'
        self.assertIn('not configured', validate({'client': [entry]}, 'current.app', 'debug'))

    def test_web_oauth_client_required(self):
        self.assertIn('web OAuth', validate({'client': [client('current.app', 'debug', False)]}, 'current.app', 'debug'))

    def test_unknown_package_rejected(self):
        self.assertIn('No Firebase', validate({'client': [client('legacy.app', 'debug')]}, 'current.app', 'debug'))


if __name__ == '__main__':
    unittest.main()
