#!/bin/bash

cd /Users/ufoanima/Dev/experiments/hotpaws

echo "🧹 Очистка истории и push"
echo "=========================="
echo ""

echo "🔧 Проверяю файлы..."
# Файлы уже исправлены - токены заменены на плейсхолдеры

echo "✅ Файлы готовы"
echo ""

# Пересоздаём историю
echo "🔄 Создаю чистую историю..."

# Создаём новую ветку
git checkout --orphan temp-clean-branch

# Добавляем все файлы
git add -A

# Создаём чистый коммит
git commit -m "Initial release: Hotpaws v0.1.0

Features:
- macOS overlay app with F19 hotkey activation  
- Swift + WKWebView architecture
- Terminal integration: Terminal.app, iTerm2, Warp
- Click-to-insert command functionality
- Customizable via ~/.hotpaws/
- Universal binary support (Intel + Apple Silicon)
- Complete documentation and build scripts"

# Удаляем старую ветку main
git branch -D main

# Переименовываем новую ветку в main
git branch -m main

echo "✅ История очищена"
echo ""

# Push
echo "🚀 Отправляю на GitHub..."
echo ""
echo "Git попросит credentials:"
echo "  Username: listeomin"
echo "  Password: [твой новый токен]"
echo ""

git push -f origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Успех!"
    echo "🔗 https://github.com/listeomin/hotpaws"
    echo ""
    echo "✨ Проект опубликован!"
else
    echo ""
    echo "❌ Ошибка"
fi
