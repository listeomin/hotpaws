#!/bin/bash

cd /Users/ufoanima/Dev/experiments/hotpaws

echo "🐾 Hotpaws - Force Push"
echo "======================="
echo ""

echo "📋 Что будем отправлять:"
git log --oneline -5
echo ""

echo "📦 Файлы в репозитории:"
git ls-files | head -20
echo "... и другие"
echo ""

echo "🚀 Отправляю с force push..."
echo ""

git push -f origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Успех! Проверяй:"
    echo "🔗 https://github.com/listeomin/hotpaws"
    echo ""
    echo "Должны появиться:"
    echo "  ✓ README.md"
    echo "  ✓ Все файлы проекта"
    echo "  ✓ 5 коммитов в истории"
else
    echo ""
    echo "❌ Ошибка. Попробуем по-другому..."
    echo ""
    echo "Вариант 1: Увеличим buffer для больших файлов"
    git config http.postBuffer 524288000
    echo "✓ Buffer увеличен до 500MB"
    echo ""
    echo "Попробуй снова:"
    echo "  git push -f origin main"
    echo ""
    echo "Вариант 2: Проверь размер .app файлов"
    echo "  find build -name '*.app' -exec du -sh {} \\;"
fi
