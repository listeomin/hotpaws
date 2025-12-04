#!/bin/bash

cd /Users/ufoanima/Dev/experiments/hotpaws

echo "🐾 Простой push на GitHub"
echo "========================="
echo ""

# Удаляем .git полностью
echo "1️⃣ Удаляю старый .git..."
rm -rf .git

# Инициализируем заново
echo "2️⃣ Создаю новый git..."
git init
git branch -M main

# Добавляем remote
echo "3️⃣ Подключаю к GitHub..."
git remote add origin https://github.com/listeomin/hotpaws.git

# Добавляем все файлы
echo "4️⃣ Добавляю файлы..."
git add .

# Коммит
echo "5️⃣ Создаю коммит..."
git commit -m "Initial commit"

# Push
echo "6️⃣ Отправляю..."
git push -u origin main --force

echo ""
echo "✅ Готово!"
echo "🔗 https://github.com/listeomin/hotpaws"
