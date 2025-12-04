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

# Компиляция Swift (только Intel Mac, совместимость от macOS Ventura 13.0)
echo "🔨 Компиляция Swift (x86_64 - Intel только, macOS Ventura+)..."
swiftc \
    -o "$APP_BUNDLE/Contents/MacOS/hotpaws" \
    -framework Cocoa \
    -framework WebKit \
    -framework Carbon \
    -target x86_64-apple-macos13.0 \
    -swift-version 5 \
    "$SRC_DIR"/*.swift

# Копирование Info.plist
echo "📋 Копирование Info.plist..."
cp "$PROJECT_DIR/Info.plist" "$APP_BUNDLE/Contents/"

# Копирование ресурсов
echo "📦 Копирование ресурсов..."
for file in index.html main.js main.css commands.json commands-meta.json; do
    if [ -f "$RESOURCES_DIR/$file" ]; then
        cp "$RESOURCES_DIR/$file" "$APP_BUNDLE/Contents/Resources/"
        echo "   ✓ $file"
    else
        echo "   ⚠ $file не найден"
    fi
done

# Копирование иконки
echo "🎨 Копирование иконки..."
if [ -f "$RESOURCES_DIR/AppIcon.icns" ]; then
    cp "$RESOURCES_DIR/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/"
    echo "   ✓ AppIcon.icns"
else
    echo "   ⚠ AppIcon.icns не найдена (опционально)"
fi



# Установка прав
chmod +x "$APP_BUNDLE/Contents/MacOS/hotpaws"

# Удаление quarantine атрибута (обход блокировки macOS)
echo "🔓 Снятие quarantine атрибута..."
xattr -cr "$APP_BUNDLE" 2>/dev/null || true

echo ""
echo "✅ Сборка завершена!"
echo ""
echo "📍 Приложение: $APP_BUNDLE"
echo ""
echo "🚀 Запуск:"
echo "   open $APP_BUNDLE"
echo ""
echo "⚠️  При первом запуске macOS может запросить разрешения:"
echo "   - Accessibility (для AppleScript)"
echo "   - Разрешить запуск неподписанного приложения"
echo ""
echo "⌨️  Горячая клавиша: F19"
echo "   ESC — закрыть оверлей"
