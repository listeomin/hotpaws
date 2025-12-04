import Cocoa
import Carbon

class HotkeyManager {
    
    private var eventHandler: EventHandlerRef?
    private var hotKeyRef: EventHotKeyRef?
    private let callback: () -> Void
    
    init(callback: @escaping () -> Void) {
        self.callback = callback
        registerHotkey()
    }
    
    private func registerHotkey() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, theEvent, userData) -> OSStatus in
            guard let userData = userData else { return noErr }
            let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
            manager.callback()
            return noErr
        }, 1, &eventType, Unmanaged.passUnretained(self).toOpaque(), &eventHandler)
        
        // Регистрируем Cmd+Shift+H (hotkey ID: 1)
        let hotKeyID = EventHotKeyID(signature: OSType(0x48505753), id: 1) // 'HPWS'
        RegisterEventHotKey(
            UInt32(kVK_ANSI_H),           // H key
            UInt32(cmdKey | shiftKey),     // Cmd+Shift
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }
    
    func unregister() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }
    
    deinit {
        unregister()
    }
}
