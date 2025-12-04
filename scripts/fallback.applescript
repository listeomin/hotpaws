-- Универсальный fallback - вставляет текст в любое активное приложение
-- Через буфер обмена (более надёжно)

on run argv
    set command_text to item 1 of argv
    set the clipboard to command_text
    
    tell application "System Events"
        keystroke "v" using command down
    end tell
end run