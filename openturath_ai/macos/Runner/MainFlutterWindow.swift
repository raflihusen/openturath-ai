import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController
    let visibleFrame = (self.screen ?? NSScreen.main)?.visibleFrame
      ?? NSRect(x: 0, y: 0, width: 1280, height: 820)

    // Comfortable fixed desktop proportion without stretching UI shapes.
    let windowWidth = min(1040, visibleFrame.width - 40)
    let windowHeight = min(800, visibleFrame.height - 60)
    let windowSize = NSSize(width: windowWidth, height: windowHeight)
    let windowX = visibleFrame.minX + (visibleFrame.width - windowWidth) / 2.0
    let windowY = visibleFrame.minY + (visibleFrame.height - windowHeight) / 2.0
    let windowFrame = NSRect(x: windowX, y: windowY, width: windowWidth, height: windowHeight)

    self.setFrame(windowFrame, display: true)
    self.minSize = windowSize
    self.maxSize = windowSize
    self.styleMask.remove(.resizable)
    self.collectionBehavior.remove(.fullScreenPrimary)
    self.collectionBehavior.remove(.fullScreenAuxiliary)
    self.standardWindowButton(.zoomButton)?.isEnabled = false
    self.standardWindowButton(.zoomButton)?.isHidden = true
    self.title = "OpenTurath AI"
    self.center()

    RegisterGeneratedPlugins(registry: flutterViewController)
    super.awakeFromNib()
  }
}
