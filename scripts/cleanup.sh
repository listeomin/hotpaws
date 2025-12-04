#!/bin/bash

# Hotpaws Project Cleanup Script
# Приводит структуру проекта в порядок

set -e

cd "$(dirname "$0")/.."

echo "🧹 Hotpaws Project Cleanup"
echo "=========================="
echo ""

# Проверка, что мы в правильной директории
if [ ! -f "README.md" ] || [ ! -d "src" ]; then
    echo "❌ Ошибка: запустите скрипт из корня проекта hotpaws"
    exit 1
fi

echo "📋 Что будет сделано:"
echo "  1. Перемещение Swift файлов в src/"
echo "  2. Удаление дубликатов и пустых папок"
echo "  3. Очистка временных файлов"
echo ""

read -p "Продолжить? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Отменено"
    exit 0
fi

echo ""
echo "🔄 Начинаем очистку..."
echo ""

# Перемещение Swift файлов в src/
echo "📦 Перемещение Swift файлов..."
for file in AppDelegate.swift HotkeyManager.swift OverlayWindow.swift TerminalInjector.swift; do
    if [ -f "$file" ]; then
        echo "  → $file → src/$file"
        mv "$file" "src/"
    fi
done

# Удаление дубликатов папок
echo ""
echo "🗑  Удаление дубликатов..."

if [ -d "$design" ]; then
    echo "  → Удаляю \$design/"
    rm -rf "$design"
fi

if [ -d "$desi" ]; then
    echo "  → Удаляю \$desi/"
    rm -rf "$desi"
fi

if [ -d "css" ]; then
    echo "  → Удаляю css/ (есть resources/)"
    rm -rf "css"
fi

if [ -d "js" ]; then
    echo "  → Удаляю js/ (есть resources/)"
    rm -rf "js"
fi

# Удаление пустых папок
echo ""
echo "🗑  Удаление пустых папок..."

for dir in assets docs images; do
    if [ -d "$dir" ] && [ -z "$(ls -A $dir)" ]; then
        echo "  → Удаляю $dir/"
        rm -rf "$dir"
    fi
done

# Удаление дубликатов файлов
echo ""
echo "🗑  Удаление дубликатов файлов..."

if [ -f "index.html" ]; then
    echo "  → Удаляю index.html (есть resources/index.html)"
    rm "index.html"
fi

# Удаление служебных файлов
echo ""
echo "🗑  Удаление служебных файлов..."

find . -name ".DS_Store" -delete
echo "  → Удалены .DS_Store файлы"

if [ -f ".git/MERGE_MSG.swp" ]; then
    rm ".git/MERGE_MSG.swp"
    echo "  → Удалён .git/MERGE_MSG.swp"
fi

echo ""
echo "✅ Очистка завершена!"
echo ""
echo "📊 Текущая структура:"
ls -1 | grep -v "^\\." | head -20

echo ""
echo "🔍 Следующие шаги:"
echo "  1. Проверь что build.sh работает: ./scripts/build.sh"
echo "  2. Если всё ОК: git add -A && git commit -m 'refactor: clean up structure'"
echo "  3. Отправь на GitHub: git push origin main"
echo ""
echo "📝 Подробности: см. CLEANUP.md"
