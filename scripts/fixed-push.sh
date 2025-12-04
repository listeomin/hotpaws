#!/bin/bash

# Fixed GitHub Push
# Правильная отправка на GitHub

set -e

cd "$(dirname "$0")/.."

echo "🐾 Hotpaws - GitHub Push (Fixed)"
echo "================================="
echo ""

# Проверяем конфигурацию git
echo "🔧 Проверяю git конфигурацию..."

# Проверяем user.name и user.email
if [ -z "$(git config user.name)" ]; then
    echo "⚠️  Не настроено имя пользователя"
    read -p "Введи своё имя для Git: " git_name
    git config user.name "$git_name"
    echo "✅ Имя сохранено"
fi

if [ -z "$(git config user.email)" ]; then
    echo "⚠️  Не настроен email"
    read -p "Введи свой email для Git: " git_email
    git config user.email "$git_email"
    echo "✅ Email сохранён"
fi

echo ""
echo "👤 Git пользователь: $(git config user.name) <$(git config user.email)>"
echo ""

# Проверяем remote
echo "🌐 Remote URL: $(git config remote.origin.url)"
echo ""

# Проверяем статус
echo "📊 Проверяю изменения..."
if [ -z "$(git status --porcelain)" ]; then
    echo "✅ Локальных изменений нет"
    
    # Проверяем есть ли коммиты для пуша
    if git log origin/main..HEAD --oneline 2>/dev/null | grep -q .; then
        echo "📤 Есть коммиты для отправки:"
        git log origin/main..HEAD --oneline
        echo ""
    else
        echo "✨ Всё уже актуально на GitHub"
        exit 0
    fi
else
    echo "📝 Найдены изменения:"
    git status --short
    echo ""
    
    # Добавляем всё
    git add -A
    echo "✅ Файлы добавлены (git add -A)"
    echo ""
    
    # Коммитим
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    commit_msg="Update: $timestamp"
    
    git commit -m "$commit_msg"
    echo "✅ Коммит создан: $commit_msg"
    echo ""
fi

# Пушим
echo "📤 Отправляю на GitHub..."
echo ""
echo "ℹ️  Если это первый push, Git попросит ввести credentials:"
echo "   Username: listeomin"
echo "   Password: твой GitHub Personal Access Token (не обычный пароль!)"
echo ""
echo "💡 Как получить токен:"
echo "   1. GitHub → Settings → Developer settings → Personal access tokens"
echo "   2. Generate new token (classic)"
echo "   3. Отметь 'repo' и скопируй токен"
echo ""
read -p "Нажми Enter чтобы продолжить..."
echo ""

if git push origin main 2>&1; then
    echo ""
    echo "✅ Всё отправлено на GitHub!"
    echo ""
    echo "🔗 Репозиторий: https://github.com/listeomin/hotpaws"
    echo "✨ Готово!"
else
    echo ""
    echo "❌ Ошибка при отправке"
    echo ""
    echo "🔧 Попробуй это:"
    echo "1. Проверь что у тебя есть доступ к репозиторию"
    echo "2. Создай новый Personal Access Token на GitHub"
    echo "3. Попробуй снова: ./scripts/fixed-push.sh"
    echo ""
    echo "Или используй SSH вместо HTTPS:"
    echo "   git remote set-url origin git@github.com:listeomin/hotpaws.git"
    exit 1
fi
