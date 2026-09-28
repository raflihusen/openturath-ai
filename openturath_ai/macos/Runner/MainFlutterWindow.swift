import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController
    let visibleFrame = (self.screen ?? NSScreen.main)?.visibleFrame
      ?? NSRect(x: 0, y: 0, width: 1280, height: 820)

    let minWidth: CGFloat = 920
    let minHeight: CGFloat = 640
    let windowWidth = min(1120, visibleFrame.width - 40)
    let windowHeight = min(820, visibleFrame.height - 60)
    let windowX = visibleFrame.minX + (visibleFrame.width - windowWidth) / 2.0
    let windowY = visibleFrame.minY + (visibleFrame.height - windowHeight) / 2.0
    let windowFrame = NSRect(x: windowX, y: windowY, width: windowWidth, height: windowHeight)

    self.setFrame(windowFrame, display: true)
    self.minSize = NSSize(width: minWidth, height: minHeight)
    self.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    self.styleMask.insert(.resizable)
    self.collectionBehavior.insert(.fullScreenPrimary)
    self.standardWindowButton(.zoomButton)?.isEnabled = true
    self.standardWindowButton(.zoomButton)?.isHidden = false
    self.title = "OpenTurath AI"
    self.center()

    RegisterGeneratedPlugins(registry: flutterViewController)
    super.awakeFromNib()
  }
}
