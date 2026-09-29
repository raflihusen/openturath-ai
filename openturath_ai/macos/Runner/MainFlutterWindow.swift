import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController
    let visibleFrame = (self.screen ?? NSScreen.main)?.visibleFrame
      ?? NSRect(x: 0, y: 0, width: 1280, height: 820)

    let fixedWidth: CGFloat = 920
    let fixedHeight: CGFloat = min(920, visibleFrame.height - 40)
    let windowX = visibleFrame.maxX - fixedWidth - 20.0
    let windowY = visibleFrame.minY + (visibleFrame.height - fixedHeight) / 2.0
    let windowFrame = NSRect(x: max(visibleFrame.minX, windowX), y: windowY, width: fixedWidth, height: fixedHeight)

    self.isRestorable = false
    self.showsResizeIndicator = false
    self.styleMask.remove(.resizable)
    self.styleMask.remove(.fullScreen)
    self.collectionBehavior = [.defaultActivationPolicy]
    self.minSize = NSSize(width: fixedWidth, height: fixedHeight)
    self.maxSize = NSSize(width: fixedWidth, height: fixedHeight)
    self.setContentSize(NSSize(width: fixedWidth, height: fixedHeight))
    self.setFrame(windowFrame, display: true)
    self.standardWindowButton(.zoomButton)?.isEnabled = false
    self.standardWindowButton(.zoomButton)?.isHidden = true
    self.title = "OpenTurath AI"

    RegisterGeneratedPlugins(registry: flutterViewController)
    super.awakeFromNib()
  }
}
