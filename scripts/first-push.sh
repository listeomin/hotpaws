#!/bin/bash

# Hotpaws - First commit and push script

set -e

cd /Users/ufoanima/Dev/experiments/hotpaws

echo "🐾 Hotpaws - First Commit & Push"
echo "================================="
echo ""

# Проверка git
if [ ! -d .git ]; then
    echo "❌ Ошибка: не git репозиторий"
    exit 1
fi

echo "📊 Файлы для коммита:"
git status --short
echo ""

read -p "Продолжить? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Отменено"
    exit 0
fi

echo ""
echo "📦 Добавляем файлы..."
git add -A

echo ""
echo "✍️  Создаём коммит..."
git commit -m "Initial release: Hotpaws v0.1.0

Features:
- macOS overlay app with F19 hotkey activation
- Swift + WKWebView architecture (HTML/CSS/JS interface)
- Terminal integration: Terminal.app, iTerm2, Warp
- Click-to-insert command functionality
- Customizable via ~/.hotpaws/ (commands.json, style.css)
- Universal binary support (Intel + Apple Silicon)
- Complete documentation and build scripts

Technical:
- Swift 5 with Cocoa and WebKit frameworks
- AppleScript for terminal automation
- Carbon framework for global hotkeys
- swiftc build without Xcode requirement

Documentation:
- Complete README with quick start
- Contributing guidelines
- MIT License
- GitHub Actions CI/CD
- Issue and PR templates"

echo ""
echo "🚀 Пушим на GitHub..."
git push -u origin main

echo ""
echo "✅ Готово!"
echo "🔗 Проверь: https://github.com/listeomin/hotpaws"
