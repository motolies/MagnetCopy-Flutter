import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var methodChannel: FlutterMethodChannel?

  override func applicationDidFinishLaunching(_ notification: Notification) {
    if let window = mainFlutterWindow,
       let controller = window.contentViewController as? FlutterViewController {
      methodChannel = FlutterMethodChannel(
        name: "magnet_copy/url_handler",
        binaryMessenger: controller.engine.binaryMessenger
      )

      methodChannel?.setMethodCallHandler { [weak self] (call, result) in
        switch call.method {
        case "registerAsDefaultHandler":
          self?.registerAsDefaultMagnetHandler()
          result(true)
        case "isDefaultHandler":
          result(self?.isDefaultMagnetHandler() ?? false)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    // 앱 시작 시 자동으로 magnet 핸들러 등록
    registerAsDefaultMagnetHandler()
  }

  private func registerAsDefaultMagnetHandler() {
    if let bundleId = Bundle.main.bundleIdentifier {
      LSSetDefaultHandlerForURLScheme("magnet" as CFString, bundleId as CFString)

      if let appUrl = Bundle.main.bundleURL as CFURL? {
        LSRegisterURL(appUrl, true)
      }
    }
  }

  private func isDefaultMagnetHandler() -> Bool {
    guard let magnetUrl = URL(string: "magnet:?xt=test") else { return false }

    if let handlerUrl = NSWorkspace.shared.urlForApplication(toOpen: magnetUrl),
       let bundleUrl = Bundle.main.bundleURL as URL? {
      return handlerUrl.path == bundleUrl.path
    }
    return false
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
