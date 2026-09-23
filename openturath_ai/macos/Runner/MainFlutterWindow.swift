import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController
    let available = (self.screen ?? NSScreen.main)?.visibleFrame.size
      ?? NSSize(width: 1280, height: 820)
    // Leave room for the menu bar, title bar and Dock on smaller displays.
    self.contentMinSize = NSSize(width: min(860, available.width - 32),
                                 height: min(600, available.height - 64))
    self.setContentSize(NSSize(width: min(1280, available.width - 32),
                               height: min(820, available.height - 64)))
    self.title = "OpenTurath AI"
    self.center()
    RegisterGeneratedPlugins(registry: flutterViewController)
    super.awakeFromNib()
  }
}
