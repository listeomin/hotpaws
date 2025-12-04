#!/bin/bash

# Hotpaws Build Script
# Собирает macOS приложение без Xcode

set -e

# Пути
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SRC_DIR="$PROJECT_DIR/src"
RESOURCES_DIR="$PROJECT_DIR/resources"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="Hotpaws"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

echo "🔥 Сборка Hotpaws..."
echo "   Проект: $PROJECT_DIR"

# Очистка предыдущей сборки
rm -rf "$APP_BUNDLE"

# Создание структуры .app bundle
echo "📁 Создание структуры приложения..."
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Компиляция Swift (x86_64 для Intel Mac)
echo "🔨 Компиляция Swift (x86_64 - Intel)..."
swiftc \
    -o "$APP_BUNDLE/Contents/MacOS/hotpaws" \
    -framework Cocoa \
    -framework WebKit \
    -framework Carbon \
    -target x86_64-apple-macos13.0 \
    "$SRC_DIR"/*.swift

# Копирование Info.plist
echo "📋 Копирование Info.plist..."
cp "$PROJECT_DIR/Info.plist" "$APP_BUNDLE/Contents/"

# Копирование ресурсов
echo "📦 Копирование ресурсов..."
for file in index.html script.js style.css commands.json; do
    if [ -f "$RESOURCES_DIR/$file" ]; then
        cp "$RESOURCES_DIR/$file" "$APP_BUNDLE/Contents/Resources/"
        echo "   ✓ $file"
    else
        echo "   ⚠ $file не найден (будет использован fallback)"
    fi
done

# Копирование иконки
echo "🎨 Копирование иконки..."
if [ -f "$PROJECT_DIR/AppIcon.icns" ]; then
    cp "$PROJECT_DIR/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/"
    echo "   ✓ AppIcon.icns"
else
    echo "   ⚠ AppIcon.icns не найдена"
fi

# Установка прав
chmod +x "$APP_BUNDLE/Contents/MacOS/hotpaws"

echo ""
echo "✅ Сборка завершена!"
echo ""
echo "📍 Приложение: $APP_BUNDLE"
echo ""
echo "🚀 Запуск:"
echo "   open $APP_BUNDLE"
echo ""
echo "   или напрямую:"
echo "   $APP_BUNDLE/Contents/MacOS/hotpaws"
echo ""
echo "⌨️  Горячая клавиша: F19"
echo "   ESC — закрыть оверлей"
echo ""
echo "⚠️  При первом запуске macOS попросит разрешения:"
echo "   • Accessibility (для горячих клавиш)"
echo "   • Automation/Terminal (для отправки команд)"
