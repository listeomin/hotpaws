#!/bin/bash

# Quick GitHub Push
# Быстрая отправка всех изменений на GitHub

set -e

cd "$(dirname "$0")/.."

echo "🐾 Hotpaws - Быстрый Push"
echo "=========================="
echo ""

# Проверяем статус
echo "📊 Проверяю изменения..."
if [ -z "$(git status --porcelain)" ]; then
    echo "✅ Локальных изменений нет"
    
    # Проверяем есть ли коммиты для пуша
    if git log origin/main..HEAD --oneline | grep -q .; then
        echo "📤 Есть коммиты для отправки:"
        git log origin/main..HEAD --oneline
        echo ""
        git push origin main
        echo ""
        echo "✅ Коммиты отправлены на GitHub!"
    else
        echo "✨ Всё уже актуально на GitHub"
    fi
else
    echo "📝 Найдены изменения:"
    git status --short
    echo ""
    
    # Добавляем всё
    git add -A
    echo "✅ Файлы добавлены"
    
    # Коммитим
    timestamp=$(date +"%Y-%m-%d %H:%M")
    git commit -m "Update: $timestamp"
    echo "✅ Коммит создан"
    
    # Пушим
    echo ""
    echo "📤 Отправляю на GitHub..."
    git push origin main
    echo ""
    echo "✅ Всё отправлено!"
fi

echo ""
echo "🔗 Репозиторий: https://github.com/listeomin/hotpaws"
echo "✨ Готово!"
