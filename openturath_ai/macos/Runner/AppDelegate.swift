import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationDidFinishLaunching(_ notification: Notification) {
    // Retire only the three credential keys written by the old AuthUserDefaults
    // patch. Do not read their values, touch Keychain, or clear research notes.
    // The new launcher never authenticates Firebase natively.
    let appID = "1:255541559800:ios:c789f7f14e7fb46cd2960d"
    let apiKey = "AIzaSyB-ABXjjHM5GNNoScOLziz4G20nDFx6jSk"
    let domain = "com.google.Firebase.Auth.firebase_auth_\(appID)" as CFString
    let keys = [
      "firebase_auth_stored_user_coder_key_\(apiKey)",
      "__FIRAPP_DEFAULT_firebase_user",
      "firebase_auth_1___FIRAPP_DEFAULT_firebase_user",
    ]
    for key in keys {
      CFPreferencesSetAppValue(key as CFString, nil, domain)
    }
    CFPreferencesAppSynchronize(domain)
    super.applicationDidFinishLaunching(notification)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
