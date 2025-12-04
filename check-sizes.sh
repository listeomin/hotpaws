#!/bin/bash

cd /Users/ufoanima/Dev/experiments/hotpaws

echo "📦 Поиск больших файлов"
echo "======================="
echo ""

echo "Файлы больше 1MB:"
find . -type f -size +1M ! -path "./.git/*" ! -path "./build/*" -exec ls -lh {} \;
echo ""

echo "Все файлы с размерами:"
git ls-files -z | xargs -0 du -h | sort -rh | head -20
echo ""

echo "Общий размер репозитория:"
du -sh .git
echo ""

echo "💡 Возможные проблемы:"
echo "1. AppIcon.icns слишком большой?"
echo "2. Картинки в design/ слишком большие?"
echo ""

echo "Проверяю каждый файл:"
ls -lh AppIcon.icns
ls -lh \$design/*.png
