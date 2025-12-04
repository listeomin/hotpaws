#!/bin/bash

cd /Users/ufoanima/Dev/experiments/hotpaws

echo "🚀 Поэтапный push"
echo "================="
echo ""

# Очищаем всё
echo "1️⃣ Сброс..."
rm -rf .git
git init
git branch -M main
git remote add origin https://github.com/listeomin/hotpaws.git

# Этап 1: Только основные файлы (без картинок и binary)
echo ""
echo "2️⃣ Этап 1: Базовые файлы..."
git add *.md *.swift *.sh scripts/*.sh .github/ .gitignore
git commit -m "docs: add documentation and scripts"
git push -f origin main

if [ $? -ne 0 ]; then
    echo "❌ Не получилось даже базовые файлы"
    exit 1
fi

echo "✅ Базовые файлы отправлены!"
echo ""

# Этап 2: Конфигурационные файлы
echo "3️⃣ Этап 2: Конфиги..."
git add Info.plist *.json css/ js/ resources/
git commit -m "feat: add config files and resources"
git push origin main

if [ $? -ne 0 ]; then
    echo "⚠️  Конфиги не отправились, но продолжаем"
fi

echo ""

# Этап 3: HTML/CSS/JS
echo "4️⃣ Этап 3: Web файлы..."
git add index.html *.css *.js
git commit -m "feat: add web interface"
git push origin main

echo ""

# Этап 4: Остальное
echo "5️⃣ Этап 4: Всё остальное..."
git add .
git commit -m "feat: add remaining files"
git push origin main

echo ""
echo "✅ ГОТОВО!"
echo "🔗 https://github.com/listeomin/hotpaws"
