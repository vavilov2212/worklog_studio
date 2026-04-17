import AppKit
import FlutterMacOS

class PopoverPanel: NSPanel {
    init(contentRect: NSRect, flutterViewController: FlutterViewController) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )
        
        // Raycast-style configuration
        self.isFloatingPanel = true
        self.level = .floating // Изменено с .statusBar на .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.isMovableByWindowBackground = false
        self.hasShadow = false // Отключаем нативную тень, чтобы не было "квадрата" (тень нарисует сам Flutter)
        self.isReleasedWhenClosed = false // КРИТИЧНО: не уничтожать при закрытии
        
        // Делаем окно прозрачным (Flutter сам нарисует фон)
        self.isOpaque = false
        self.backgroundColor = .clear
        self.alphaValue = 1.0
        
        NSLog("PopoverPanel initialized")
        
        // Дополнительные настройки для стабильности Raycast-level
        self.hidesOnDeactivate = false // КРИТИЧНО: Чтобы шторка открывалась даже когда приложение работает в фоне
        self.becomesKeyOnlyIfNeeded = true
        self.worksWhenModal = true
        
        self.contentViewController = flutterViewController
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        // КРИТИЧНО: Поповер не должен становиться "Main" окном, 
        // иначе он будет отбирать статус "главного окна" у вашего основного UI (AppShell),
        // что приводило к неестественной потере фокуса у основного окна.
        return false
    }
}
