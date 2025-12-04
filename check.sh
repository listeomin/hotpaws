#!/bin/bash

cd /Users/ufoanima/Dev/experiments/hotpaws

echo "🔍 Проверка репозитория"
echo "======================="
echo ""

echo "📋 Локальные файлы в git:"
git ls-files | head -20
echo ""

echo "📊 История коммитов:"
git log --oneline
echo ""

echo "🌐 Remote:"
git remote -v
echo ""

echo "🔄 Что на GitHub:"
git ls-remote origin
echo ""

echo "💡 Попробуем ещё раз с verbose:"
git push -u origin main --force --verbose
