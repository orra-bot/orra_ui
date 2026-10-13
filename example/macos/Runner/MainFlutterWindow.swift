import Cocoa
import FlutterMacOS
import window_manager

/// 首帧前的窗口底色 = orra_ui 主题的 chrome（窗口底）。
/// 必须与 RaColors.light().surfaceWindow / RaColors.dark().surfaceWindow 一致，
/// 否则启动和调整窗口大小时会闪色；由 example/test/native_window_test.dart 校验。
private let chromeLight: UInt32 = 0xEFEFF0
private let chromeDark: UInt32 = 0x09090A

private extension NSColor {
  convenience init(rgb: UInt32) {
    self.init(
      srgbRed: CGFloat((rgb >> 16) & 0xFF) / 255,
      green: CGFloat((rgb >> 8) & 0xFF) / 255,
      blue: CGFloat(rgb & 0xFF) / 255,
      alpha: 1)
  }
}

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    self.backgroundColor = NSColor(name: nil) { appearance in
      appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        ? NSColor(rgb: chromeDark) : NSColor(rgb: chromeLight)
    }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

  /// 首帧渲染前不显示窗口（RaDesktopWindow.ensureInitialized 准备好后再显示）。
  override public func order(_ place: NSWindow.OrderingMode, relativeTo otherWin: Int) {
    super.order(place, relativeTo: otherWin)
    hiddenWindowAtLaunch()
  }
}
