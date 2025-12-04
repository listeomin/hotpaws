-- iTerm2 - вставляет команду без выполнения
-- Создаёт новое окно если нет открытых

on run argv
    set command_text to item 1 of argv
    
    tell application "iTerm"
        if (count of windows) = 0 then
            -- Нет окон - создаём новое
            create window with default profile
        end if
        
        tell current session of current window
            write text command_text without newline
        end tell
        
        activate
    end tell
end run