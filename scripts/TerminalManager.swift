import Foundation
import Cocoa

class TerminalManager {
    enum TerminalApp: String, CaseIterable {
        case terminal = "Terminal"
        case iterm = "iTerm"
        case warp = "Warp"
        
        var bundleId: String {
            switch self {
            case .terminal: return "com.apple.Terminal"
            case .iterm: return "com.googlecode.iterm2"
            case .warp: return "dev.warp.Warp-Stable"
            }
        }
    }
    
    func executeCommand(_ command: String, in app: TerminalApp) {
        let script: String
        
        switch app {
        case .terminal:
            script = """
            tell application "Terminal"
                if (count of windows) = 0 then
                    do script "\(command)"
                else
                    tell front window
                        do script "\(command)" in front tab
                    end tell
                end if
                activate
            end tell
            """
            
        case .iterm:
            script = """
            tell application "iTerm"
                if (count of windows) = 0 then
                    create window with default profile
                end if
                tell current session of current window
                    write text "\(command)" without newline
                end tell
                activate
            end tell
            """
            
        case .warp:
            // Fallback для Warp
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(command, forType: .string)
            
            let warpScript = """
            tell application "Warp"
                activate
            end tell
            delay 0.2
            tell application "System Events"
                keystroke "v" using command down
            end tell
            """
            script = warpScript
        }
        
        let appleScript = NSAppleScript(source: script)
        var error: NSDictionary?
        appleScript?.executeAndReturnError(&error)
        
        if let error = error {
            print("AppleScript error: \(error)")
            // Fallback на универсальный метод
            fallbackPaste(command)
        }
    }
    
    private func fallbackPaste(_ command: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(command, forType: .string)
        
        let script = """
        tell application "System Events"
            keystroke "v" using command down
        end tell
        """
        
        let appleScript = NSAppleScript(source: script)
        appleScript?.executeAndReturnError(nil)
    }
    
    // Определить доступные терминалы
    func getAvailableTerminals() -> [TerminalApp] {
        return TerminalApp.allCases.filter { app in
            NSWorkspace.shared.urlForApplication(withBundleIdentifier: app.bundleId) != nil
        }
    }
}