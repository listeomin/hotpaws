# 🚨 КАК ЗАПУШИТЬ НА GITHUB

## Проблема
Старый токен в `.git/config` устарел. Я исправил это, убрав токен из URL.

## Что я сделал
1. ✅ Исправил `.git/config` - убрал устаревший токен из URL
2. ✅ Создал скрипт `scripts/fixed-push.sh` с правильной логикой
3. ✅ Создал `PUSH_TO_GITHUB.sh` для быстрого запуска

## ⚡️ Что делать сейчас

### Вариант 1: Быстрый (рекомендую)

Скопируй и вставь в iTerm2:

```bash
cd /Users/ufoanima/Dev/experiments/hotpaws
chmod +x scripts/fixed-push.sh
./scripts/fixed-push.sh
```

Скрипт:
1. Проверит git конфигурацию (имя, email)
2. Покажет что изменилось
3. Сделает коммит
4. Запушит на GitHub

**При первом push** Git попросит:
- Username: `listeomin`
- Password: твой **GitHub Personal Access Token**

### Вариант 2: Ручной

```bash
cd /Users/ufoanima/Dev/experiments/hotpaws

# Проверь статус
git status

# Добавь файлы
git add -A

# Сделай коммит
git commit -m "Initial commit: Hotpaws v0.1"

# Запушь
git push origin main
```

## 🔑 Как получить Personal Access Token

1. Зайди на GitHub: https://github.com/settings/tokens
2. Нажми **"Generate new token (classic)"**
3. Дай название: `Hotpaws Development`
4. Выбери срок действия: **90 days** (или No expiration)
5. Отметь **`repo`** (полный доступ к репозиториям)
6. Нажми **Generate token**
7. **СКОПИРУЙ ТОКЕН** - он больше не покажется!
8. Используй этот токен как пароль при `git push`

## 📋 Если всё равно не работает

### Способ 1: Используй SSH вместо HTTPS

```bash
cd /Users/ufoanima/Dev/experiments/hotpaws

# Смени remote на SSH
git remote set-url origin git@github.com:listeomin/hotpaws.git

# Проверь что есть SSH ключ
ls -la ~/.ssh/id_*.pub

# Если ключа нет - создай
ssh-keygen -t ed25519 -C "ufoanima@macbear.local"

# Скопируй публичный ключ
cat ~/.ssh/id_ed25519.pub

# Добавь его на GitHub: https://github.com/settings/keys
```

### Способ 2: Сброс credentials

```bash
# Удали сохранённые credentials из Keychain
git credential-osxkeychain erase
host=github.com
protocol=https
^D

# Попробуй снова
git push origin main
```

## ✅ Когда всё работает

После успешного push проект будет доступен:
**https://github.com/listeomin/hotpaws**

---

Удачи! 🐾
