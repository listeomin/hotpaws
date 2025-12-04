# ✅ GitHub Push Checklist

## Шаг 1: Очистка структуры (опционально)

```bash
cd /Users/ufoanima/Dev/experiments/hotpaws

# Дать права на выполнение
chmod +x scripts/cleanup.sh scripts/push.sh

# Запустить очистку
./scripts/cleanup.sh
```

## Шаг 2: Проверка сборки

```bash
# Собрать проект
./scripts/build.sh

# Проверить что работает
open build/Hotpaws.app
# Протестировать: F19, клик по команде, ESC
```

## Шаг 3: Подготовка git

```bash
# Настроить имя и email (если ещё не настроено)
git config user.name "Your Name"
git config user.email "your@email.com"

# Проверить статус
git status

# Посмотреть что изменилось
git diff
```

## Шаг 4: Коммит

```bash
# Вариант A: Всё в один коммит
git add -A
git commit -m "Initial release: Hotpaws v0.1

Features:
- Swift overlay app with WKWebView
- F19 hotkey activation  
- Terminal.app, iTerm2, Warp support
- Customizable via ~/.hotpaws/
- Universal binary (Intel + Apple Silicon)
- Complete documentation

Built with: Swift 5, WebKit, Carbon, AppleScript"

# Вариант B: Использовать интерактивный скрипт
./scripts/push.sh
```

## Шаг 5: Push на GitHub

```bash
git push origin main
```

При первом пуше потребуется:
- **Username**: listeomin
- **Password**: Personal Access Token (создать на github.com/settings/tokens)

Токен сохранится в macOS Keychain.

## Шаг 6: Проверка на GitHub

Открой: https://github.com/listeomin/hotpaws

Проверь:
- ✅ README отображается корректно
- ✅ Структура папок правильная
- ✅ Нет лишних файлов (.DS_Store, build/, etc.)
- ✅ LICENSE и CONTRIBUTING доступны

## Шаг 7: Настройка репозитория на GitHub

На странице репозитория:

1. **About** (справа сверху):
   - Description: `macOS overlay app for terminal command hints`
   - Website: оставить пустым или добавить личный сайт
   - Topics: `macos`, `swift`, `terminal`, `overlay`, `hotkey`

2. **README badges** (опционально):
   Добавить в начало README.md:
   ```markdown
   ![Platform](https://img.shields.io/badge/platform-macOS-lightgrey)
   ![Swift](https://img.shields.io/badge/swift-5-orange)
   ![License](https://img.shields.io/badge/license-MIT-green)
   ```

3. **Releases** (когда готов релиз):
   - Создать тег: `v0.1.0`
   - Приложить Hotpaws.app.zip
   - Описать изменения

## 🎉 Готово!

Твой проект на GitHub: **https://github.com/listeomin/hotpaws**

## Следующие шаги (опционально)

- [ ] Добавить скриншоты в README
- [ ] Создать GitHub Actions для автосборки
- [ ] Настроить Issues templates
- [ ] Добавить CHANGELOG.md
- [ ] Создать первый Release с .app файлом

---

**Совет**: Сделай хотя бы пару скриншотов работы приложения для README! Это сильно повышает привлекательность проекта.
