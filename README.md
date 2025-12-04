# 🐾 Hotpaws

> macOS overlay application for terminal command hints

[![Platform](https://img.shields.io/badge/platform-macOS%2012%2B-lightgrey)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/swift-5-orange)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Build](https://img.shields.io/badge/build-passing-brightgreen)](.github/workflows/build.yml)

Press **F19** to instantly access categorized terminal commands. Click any command to insert it into your terminal.

![Hotpaws Demo]($/design.png)

## ✨ Features

- **Instant Access**: F19 hotkey shows fullscreen overlay
- **Smart Organization**: Commands grouped by category → section → command
- **Universal Binary**: Runs natively on Intel and Apple Silicon Macs
- **Customizable**: Edit commands and styles via `~/.hotpaws/`
- **Multiple Terminals**: Supports Terminal.app, iTerm2, and Warp

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/listeomin/hotpaws.git
cd hotpaws

# Build the app
./scripts/build.sh

# Run
open build/Hotpaws.app
```

**First run**: Grant Accessibility permissions when prompted (required for command insertion).

## 📁 Project Structure

```
Вот итоговая структура проекта:
Итоговая структура Hotpaws
hotpaws/
├── src/                      # Swift исходники
│   ├── main.swift            # Точка входа, AppDelegate, WKWebView, хоткеи
│   └── ConfigManager.swift   # Загрузка конфигов из ~/.hotpaws/
│
├── resources/                # Ресурсы (копируются в .app)
│   ├── index.html            # HTML структура оверлея
│   ├── main.css              # Стили
│   ├── main.js               # JavaScript логика
│   ├── commands.json         # Команды пользователя
│   ├── commands-meta.json    # Словарь команд для автодополнения
│   └── AppIcon.icns          # Иконка приложения
│
├── scripts/                  # Скрипты
│   ├── build.sh              # Сборка приложения
│   ├── cleanup.sh            # Очистка билдов
│   ├── terminal.applescript  # AppleScript для Terminal.app
│   ├── iterm2.applescript    # AppleScript для iTerm2
│   ├── warp.applescript      # AppleScript для Warp
│   ├── fallback.applescript  # Резервный AppleScript
│   └── README.md             # Описание скриптов
│
├── build/                    # Артефакты сборки (в .gitignore)
│   └── Hotpaws.app/          # Собранное приложение
│
├── $/                        # Рабочие документы (не в git)
│   ├── project-doc.md        # Документация проекта
│   ├── tasks.md              # Задачи с промптами
│   ├── edit-mode-tasks.md    # Задачи по режиму редактирования
│   ├── design.png            # Дизайн-макет
│   └── CATEGORY_SELECTS.md   # Документация селектов
│
├── .github/                  # GitHub конфигурация
│   ├── workflows/
│   │   └── build.yml
│   └── ISSUE_TEMPLATE/
│
├── .gitignore
├── Info.plist                # Настройки macOS приложения
├── LICENSE                   # MIT лицензия
├── README.md                 # Описание для GitHub
├── CHANGELOG.md              # История изменений
└── CONTRIBUTING.md           # Гайд для контрибьюторов
```

## 🎨 Customization

On first run, Hotpaws creates `~/.hotpaws/` with:

- `commands.json` - Your command library
- `style.css` - Custom styling
- `config.json` - App settings (future)

Edit these files to customize your experience. Changes take effect on next launch.

### Example: Adding Commands

```json
{
  "version": "1.0",
  "categories": [
    {
      "id": "docker",
      "name": "Docker",
      "icon": "🐳",
      "groups": [
        {
          "name": "Containers",
          "commands": [
            {
              "label": "List Running",
              "command": "docker ps",
              "description": "Show running containers"
            }
          ]
        }
      ]
    }
  ]
}
```

## 🛠 Tech Stack

- **Language**: Swift 5
- **UI**: WKWebView (HTML + CSS + JavaScript)
- **Build**: swiftc (no Xcode required)
- **Frameworks**: Cocoa, WebKit, Carbon
- **Terminal Integration**: AppleScript

## 🔧 Architecture

```
[F19 Pressed] → [Swift AppDelegate]
                      ↓
                [WKWebView Window]
                      ↓
                [HTML + JS Interface]
                      ↓ (command clicked)
                [webkit.messageHandlers]
                      ↓
                [Swift receives command]
                      ↓
                [AppleScript → Terminal]
```

## 📋 Requirements

- macOS 12.0+
- Accessibility permissions (for command insertion)
- Terminal.app, iTerm2, or Warp

## 🐛 Known Issues

- First launch requires manual Accessibility permission grant
- Build directory ignored by git (`.app` bundles excluded)

## 🗺 Roadmap

- [ ] GUI for editing commands
- [ ] Command search/filter
- [ ] Command aliases support
- [ ] Theme system
- [ ] iCloud sync

## 📝 License

MIT

## 🤝 Contributing

Contributions welcome! This project is designed for beginners who struggle with terminal commands.

**Philosophy**: 
- Focus on beginners, not power users
- Wrap complexity in intuitive interfaces
- External config over code changes
- No command execution without user confirmation

## 📖 Documentation

See `$/project-doc.md` for complete technical documentation.

---

Made with 🐾 by [@listeomin](https://github.com/listeomin)
