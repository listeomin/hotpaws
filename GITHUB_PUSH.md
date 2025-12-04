# 🚀 GitHub Push Instructions

Проект готов к отправке на GitHub! Вот что я сделал:

## ✅ Что обновлено

1. **README.md** - полное описание проекта с badges, структурой, примерами
2. **CONTRIBUTING.md** - гайд для контрибьюторов
3. **LICENSE** - MIT лицензия
4. **.gitignore** - обновлён, исключает build/ и служебные файлы
5. **.git/config** - убрал токен из URL (теперь безопасно)
6. **scripts/push.sh** - интерактивный скрипт для пуша

## 📋 Что нужно сделать

### 1. Дать права на выполнение скрипту
```bash
chmod +x /Users/ufoanima/Dev/experiments/hotpaws/scripts/push.sh
```

### 2. Настроить git credentials (если ещё не настроено)
```bash
cd /Users/ufoanima/Dev/experiments/hotpaws

# Настроить имя и email (если ещё не сделано)
git config user.name "Your Name"
git config user.email "your.email@example.com"

# При первом пуше macOS спросит токен и сохранит его в Keychain
```

### 3. Использовать push.sh скрипт

**Вариант A: Интерактивный**
```bash
cd /Users/ufoanima/Dev/experiments/hotpaws
./scripts/push.sh
```

Скрипт покажет статус и спросит что делать:
1. Добавить все изменения и закоммитить
2. Выборочно добавить файлы  
3. Только показать статус

**Вариант B: Ручками**
```bash
cd /Users/ufoanima/Dev/experiments/hotpaws

# Посмотреть что изменилось
git status

# Добавить все файлы
git add -A

# Сделать коммит
git commit -m "docs: improve README, add CONTRIBUTING and LICENSE"

# Отправить на GitHub
git push origin main
```

### 4. После первого пуша

При первом `git push` macOS попросит ввести:
- **Username**: listeomin  
- **Password**: ваш Personal Access Token (не обычный пароль!)

Токен можно создать на GitHub:
Settings → Developer settings → Personal access tokens → Generate new token

Нужные права:
- ✅ repo (полный доступ к репозиториям)

После ввода, токен сохранится в macOS Keychain и больше спрашивать не будет.

## 🎉 Готово!

После пуша проект будет доступен на:
**https://github.com/listeomin/hotpaws**

## 🔧 Troubleshooting

### Если git спрашивает пароль каждый раз:
```bash
git config --global credential.helper osxkeychain
```

### Если хочешь использовать SSH вместо HTTPS:
```bash
# Смени remote URL на SSH
git remote set-url origin git@github.com:listeomin/hotpaws.git

# Добавь SSH ключ на GitHub (если ещё нет)
ssh-keygen -t ed25519 -C "your.email@example.com"
cat ~/.ssh/id_ed25519.pub  # Скопируй и добавь на GitHub
```

## 📝 Примерный первый коммит

```bash
git add -A
git commit -m "Initial commit: Hotpaws v0.1

- Swift app with WKWebView overlay
- F19 hotkey support
- Terminal.app, iTerm2, Warp integration
- Customizable via ~/.hotpaws/
- Universal binary build script"

git push origin main
```

---

Удачи! 🐾
