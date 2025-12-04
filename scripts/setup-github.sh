#!/bin/bash

# Create hotpaws repository on GitHub and push

set -e

GITHUB_TOKEN='YOUR_GITHUB_TOKEN_HERE'
USERNAME='listeomin'
REPO_NAME='hotpaws'

cd /Users/ufoanima/Dev/experiments/hotpaws

echo "🐾 Hotpaws - GitHub Setup"
echo "========================"
echo ""

echo "1️⃣ Создаём репозиторий на GitHub..."
response=$(curl -s -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user/repos \
  -d "{
    \"name\": \"$REPO_NAME\",
    \"description\": \"macOS overlay app for terminal command hints\",
    \"private\": false,
    \"has_issues\": true,
    \"has_projects\": true,
    \"has_wiki\": false
  }")

if echo "$response" | grep -q '"id"'; then
    echo "✅ Репозиторий создан!"
    echo ""
    
    echo "2️⃣ Добавляем файлы в git..."
    git add -A
    
    echo ""
    echo "3️⃣ Создаём коммит..."
    git commit -m "Initial release: Hotpaws v0.1.0

Features:
- macOS overlay app with F19 hotkey activation
- Swift + WKWebView architecture
- Terminal integration: Terminal.app, iTerm2, Warp
- Click-to-insert command functionality
- Customizable via ~/.hotpaws/
- Universal binary support (Intel + Apple Silicon)
- Complete documentation and build scripts"
    
    echo ""
    echo "4️⃣ Пушим на GitHub..."
    git push -u origin main
    
    echo ""
    echo "🎉 Всё готово!"
    echo "🔗 https://github.com/$USERNAME/$REPO_NAME"
    
else
    echo "❌ Ошибка при создании репозитория:"
    echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"
    echo ""
    echo "Попробуй создать вручную:"
    echo "   https://github.com/new"
    exit 1
fi
