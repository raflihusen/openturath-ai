import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private let fixedWidth: CGFloat = 920

  override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
    let targetScreen = screen ?? self.screen ?? NSScreen.main
    guard let visible = targetScreen?.visibleFrame else {
      return super.constrainFrameRect(frameRect, to: screen)
    }
    var constrained = frameRect
    constrained.size.width = fixedWidth
    constrained.size.height = visible.height
    constrained.origin.y = visible.origin.y
    if constrained.maxX > visible.maxX {
      constrained.origin.x = visible.maxX - fixedWidth
    }
    if constrained.minX < visible.minX {
      constrained.origin.x = visible.minX
    }
    return constrained
  }

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController
    let targetScreen = self.screen ?? NSScreen.main
    let visibleFrame = targetScreen?.visibleFrame
      ?? NSRect(x: 0, y: 0, width: 1280, height: 820)

    let fixedHeight: CGFloat = visibleFrame.height
    let windowX = (visibleFrame.maxX - fixedWidth) / 2.0
    let windowY = visibleFrame.origin.y
    let windowFrame = NSRect(x: max(visibleFrame.minX, windowX), y: windowY, width: fixedWidth, height: fixedHeight)

    self.isRestorable = false
    self.showsResizeIndicator = false
    self.styleMask.remove(.resizable)
    self.styleMask.remove(.fullScreen)
    self.collectionBehavior = [.managed, .fullScreenNone]
    self.minSize = NSSize(width: fixedWidth, height: fixedHeight)
    self.maxSize = NSSize(width: fixedWidth, height: fixedHeight)
    self.setFrame(windowFrame, display: true)
    self.standardWindowButton(.zoomButton)?.isEnabled = false
    self.standardWindowButton(.zoomButton)?.isHidden = true
    self.title = "OpenTurath AI"

    RegisterGeneratedPlugins(registry: flutterViewController)
    super.awakeFromNib()
  }
}
