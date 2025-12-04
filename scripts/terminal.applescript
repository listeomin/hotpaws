-- Terminal.app - вставляет команду без выполнения
-- Создаёт новое окно если нет открытых

on run argv
    set command_text to item 1 of argv
    
    tell application "Terminal"
        if (count of windows) = 0 then
            -- Нет окон - создаём новое
            do script ""
            tell front window
                do script command_text in tab 1
            end tell
        else
            -- Есть окна - используем переднее
            tell front window
                tell front tab
                    set current_contents to contents
                    if current_contents ends with "$ " or current_contents ends with "% " then
                        -- Командная строка готова
                        do script command_text
                    else
                        -- Создаём новую вкладку
                        tell application "System Events"
                            keystroke "t" using command down
                        end tell
                        delay 0.1
                        do script command_text in front tab
                    end if
                end tell
            end tell
        end if
        activate
    end tell
end run