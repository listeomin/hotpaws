#!/bin/bash

cd /Users/ufoanima/Dev/experiments/hotpaws

echo "🔍 Диагностика GitHub Push"
echo "==========================="
echo ""

echo "📋 Remote URL:"
git config remote.origin.url
echo ""

echo "📊 Локальные коммиты:"
git log --oneline -5
echo ""

echo "🌐 Проверяю связь с GitHub..."
git ls-remote origin 2>&1
echo ""

echo "📦 Статус репозитория:"
git status
echo ""

echo "🔄 Попробуем pull для синхронизации..."
git pull origin main --rebase
echo ""

echo "✨ Теперь попробуй:"
echo "   git push origin main"
