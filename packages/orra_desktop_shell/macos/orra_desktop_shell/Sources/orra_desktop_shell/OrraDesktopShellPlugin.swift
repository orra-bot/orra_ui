import Cocoa
import FlutterMacOS

/// orra_desktop_shell 的 macOS 原生部分：按标题栏中线定位红绿灯。
///
/// 系统默认把红绿灯放在约 28px 高的标题栏里；隐藏标题栏后自绘 44px 标题栏时，
/// 需要把红绿灯所在的标题栏容器撑到同样高度并垂直居中，否则红绿灯与窗口按钮组不在同一中线。
/// AppKit 会在缩放、全屏切换、焦点变化时重排标题栏，因此监听这些通知后重新定位。
public class OrraDesktopShellPlugin: NSObject, FlutterPlugin {
  private weak var registrar: FlutterPluginRegistrar?
  private var trafficLightX: CGFloat?
  private var titlebarHeight: CGFloat = 44
  private var observers: [NSObjectProtocol] = []
  private weak var observedWindow: NSWindow?

  init(registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
    super.init()
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "orra_desktop_shell", binaryMessenger: registrar.messenger)
    let instance = OrraDesktopShellPlugin(registrar: registrar)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setTrafficLightPosition":
      guard let args = call.arguments as? [String: Any],
        let x = args["x"] as? Double,
        let height = args["titlebarHeight"] as? Double
      else {
        result(FlutterError(code: "bad_args", message: "x 与 titlebarHeight 必填", details: nil))
        return
      }
      guard let window = registrar?.view?.window else {
        result(FlutterError(code: "no_window", message: "找不到 Flutter 窗口", details: nil))
        return
      }
      trafficLightX = CGFloat(x)
      titlebarHeight = CGFloat(height)
      observe(window)
      layoutTrafficLights(in: window)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func observe(_ window: NSWindow) {
    if observedWindow === window { return }
    observers.forEach { NotificationCenter.default.removeObserver($0) }
    observers.removeAll()
    observedWindow = window
    let names: [Notification.Name] = [
      NSWindow.didResizeNotification,
      NSWindow.didEndLiveResizeNotification,
      NSWindow.didExitFullScreenNotification,
      NSWindow.didBecomeKeyNotification,
      NSWindow.didResignKeyNotification,
      NSWindow.didChangeBackingPropertiesNotification,
    ]
    for name in names {
      let token = NotificationCenter.default.addObserver(
        forName: name, object: window, queue: .main
      ) { [weak self, weak window] _ in
        guard let self = self, let window = window else { return }
        self.layoutTrafficLights(in: window)
      }
      observers.append(token)
    }
  }

  private func layoutTrafficLights(in window: NSWindow) {
    guard let x = trafficLightX,
      !window.styleMask.contains(.fullScreen),
      let close = window.standardWindowButton(.closeButton),
      let miniaturize = window.standardWindowButton(.miniaturizeButton),
      let zoom = window.standardWindowButton(.zoomButton),
      let titlebarView = close.superview,
      let container = titlebarView.superview
    else { return }

    // 标题栏容器撑到自绘标题栏的高度，贴住窗口顶部。
    var frame = container.frame
    frame.size.height = titlebarHeight
    frame.origin.y = window.frame.height - titlebarHeight
    container.frame = frame
    titlebarView.frame = container.bounds

    // 三个按钮保持系统间距，在标题栏内垂直居中。
    let spacing = miniaturize.frame.minX - close.frame.minX
    let y = (titlebarHeight - close.frame.height) / 2
    for (index, button) in [close, miniaturize, zoom].enumerated() {
      button.setFrameOrigin(NSPoint(x: x + CGFloat(index) * spacing, y: y))
    }
  }

  deinit {
    observers.forEach { NotificationCenter.default.removeObserver($0) }
  }
}
