// Встроенные команды
const COMMANDS_DATA = {
    "version": "1.0",
    "categories": [
        {
            "id": "git",
            "name": "Git",
            "icon": "🌿",
            "groups": [
                {
                    "name": "Базовое",
                    "commands": [
                        { "label": "git status", "command": "git status", "description": "Показать статус репозитория" },
                        { "label": "git add .", "command": "git add .", "description": "Добавить все изменения" },
                        { "label": "git commit -m", "command": "git commit -m \"\"", "description": "Сохранить изменения с сообщением" },
                        { "label": "git push", "command": "git push", "description": "Отправить коммиты на сервер" },
                        { "label": "git pull", "command": "git pull", "description": "Забрать изменения с сервера" }
                    ]
                },
                {
                    "name": "Ветки",
                    "commands": [
                        { "label": "git branch", "command": "git branch", "description": "Список веток" },
                        { "label": "git checkout -b", "command": "git checkout -b ", "description": "Создать и переключиться на ветку" },
                        { "label": "git merge", "command": "git merge ", "description": "Объединить ветку с текущей" },
                        { "label": "git branch -d", "command": "git branch -d ", "description": "Удалить ветку" }
                    ]
                },
                {
                    "name": "История",
                    "commands": [
                        { "label": "git log --oneline", "command": "git log --oneline -10", "description": "История коммитов (10 шт)" },
                        { "label": "git diff", "command": "git diff", "description": "Показать изменения" },
                        { "label": "git stash", "command": "git stash", "description": "Спрятать незакоммиченное" },
                        { "label": "git stash pop", "command": "git stash pop", "description": "Достать спрятанное" }
                    ]
                }
            ]
        },
        {
            "id": "files",
            "name": "Файлы",
            "icon": "📁",
            "groups": [
                {
                    "name": "Навигация",
                    "commands": [
                        { "label": "ls -la", "command": "ls -la", "description": "Список файлов и папок" },
                        { "label": "pwd", "command": "pwd", "description": "Показать текущую папку" },
                        { "label": "cd", "command": "cd ", "description": "Перейти в папку" },
                        { "label": "cd ~", "command": "cd ~", "description": "Перейти в домашнюю папку" },
                        { "label": "cd ..", "command": "cd ..", "description": "Перейти на уровень выше" }
                    ]
                },
                {
                    "name": "Операции",
                    "commands": [
                        { "label": "mkdir", "command": "mkdir ", "description": "Создать папку" },
                        { "label": "touch", "command": "touch ", "description": "Создать файл" },
                        { "label": "cp", "command": "cp ", "description": "Скопировать файл" },
                        { "label": "mv", "command": "mv ", "description": "Переместить/переименовать" },
                        { "label": "rm", "command": "rm ", "description": "Удалить файл" }
                    ]
                },
                {
                    "name": "Поиск",
                    "commands": [
                        { "label": "find", "command": "find . -name \"\"", "description": "Найти файл по имени" },
                        { "label": "grep", "command": "grep -r \"\" .", "description": "Найти текст в файлах" },
                        { "label": "du -sh", "command": "du -sh *", "description": "Размер файлов и папок" }
                    ]
                }
            ]
        },
        {
            "id": "system",
            "name": "Система",
            "icon": "⚙️",
            "groups": [
                {
                    "name": "Процессы",
                    "commands": [
                        { "label": "ps aux", "command": "ps aux", "description": "Список запущенных процессов" },
                        { "label": "top", "command": "top", "description": "Монитор процессов (live)" },
                        { "label": "kill", "command": "kill ", "description": "Остановить процесс по PID" },
                        { "label": "killall", "command": "killall ", "description": "Остановить процесс по имени" }
                    ]
                },
                {
                    "name": "Сеть",
                    "commands": [
                        { "label": "ifconfig", "command": "ifconfig | grep inet", "description": "Показать IP-адреса" },
                        { "label": "ping", "command": "ping ", "description": "Проверить доступность хоста" },
                        { "label": "curl", "command": "curl ", "description": "Загрузить содержимое URL" }
                    ]
                },
                {
                    "name": "Диск",
                    "commands": [
                        { "label": "df -h", "command": "df -h", "description": "Свободное место на дисках" },
                        { "label": "du -sh", "command": "du -sh", "description": "Размер текущей папки" }
                    ]
                }
            ]
        }
    ]
};

// Состояние приложения
let activeCategory = COMMANDS_DATA.categories[0].id;
let executeMode = true; // true = исполнить, false = только отправить

