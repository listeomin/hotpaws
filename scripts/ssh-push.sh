#!/bin/bash

echo "🔑 Настройка SSH для GitHub"
echo "============================"
echo ""

echo "1️⃣ Проверяю SSH ключи..."
if [ -f ~/.ssh/id_ed25519.pub ]; then
    echo "✅ SSH ключ найден!"
    echo ""
    echo "📋 Твой публичный ключ:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat ~/.ssh/id_ed25519.pub
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📝 ЧТО ДЕЛАТЬ:"
    echo "1. Скопируй ключ выше (весь текст)"
    echo "2. Зайди: https://github.com/settings/keys"
    echo "3. Нажми 'New SSH key'"
    echo "4. Вставь ключ и сохрани"
    echo ""
    read -p "Ключ добавлен на GitHub? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "❌ SSH ключа нет. Создаю..."
    echo ""
    ssh-keygen -t ed25519 -C "ufoanima@macbear.local" -f ~/.ssh/id_ed25519 -N ""
    echo ""
    echo "✅ Ключ создан!"
    echo ""
    echo "📋 Твой публичный ключ:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat ~/.ssh/id_ed25519.pub
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📝 ЧТО ДЕЛАТЬ:"
    echo "1. Скопируй ключ выше"
    echo "2. Зайди: https://github.com/settings/keys"
    echo "3. Нажми 'New SSH key'"
    echo "4. Title: 'Mac'"
    echo "5. Вставь ключ"
    echo "6. Нажми 'Add SSH key'"
    echo ""
    read -p "Готово? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

cd /Users/ufoanima/Dev/experiments/hotpaws

echo ""
echo "2️⃣ Меняю remote на SSH..."
git remote remove origin 2>/dev/null
git remote add origin git@github.com:listeomin/hotpaws.git

echo "✅ Remote обновлён"
echo ""

echo "3️⃣ Проверяю соединение с GitHub..."
ssh -T git@github.com

echo ""
echo "4️⃣ Отправляю на GitHub..."
git push -f origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ УСПЕХ!"
    echo "🔗 https://github.com/listeomin/hotpaws"
    echo ""
    echo "🎉 Проект опубликован через SSH!"
else
    echo ""
    echo "❌ Ошибка"
fi
