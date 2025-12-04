import Cocoa
import ApplicationServices

class TerminalInjector {
    
    static func insertCommand(_ command: String) {
        // Копируем команду в буфер обмена
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(command, forType: .string)
        
        // Небольшая задержка чтобы буфер обновился
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            // Симулируем Cmd+V
            simulateKeyPress(keyCode: CGKeyCode(цkVK_ANSI_V), flags: .maskCommand)
        }
    }
    
    private static func simulateKeyPress(keyCode: CGKeyCode, flags: CGEventFlags) {
        guard let source = CGEventSource(stateID: .hidSystemState) else { return }
        
        // Key down
        guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true) else { return }
        keyDown.flags = flags
        keyDown.post(tap: .cghidEventTap)
        
        // Key up
        guard let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) else { return }
        keyUp.flags = flags
        keyUp.post(tap: .cghidEventTap)
    }
}
