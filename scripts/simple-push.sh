#!/bin/bash

# Simple Push - просто пушим существующие коммиты
cd /Users/ufoanima/Dev/experiments/hotpaws

echo "🐾 Hotpaws - Simple Push"
echo "========================"
echo ""

echo "📋 Коммиты для отправки:"
git log --oneline -5
echo ""

echo "📤 Отправляю на GitHub..."
echo ""
echo "ℹ️  Git попросит credentials:"
echo "   Username: listeomin"
echo "   Password: твой GitHub Personal Access Token"
echo ""

git push origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Успешно!"
    echo "🔗 https://github.com/listeomin/hotpaws"
else
    echo ""
    echo "❌ Ошибка. Попробуй:"
    echo ""
    echo "1. Создать новый токен: https://github.com/settings/tokens"
    echo "2. Отметить 'repo'"
    echo "3. Использовать токен как пароль"
    echo ""
    echo "Или используй SSH:"
    echo "git remote set-url origin git@github.com:listeomin/hotpaws.git"
fi
