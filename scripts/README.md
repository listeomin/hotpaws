# AppleScript скрипты для Hotpaws

Этот каталог содержит AppleScript коды для вставки команд в разные терминалы macOS.

## Файлы

### Swift код
- `TerminalManager.swift` - универсальный класс для работы со всеми терминалами

### AppleScript скрипты
- `terminal.applescript` - для Terminal.app (встроенный)
- `iterm2.applescript` - для iTerm2
- `warp.applescript` - для Warp (через System Events)
- `fallback.applescript` - универсальный fallback для любого приложения

## Использование в Swift

```swift
// Подключить TerminalManager.swift к проекту
let terminalManager = TerminalManager()

// Выполнить команду в конкретном терминале
terminalManager.executeCommand("git status", in: .terminal)
terminalManager.executeCommand("ls -la", in: .iterm)

// Получить список доступных терминалов
let available = terminalManager.getAvailableTerminals()
print("Доступные терминалы: \(available)")
```

## Прямое выполнение AppleScript

```swift
func executeInTerminal(_ command: String) {
    let script = """
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
    
    let appleScript = NSAppleScript(source: script)
    appleScript?.executeAndReturnError(nil)
}
```

## Особенности

- **Terminal.app**: Создаёт новое окно если нет открытых, иначе использует текущее
- **iTerm2**: Использует `write text without newline` для вставки без выполнения
- **Warp**: Через System Events (нет полноценного AppleScript API)
- **Fallback**: Через буфер обмена для максимальной совместимости

Все команды вставляются БЕЗ автоматического выполнения - пользователь сам нажимает Enter.
