-- Warp - использует fallback через System Events
-- Warp пока не имеет полноценного AppleScript API

on run argv
    set command_text to item 1 of argv
    
    tell application "Warp"
        activate
    end tell
    
    delay 0.2
    
    tell application "System Events"
        -- Вставляем текст в активное поле
        keystroke command_text
    end tell
end run