import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var overlayWindow: OverlayWindow?
    var hotkeyManager: HotkeyManager?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Создаём overlay window (но не показываем)
        overlayWindow = OverlayWindow()
        
        // Настраиваем глобальный хоткей (Cmd+Shift+H)
        hotkeyManager = HotkeyManager { [weak self] in
            self?.toggleOverlay()
        }   
        
        // Скрываем иконку из Dock
        NSApp.setActivationPolicy(.accessory)
    }
    
    func toggleOverlay() {
        guard let window = overlayWindow else { return }
        
        if window.isVisible {
            window.hideOverlay()
        } else {
            window.showOverlay()
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        hotkeyManager?.unregister()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
