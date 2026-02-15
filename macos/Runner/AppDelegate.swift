import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var methodChannel: FlutterMethodChannel?

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)

    if let window = mainFlutterWindow,
       let controller = window.contentViewController as? FlutterViewController {
      methodChannel = FlutterMethodChannel(
        name: "magnet_copy/url_handler",
        binaryMessenger: controller.engine.binaryMessenger
      )

      methodChannel?.setMethodCallHandler { [weak self] (call, result) in
        switch call.method {
        case "registerAsDefaultHandler":
          self?.registerAsDefaultMagnetHandler(result: result)
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

  private func registerAsDefaultMagnetHandler(result: FlutterResult? = nil) {
    guard let bundleId = Bundle.main.bundleIdentifier else {
      NSLog("[MagnetCopy] Bundle identifier not found")
      result?(false)
      return
    }

    let appUrl = Bundle.main.bundleURL

    if #available(macOS 12.0, *) {
      NSWorkspace.shared.setDefaultApplication(
        at: appUrl,
        toOpenURLsWithScheme: "magnet"
      ) { error in
        if let error = error {
          NSLog("[MagnetCopy] Failed to register as magnet handler: \(error)")
          result?(false)
        } else {
          NSLog("[MagnetCopy] Successfully registered as magnet handler (bundleId: \(bundleId))")
          result?(true)
        }
      }
    } else {
      LSSetDefaultHandlerForURLScheme("magnet" as CFString, bundleId as CFString)
      if let cfUrl = appUrl as CFURL? {
        LSRegisterURL(cfUrl, true)
      }
      NSLog("[MagnetCopy] Registered via legacy API (bundleId: \(bundleId))")
      result?(true)
    }
  }

  private func isDefaultMagnetHandler() -> Bool {
    guard let magnetUrl = URL(string: "magnet:?xt=test") else { return false }

    if let handlerUrl = NSWorkspace.shared.urlForApplication(toOpen: magnetUrl) {
      let isDefault = handlerUrl.path == Bundle.main.bundleURL.path
      NSLog("[MagnetCopy] isDefaultHandler: \(isDefault), handler: \(handlerUrl.path)")
      return isDefault
    }
    NSLog("[MagnetCopy] No handler found for magnet: scheme")
    return false
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
