import Cocoa
import FlutterMacOS
import Sparkle

@main
class AppDelegate: FlutterAppDelegate {
  private var updaterController: SPUStandardUpdaterController!

  override func applicationDidFinishLaunching(_ notification: Notification) {
    let controller : FlutterViewController = mainFlutterWindow!.contentViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "worklog_studio/updater",
                                      binaryMessenger: controller.engine.binaryMessenger)
    channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      switch call.method {
      case "checkForUpdates":
        self.updaterController?.checkForUpdates(nil)
        result(nil)
      case "checkSilently":
        self.updaterController?.updater.checkForUpdatesInBackground()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    })

    super.applicationDidFinishLaunching(notification)
  }
  override func awakeFromNib() {
      if updaterController == nil {
          updaterController = SPUStandardUpdaterController(
              startingUpdater: true,
              updaterDelegate: nil,
              userDriverDelegate: nil
          )
      }
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}