// Рендер категорий
function renderCategories() {
    const nav = document.getElementById('categories');
    nav.innerHTML = '';
    
    COMMANDS_DATA.categories.forEach(cat => {
        const btn = document.createElement('button');
        btn.className = 'category-tab' + (cat.id === activeCategory ? ' active' : '');
        btn.innerHTML = `<span>${cat.icon}</span><span>${cat.name}</span>`;
        btn.onclick = () => switchCategory(cat.id);
        nav.appendChild(btn);
    });
}

// Рендер команд
function renderCommands() {
    const container = document.getElementById('commands-container');
    container.innerHTML = '';
    
    const category = COMMANDS_DATA.categories.find(c => c.id === activeCategory);
    if (!category) return;
    
    category.groups.forEach(group => {
        const groupDiv = document.createElement('div');
        groupDiv.className = 'group';
        
        const title = document.createElement('h3');
        title.className = 'group-title';
        title.textContent = group.name;
        groupDiv.appendChild(title);
        
        const cmdsDiv = document.createElement('div');
        cmdsDiv.className = 'commands';
        
        group.commands.forEach(cmd => {
            const btn = document.createElement('button');
            btn.className = 'command';
            
            // Создаём структуру: заголовок + описание
            const labelDiv = document.createElement('div');
            labelDiv.className = 'command-label';
            labelDiv.textContent = cmd.label;
            btn.appendChild(labelDiv);
            
            if (cmd.description) {
                const descDiv = document.createElement('div');
                descDiv.className = 'command-description';
                descDiv.textContent = cmd.description;
                btn.appendChild(descDiv);
            }
            
            btn.onclick = () => executeCommand(cmd.command);
            
            // Явно устанавливаем курсор
            btn.style.cursor = 'pointer';
            
            // Явные обработчики hover для WKWebView
            btn.addEventListener('mouseenter', function() {
                console.log('HOVER IN:', cmd.label);
                this.style.background = 'rgba(255, 221, 0, 0.95)';
                this.style.borderColor = 'rgba(255, 221, 0, 1)';
                this.style.color = '#000';
                this.style.transform = 'translateY(-2px)';
                this.style.boxShadow = '0 4px 16px rgba(255, 221, 0, 0.4)';
                this.style.cursor = 'pointer';
                
                // Для описания тоже чёрный цвет
                const desc = this.querySelector('.command-description');
                if (desc) desc.style.color = 'rgba(0, 0, 0, 0.6)';
            });
            
            btn.addEventListener('mouseleave', function() {
                console.log('HOVER OUT:', cmd.label);
                this.style.background = 'rgba(30, 30, 40, 0.96)';
                this.style.borderColor = 'rgba(255, 255, 255, 0.15)';
                this.style.color = '#fff';
                this.style.transform = '';
                this.style.boxShadow = '';
                this.style.cursor = 'pointer';
                
                // Возвращаем серый цвет описанию
                const desc = this.querySelector('.command-description');
                if (desc) desc.style.color = 'rgba(255, 255, 255, 0.4)';
            });
            
            cmdsDiv.appendChild(btn);
        });
        
        groupDiv.appendChild(cmdsDiv);
        container.appendChild(groupDiv);
    });
}

// Переключение категории
function switchCategory(id) {
    activeCategory = id;
    renderCategories();
    renderCommands();
}

// Выполнение команды
function executeCommand(cmd) {
    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.executeCommand) {
        window.webkit.messageHandlers.executeCommand.postMessage({ 
            command: cmd,
            execute: executeMode // true = исполнить, false = только вставить
        });
    }
}

// Закрытие
function closeOverlay() {
    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.closeOverlay) {
        window.webkit.messageHandlers.closeOverlay.postMessage({});
    }
}

// Установка режима выполнения (вызывается из Swift)
function setExecuteMode(shouldExecute) {
    executeMode = shouldExecute;
    console.log('Execute mode:', executeMode ? 'EXECUTE' : 'INSERT ONLY');
}

// Клавиатура
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        closeOverlay();
    } else if (e.key === 'ArrowLeft') {
        const cats = COMMANDS_DATA.categories;
        const idx = cats.findIndex(c => c.id === activeCategory);
        const newIdx = idx > 0 ? idx - 1 : cats.length - 1;
        switchCategory(cats[newIdx].id);
    } else if (e.key === 'ArrowRight') {
        const cats = COMMANDS_DATA.categories;
        const idx = cats.findIndex(c => c.id === activeCategory);
        const newIdx = idx < cats.length - 1 ? idx + 1 : 0;
        switchCategory(cats[newIdx].id);
    }
});

// Клик по фону закрывает оверлей
document.querySelector('.overlay-backdrop').addEventListener('click', closeOverlay);

document.querySelector('.overlay').addEventListener('click', (e) => {
    if (e.target === e.currentTarget || e.target.classList.contains('content')) {
        closeOverlay();
    }
});

// Инициализация
renderCategories();
renderCommands();

console.log('Hotpaws UI initialized');
