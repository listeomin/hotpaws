#!/bin/bash

echo "🔑 Очистка старых credentials"
echo "=============================="
echo ""

echo "1️⃣ Удаляю старые credentials из Keychain..."

# Удаляем из Keychain
printf "protocol=https\nhost=github.com\n\n" | git credential-osxkeychain erase

echo "✅ Старые credentials удалены"
echo ""

cd /Users/ufoanima/Dev/experiments/hotpaws

echo "2️⃣ Пробую push..."
echo ""
echo "⚠️  Git попросит ввести НОВЫЕ credentials:"
echo "   Username: listeomin"
echo "   Password: [вставь свой новый токен]"
echo ""
read -p "Нажми Enter чтобы продолжить..."
echo ""

git push -f origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Успех! Токен сохранён в Keychain"
    echo "🔗 https://github.com/listeomin/hotpaws"
    echo ""
    echo "Теперь Git больше не будет спрашивать пароль!"
else
    echo ""
    echo "❌ Ошибка"
    echo ""
    echo "Проверь что:"
    echo "  1. Username точно: listeomin"
    echo "  2. Токен рабочий и имеет права 'repo'"
fi
