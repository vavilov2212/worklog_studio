import Cocoa
import FlutterMacOS
import Sparkle

@main
class AppDelegate: FlutterAppDelegate {
    private var updaterController: SPUStandardUpdaterController!
    private var popoverEngine: FlutterEngine?
    private var popoverPanel: PopoverPanel?
    private var statusItem: NSStatusItem!
    private var isPopoverExpanded: Bool = false

    private var popupLastCloseTime: Date = Date.distantPast
    
    override func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. Инициализируем Sparkle
        setupUpdater()
        
        // 2. Инициализируем отдельный движок для поповера (tray role)
        popoverEngine = FlutterEngine(name: "PopoverEngine", project: nil)
        
        if let engine = popoverEngine {
            RegisterGeneratedPlugins(registry: engine)
            
            // Настраиваем MethodChannel через IpcRouter ДО запуска движка
            IpcRouter.shared.register(messenger: engine.binaryMessenger, role: "tray") { [weak self] (call, result) in
                self?.handleNativeCommand(call: call, result: result)
            }
            
            // Запускаем движок стандартно
            engine.run(withEntrypoint: nil)
            NSLog("AppDelegate: popoverEngine (tray) started")
            
            // 3. Создаем контроллер и панель для поповера
            let flutterViewController = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
            flutterViewController.backgroundColor = .clear // Убираем черный фон у Flutter
            
            popoverPanel = PopoverPanel(
                contentRect: NSRect(x: 0, y: 0, width: 320, height: 400),
                flutterViewController: flutterViewController
            )
            
            // НАБЛЮДАТЕЛЬ ЗА ПОТЕРЕЙ ФОКУСА (закрывает поповер при клике вне него)
            NotificationCenter.default.addObserver(
                forName: NSWindow.didResignKeyNotification,
                object: popoverPanel,
                queue: .main
            ) { [weak self] _ in
                self?.hidePopover()
            }
            
            // Дублирующий наблюдатель: если потерял фокус весь App (переключились на другую программу)
            NotificationCenter.default.addObserver(
                forName: NSApplication.didResignActiveNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.hidePopover()
            }
        }
        
        // 4. Настраиваем Tray Icon (NSStatusItem)
        setupStatusItem()
        
        // 5. Вызываем super, чтобы Flutter показал главное окно (MainFlutterWindow)
        super.applicationDidFinishLaunching(notification)
    }

    private func setupUpdater() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(named: "AppIcon")
            button.image?.size = NSSize(width: 18, height: 18)
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if let panel = popoverPanel, panel.isVisible {
            hidePopover()
        } else {
            if Date().timeIntervalSince(popupLastCloseTime) < 0.2 {
                return
            }
            showPopover()
        }
    }

    func showPopover() {
        guard let panel = popoverPanel else { return }
        
        let width: CGFloat = 320
        let newHeight: CGFloat = self.isPopoverExpanded ? 600 : 400
        
        let mouseLoc = NSEvent.mouseLocation
        let currentScreen = NSScreen.screens.first(where: { NSMouseInRect(mouseLoc, $0.frame, false) }) ?? NSScreen.main
        
        if let screen = currentScreen {
            let x = mouseLoc.x - (width / 2)
            let y = screen.visibleFrame.maxY - newHeight - 8
            panel.setFrame(NSRect(x: x, y: y, width: width, height: newHeight), display: true)
        }
        
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        panel.level = .popUpMenu 
        panel.makeKeyAndOrderFront(nil)
    }

    func hidePopover() {
        if let panel = popoverPanel, panel.isVisible {
             // Посылаем сигнал follower'у (tray) о том что окно закрыто
             IpcRouter.shared.routeMessage(from: "native", target: "role:tray", method: "miniClosed_native", payload: nil)
        }
        popoverPanel?.orderOut(nil)
        popupLastCloseTime = Date()
    }

    // Обработчик нативных команд, не покрываемых подписками (show, hide, updateTray)
    func handleNativeCommand(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "show":
            self.showPopover()
            result(nil)
        case "hide":
            self.hidePopover()
            result(nil)
        case "toggle":
            self.togglePopover(nil)
            result(nil)
        case "resizePopover":
            if let args = call.arguments as? [String: Any], let isExpanded = args["isExpanded"] as? Bool {
                self.resizePopover(isExpanded: isExpanded)
            }
            result(nil)
        case "checkForUpdates":
            self.updaterController?.checkForUpdates(nil)
            result(nil)
        case "updateTray":
            if let args = call.arguments as? [String: Any] {
                if let title = args["title"] as? String {
                    self.statusItem.button?.title = title
                }
                if let iconName = args["icon"] as? String {
                    self.statusItem.button?.image = NSImage(named: iconName)
                    self.statusItem.button?.image?.size = NSSize(width: 18, height: 18)
                }
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func resizePopover(isExpanded: Bool) {
        guard let panel = popoverPanel else { return }
        
        self.isPopoverExpanded = isExpanded
        
        // Match logic from showPopover() where y = screen.visibleFrame.maxY - height - 8
        let screen = NSScreen.main ?? NSScreen.screens.first!
        let newHeight: CGFloat = isExpanded ? 600 : 400
        
        var frame = panel.frame
        // We want to keep the top edge of the popover fixed relative to the screen,
        // or ensure it doesn't go off-screen. If it's anchored to the tray,
        // we likely want to grow downwards, so top remains the same.
        
        // Let's recalculate based on the tray anchor
        frame.origin.y = screen.visibleFrame.maxY - newHeight - 8
        frame.size.height = newHeight
        
        panel.setFrame(frame, display: true, animate: true)
    }

    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
