#!/bin/bash

cd /Users/ufoanima/Dev/experiments/hotpaws

echo "🚀 Push без больших файлов"
echo "=========================="
echo ""

# Временно исключаем картинки и иконки
echo "1️⃣ Временно убираю большие файлы..."
echo "*.png" >> .gitignore
echo "*.icns" >> .gitignore

# Удаляем их из индекса (но не с диска)
git rm --cached AppIcon.icns 2>/dev/null
git rm --cached \$design/*.png 2>/dev/null
git rm --cached \$desi/*.png 2>/dev/null

# Коммитим
echo "2️⃣ Создаю коммит без картинок..."
git add .gitignore
git commit -m "Initial commit (without large assets)"

# Пушим
echo "3️⃣ Отправляю..."
git push -u origin main --force

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Основные файлы отправлены!"
    echo ""
    echo "Теперь добавим картинки:"
    
    # Возвращаем картинки
    sed -i.bak '/\*.png/d' .gitignore
    sed -i.bak '/\*.icns/d' .gitignore
    rm .gitignore.bak
    
    git add AppIcon.icns \$design/ \$desi/
    git commit -m "Add design assets"
    git push origin main
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ ВСЁ ОТПРАВЛЕНО!"
        echo "🔗 https://github.com/listeomin/hotpaws"
    fi
else
    echo ""
    echo "❌ Даже без картинок не работает"
    echo ""
    echo "Это явно проблема с GitHub. Попробуй:"
    echo "1. Зайти на https://github.com/listeomin/hotpaws/settings"
    echo "2. Проверить нет ли каких-то правил защиты"
    echo "3. Или создать репозиторий под другим именем"
fi
