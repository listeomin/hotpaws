/* Hotpaws — Overlay JavaScript. Управление интерфейсом оверлея
Правила: Перед началом работ с файлом ознакомся с правилами и строго им следуй!
 1. Простые комментарии без докараций*/

console.log('🐾 Hotpaws JS загружен');

// Глобальные переменные
let currentCommandData = null;
let isEditMode = false;
let commandsDictionary = [];
let currentSuggestions = [];
let selectedSuggestionIndex = -1;
let lastInputValue = '';

// Состояние селектов
let currentCommands = {}; // Текущие команды со всех категорий
let selectedCategory = null;
let selectedGroup = null;
let recommendedPlacement = null; // { category, group } из словаря


//  Инициализация

document.addEventListener('DOMContentLoaded', function() {
    initializeModal();
    initializeHoverEffects();
    initializeKeyboardNavigation();
    
    // Загрузить словарь команд
    loadCommandsDictionary();
    
    // Тестовые данные для демонстрации
    loadTestData();
});


// Инициализация модального окна

function initializeModal() {
    const modalOverlay = document.getElementById('modal-overlay');
    const modalClose = document.getElementById('modal-close');
    const btnCancel = document.getElementById('btn-cancel');
    const commandForm = document.getElementById('command-form');
    
    // Закрытие модального окна
    modalClose.addEventListener('click', closeCommandEditor);
    btnCancel.addEventListener('click', closeCommandEditor);
    
    // Закрытие по клику на backdrop
    modalOverlay.addEventListener('click', function(e) {
        if (e.target === modalOverlay) {
            closeCommandEditor();
        }
    });
    
    // Закрытие по ESC (только если модальное окно открыто)
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape' && modalOverlay.classList.contains('visible')) {
            e.stopPropagation();
            hideAutocompleteSuggestions();
            closeCommandEditor();
        }
    });
    
    // Обработка отправки формы
    commandForm.addEventListener('submit', function(e) {
        e.preventDefault();
        saveCommand();
    });
    
    // Инициализация автодополнения и селектов
    initializeAutocomplete();
    initializeSelects();
}

// ============================================
//   Загрузка словаря команд
// ============================================

/**
 * Загрузить словарь команд для автодополнения
 */
async function loadCommandsDictionary() {
    try {
        console.log('📚 Загружаем словарь команд...');
        
        // В реальном приложении это будет через Swift:
        // webkit.messageHandlers.loadDictionary.postMessage({});
        
        // Пока загружаем напрямую
        const response = await fetch('commands-dictionary.json');
        const data = await response.json();
        
        commandsDictionary = data.commands || [];
        console.log(`📚 Словарь загружен: ${commandsDictionary.length} команд`);
    } catch (error) {
        console.warn('⚠️ Ошибка загрузки словаря:', error);
        commandsDictionary = [];
    }
}

// ============================================
//   Автодополнение
// ============================================

/**
 * Инициализация автодополнения для поля команды
 */
function initializeAutocomplete() {
    const commandInput = document.getElementById('command-input');
    const commandGroup = document.querySelector('#command-input').closest('.form-group');
    
    // Создаём контейнер для автодополнения
    const autocompleteContainer = document.createElement('div');
    autocompleteContainer.className = 'autocomplete-container';
    
    // Создаём поле для inline подсказки
    const suggestionSpan = document.createElement('span');
    suggestionSpan.className = 'autocomplete-suggestion';
    
    autocompleteContainer.appendChild(commandInput);
    autocompleteContainer.appendChild(suggestionSpan);
    
    // Заменяем оригинальный input
    const originalParent = commandInput.parentNode;
    originalParent.replaceChild(autocompleteContainer, commandInput);
    
    // Обработчики событий
    commandInput.addEventListener('input', handleAutocompleteInput);
    commandInput.addEventListener('keydown', handleAutocompleteKeydown);
    
    // Небольшая задержка на blur чтобы можно было нажать Tab
    commandInput.addEventListener('blur', function() {
        setTimeout(hideAutocompleteSuggestions, 100);
    });
}

/**
 * Обработка ввода в поле команды
 */
function handleAutocompleteInput(e) {
    const input = e.target;
    const value = input.value.toLowerCase().trim();
    
    // Сброс если поле пустое
    if (!value) {
        hideAutocompleteSuggestions();
        checkForAutoDescription('');
        updateFieldIndicators();
        return;
    }
    
    // Поиск совпадений
    currentSuggestions = findCommandSuggestions(value);
    selectedSuggestionIndex = currentSuggestions.length > 0 ? 0 : -1;
    
    // Показать подсказку
    showInlineSuggestion(value);
    
    // Проверить автозаполнение описания и категории
    checkForAutoDescription(input.value.trim());
    checkForCategoryRecommendation(input.value.trim());
    
    // Обновить визуальные индикаторы
    updateFieldIndicators();
    
    lastInputValue = value;
}

/**
 * Обработка клавиш в поле автодополнения
 */
function handleAutocompleteKeydown(e) {
    if (!currentSuggestions.length) return;
    
    switch (e.key) {
        case 'ArrowUp':
            e.preventDefault();
            selectedSuggestionIndex = Math.max(0, selectedSuggestionIndex - 1);
            showInlineSuggestion(lastInputValue);
            break;
            
        case 'ArrowDown':
            e.preventDefault();
            selectedSuggestionIndex = Math.min(currentSuggestions.length - 1, selectedSuggestionIndex + 1);
            showInlineSuggestion(lastInputValue);
            break;
            
        case 'Tab':
        case 'ArrowRight':
            if (selectedSuggestionIndex >= 0) {
                e.preventDefault();
                acceptSuggestion();
            }
            break;
            
        case 'Escape':
            e.stopPropagation();
            hideAutocompleteSuggestions();
            break;
            
        case 'Enter':
            // Enter не принимает подсказку, просто отправляет форму
            hideAutocompleteSuggestions();
            break;
    }
}

/**
 * Найти команды, начинающиеся с введённого текста
 */
function findCommandSuggestions(input) {
    if (!input || !commandsDictionary.length) return [];
    
    const suggestions = commandsDictionary
        .filter(cmd => cmd.command.toLowerCase().startsWith(input))
        .slice(0, 10); // Топ-10 совпадений
    
    // Сортировка: точные совпадения сначала, потом по длине
    return suggestions.sort((a, b) => {
        const aExact = a.command.toLowerCase() === input;
        const bExact = b.command.toLowerCase() === input;
        
        if (aExact && !bExact) return -1;
        if (!aExact && bExact) return 1;
        
        return a.command.length - b.command.length;
    });
}

/**
 * Показать inline подсказку
 */
function showInlineSuggestion(input) {
    const suggestionSpan = document.querySelector('.autocomplete-suggestion');
    const commandInput = document.getElementById('command-input');
    
    if (selectedSuggestionIndex >= 0 && currentSuggestions[selectedSuggestionIndex]) {
        const suggestion = currentSuggestions[selectedSuggestionIndex];
        const completion = suggestion.command.slice(input.length);
        
        if (completion) {
            // Вычисляем позицию за введённым текстом
            const textWidth = getTextWidth(commandInput.value, commandInput);
            
            suggestionSpan.textContent = completion;
            suggestionSpan.style.display = 'inline';
            suggestionSpan.style.paddingLeft = `calc(var(--spacing-md) + ${textWidth}px)`;
            
            // Добавляем класс для анимации
            suggestionSpan.classList.add('visible');
            
            // Подсвечиваем активный вариант
            if (currentSuggestions.length > 1) {
                suggestionSpan.classList.add('highlighted');
                
                // Добавляем индикатор количества вариантов
                const indicator = ` (${selectedSuggestionIndex + 1}/${currentSuggestions.length})`;
                suggestionSpan.setAttribute('data-indicator', indicator);
            } else {
                suggestionSpan.removeAttribute('data-indicator');
            }
        } else {
            suggestionSpan.style.display = 'none';
            suggestionSpan.removeAttribute('data-indicator');
        }
    } else {
        suggestionSpan.style.display = 'none';
        suggestionSpan.classList.remove('visible', 'highlighted');
    }
}

/**
 * Вычислить ширину текста в пикселях
 */
function getTextWidth(text, element) {
    const canvas = getTextWidth.canvas || (getTextWidth.canvas = document.createElement('canvas'));
    const context = canvas.getContext('2d');
    
    // Копируем стили шрифта
    const computedStyle = window.getComputedStyle(element);
    context.font = `${computedStyle.fontSize} ${computedStyle.fontFamily}`;
    
    return context.measureText(text).width;
}

/**
 * Принять текущую подсказку
 */
function acceptSuggestion() {
    if (selectedSuggestionIndex >= 0 && currentSuggestions[selectedSuggestionIndex]) {
        const commandInput = document.getElementById('command-input');
        const suggestion = currentSuggestions[selectedSuggestionIndex];
        
        commandInput.value = suggestion.command;
        hideAutocompleteSuggestions();
        
        // Автозаполнение описания и категории
        checkForAutoDescription(suggestion.command);
        checkForCategoryRecommendation(suggestion.command);
        
        // Обновить индикаторы
        updateFieldIndicators();
        
        // Анимация принятия
        const suggestionSpan = document.querySelector('.autocomplete-suggestion');
        suggestionSpan.style.transition = 'opacity 200ms ease-out';
        suggestionSpan.style.opacity = '0';
        
        setTimeout(() => {
            suggestionSpan.style.transition = '';
            suggestionSpan.style.opacity = '';
        }, 200);
    }
}

/**
 * Скрыть подсказки автодополнения
 */
function hideAutocompleteSuggestions() {
    const suggestionSpan = document.querySelector('.autocomplete-suggestion');
    if (suggestionSpan) {
        suggestionSpan.style.display = 'none';
        suggestionSpan.classList.remove('visible', 'highlighted');
        suggestionSpan.style.paddingLeft = 'calc(var(--spacing-md) + 2px)';
    }
    
    currentSuggestions = [];
    selectedSuggestionIndex = -1;
    lastInputValue = '';
}

/**
 * Проверить и автозаполнить описание команды
 */
function checkForAutoDescription(command) {
    const descriptionInput = document.getElementById('description-input');
    
    // Автозаполнение только если поле описания пустое
    if (!command || descriptionInput.value.trim()) return;
    
    const matchingCommand = commandsDictionary.find(cmd => 
        cmd.command.toLowerCase() === command.toLowerCase()
    );
    
    if (matchingCommand && matchingCommand.description) {
        descriptionInput.value = matchingCommand.description;
        
        // Плавная анимация заполнения
        descriptionInput.style.transition = 'background-color 300ms ease-out';
        descriptionInput.style.backgroundColor = 'rgba(255, 221, 0, 0.1)';
        
        setTimeout(() => {
            descriptionInput.style.backgroundColor = '';
        }, 1000);
        
        setTimeout(() => {
            descriptionInput.style.transition = '';
        }, 1300);
        
        console.log('✨ Автозаполнено описание:', matchingCommand.description);
    }
}

/**
 * Проверить рекомендации категории и группы
 */
function checkForCategoryRecommendation(command) {
    if (!command) {
        recommendedPlacement = null;
        updateCategorySelectStyle();
        return;
    }
    
    const matchingCommand = commandsDictionary.find(cmd => 
        cmd.command.toLowerCase() === command.toLowerCase()
    );
    
    if (matchingCommand && matchingCommand.category && matchingCommand.group) {
        recommendedPlacement = {
            category: matchingCommand.category,
            group: matchingCommand.group
        };
        
        console.log('✨ Найдена рекомендация:', recommendedPlacement);
        updateCategorySelectStyle();
        
        // Автоматически выбрать рекомендуемую категорию и группу
        selectCategoryById(findCategoryId(matchingCommand.category));
        selectGroupByName(matchingCommand.group);
    } else {
        recommendedPlacement = null;
        updateCategorySelectStyle();
    }
}

/**
 * Найти ID категории по имени
 */
function findCategoryId(categoryName) {
    if (!currentCommands.categories) return null;
    
    const category = currentCommands.categories.find(cat => 
        cat.name.toLowerCase() === categoryName.toLowerCase()
    );
    
    return category ? category.id : null;
}

/**
 * Обновить визуальные индикаторы состояния полей
 * Вызывается при изменении любого поля формы
 */
function updateFieldIndicators() {
    const commandInput = document.getElementById('command-input');
    const categoryButton = document.getElementById('category-select-button');
    const groupButton = document.getElementById('group-select-button');
    
    // ====== КОМАНДА ======
    const commandValue = commandInput.value.trim();
    
    // Убрать все классы состояния
    commandInput.classList.remove('field-active', 'field-recommended', 'field-match', 'field-custom', 'field-conflict');
    
    if (!commandValue) {
        // Пустое поле — нет индикатора
        return;
    }
    
    // Проверить совпадение со словарём
    const matchingCommand = commandsDictionary.find(cmd => 
        cmd.command.toLowerCase() === commandValue.toLowerCase()
    );
    
    if (matchingCommand) {
        // Зелёная обводка — команда есть в словаре
        commandInput.classList.add('field-recommended');
        console.log('✅ Команда найдена в словаре:', matchingCommand);
    } else if (commandValue.length > 0) {
        // Жёлтая обводка — пользовательское значение
        commandInput.classList.add('field-custom');
        console.log('⚠️ Команда не найдена в словаре');
    }
    
    // ====== КАТЕГОРИЯ И ГРУППА ======
    updateCategoryIndicators(categoryButton);
    updateGroupIndicators(groupButton);
}

/**
 * Обновить индикаторы для селекта категорий
 */
function updateCategoryIndicators(categoryButton) {
    categoryButton.classList.remove('field-active', 'field-recommended', 'field-match', 'field-custom', 'field-conflict');
    
    if (!selectedCategory) {
        // Не выбрана категория
        return;
    }
    
    // Если есть рекомендация и выбор совпадает — зелёная обводка
    if (recommendedPlacement && selectedCategory === recommendedPlacement.category) {
        categoryButton.classList.add('field-recommended');
        console.log('✅ Категория совпадает с рекомендацией');
    }
    // Если есть рекомендация но выбор другой — жёлтая обводка
    else if (recommendedPlacement && selectedCategory !== recommendedPlacement.category) {
        categoryButton.classList.add('field-custom');
        console.log('⚠️ Категория не совпадает с рекомендацией');
    }
    // Если рекомендации нет и выбор есть — нейтрально
    else if (selectedCategory && !recommendedPlacement) {
        // Нет индикатора
    }
}

/**
 * Обновить индикаторы для селекта групп
 */
function updateGroupIndicators(groupButton) {
    groupButton.classList.remove('field-active', 'field-recommended', 'field-match', 'field-custom', 'field-conflict');
    
    if (!selectedGroup || !selectedCategory) {
        // Не выбрана группа или категория
        return;
    }
    
    // Если есть рекомендация и выбор совпадает — зелёная обводка
    if (recommendedPlacement && 
        selectedGroup === recommendedPlacement.group && 
        selectedCategory === recommendedPlacement.category) {
        groupButton.classList.add('field-recommended');
        console.log('✅ Группа совпадает с рекомендацией');
    }
    // Если есть рекомендация но выбор другой — жёлтая обводка
    else if (recommendedPlacement && 
        (selectedGroup !== recommendedPlacement.group || 
         selectedCategory !== recommendedPlacement.category)) {
        groupButton.classList.add('field-custom');
        console.log('⚠️ Группа не совпадает с рекомендацией');
    }
    // Если рекомендации нет и выбор есть — нейтрально
    else if (selectedGroup && !recommendedPlacement) {
        // Нет индикатора
    }
}

/**
 * Обновить стиль селектора категории (зёленая/жёлтая обводка)
 */
function updateCategorySelectStyle() {
    const categoryButton = document.getElementById('category-select-button');
    
    // Убрать все стили
    categoryButton.classList.remove('recommended-choice', 'user-choice');
    
    if (!recommendedPlacement) return;
    
    if (selectedCategory === recommendedPlacement.category) {
        // Зелёная обводка - рекомендуемое размещение
        categoryButton.classList.add('recommended-choice');
    } else if (selectedCategory && selectedCategory !== recommendedPlacement.category) {
        // Жёлтая обводка - пользователь выбрал другое
        categoryButton.classList.add('user-choice');
    }
}

/** Функции управления модальным окном
* Открыть редактор команды
* @param {Object} commandData - Данные команды: { id, label, command, description, categoryId, groupName }
*/
function openCommandEditor(commandData) {
    console.log('🎯 Открытие редактора команды:', commandData);
    
    currentCommandData = commandData;
    
    // Заполнить поля формы
    document.getElementById('command-input').value = commandData.command || '';
    document.getElementById('description-input').value = commandData.description || '';
    
    // Проверка рекомендаций для новых команд после заполнения селектов
    if (!commandData.categoryId && commandData.command) {
        setTimeout(() => {
            checkForCategoryRecommendation(commandData.command);
        }, 50);
    }
    
    // Обновить селекты
    populateCategorySelect();
    
    // Если редактируем существующую команду
    if (commandData.categoryId && commandData.groupName) {
        setTimeout(() => {
            selectCategoryById(commandData.categoryId);
            selectGroupByName(commandData.groupName);
        }, 50);
    }
    
    // Обновить индикаторы
    setTimeout(() => {
        updateFieldIndicators();
    }, 100);
    
    // Показать модальное окно с анимацией
    const modalOverlay = document.getElementById('modal-overlay');
    modalOverlay.classList.remove('closing');
    modalOverlay.classList.add('visible');
    
    // Фокус на первое поле
    setTimeout(() => {
        document.getElementById('command-input').focus();
    }, 150);
}

/**
 * Закрыть редактор команды
 */
function closeCommandEditor() {
    console.log('❌ Закрытие редактора команды');
    
    const modalOverlay = document.getElementById('modal-overlay');
    
    // Анимация закрытия
    modalOverlay.classList.add('closing');
    
    setTimeout(() => {
        modalOverlay.classList.remove('visible', 'closing');
        currentCommandData = null;
        
        // Очистить форму
        document.getElementById('command-form').reset();
        
        // Очистить селекты
        resetSelects();
    }, 200);
}

/**
 * Сохранить изменения команды
 */
function saveCommand() {
    const command = document.getElementById('command-input').value.trim();
    const description = document.getElementById('description-input').value.trim();
    const categoryId = document.getElementById('category-select').value;
    const groupName = document.getElementById('group-select').value;
    
    if (!command) {
        alert('Поле "Команда" обязательно для заполнения');
        return;
    }
    
    if (!categoryId || !groupName) {
        alert('Пожалуйста, выберите категорию и группу команды');
        return;
    }
    
    console.log('💾 Сохранение команды:', {
        original: currentCommandData,
        updated: { command, description, categoryId, groupName }
    });
    
    // TODO: Здесь будет логика сохранения в commands.json через Swift
    // webkit.messageHandlers.saveCommand.postMessage({
    //     id: currentCommandData.id,
    //     command: command,
    //     description: description,
    //     categoryId: categoryId,
    //     groupName: groupName
    // });
    
    // Временно - просто уведомление
    alert(`Команда сохранена:\n${command}\nКатегория: ${getCategoryName(categoryId)}\nГруппа: ${groupName}\n${description || '(без описания)'}`);
    
    closeCommandEditor();
}

// ============================================
//   Hover эффекты (для WKWebView совместимости)
// ============================================

function initializeHoverEffects() {
    // Обработка hover для команд и табов категорий
    document.querySelectorAll('.command, .category-tab').forEach(el => {
        el.addEventListener('mouseenter', () => el.classList.add('hover'));
        el.addEventListener('mouseleave', () => el.classList.remove('hover'));
        
        // В режиме редактирования добавляем клик для команд
        if (el.classList.contains('command')) {
            el.addEventListener('click', function() {
                if (isEditMode) {
                    openCommandEditor({
                        id: 'test-command-' + Math.random(),
                        label: el.querySelector('.command-label')?.textContent || 'Команда',
                        command: el.querySelector('.command-code')?.textContent || '',
                        description: el.querySelector('.command-description')?.textContent || '',
                        categoryId: 'git',
                        groupName: 'Базовое'
                    });
                } else {
                    executeCommand(el.querySelector('.command-code')?.textContent || '');
                }
            });
        }
    });
}

// ============================================
//   Навигация клавиатурой
// ============================================

function initializeKeyboardNavigation() {
    document.addEventListener('keydown', function(e) {
        // Пропускаем если модальное окно открыто
        if (document.getElementById('modal-overlay').classList.contains('visible')) {
            return;
        }
        
        switch(e.key) {
            case 'Escape':
                closeOverlay();
                break;
            case 'ArrowLeft':
                e.preventDefault();
                switchCategory(-1);
                break;
            case 'ArrowRight':
                e.preventDefault();
                switchCategory(1);
                break;
            case 'e':
            case 'E':
                if (e.metaKey || e.ctrlKey) { // Cmd+E или Ctrl+E
                    e.preventDefault();
                    toggleEditMode();
                }
                break;
        }
    });
}

// ============================================
//   Основные функции интерфейса
// ============================================

/**
 * Выполнить команду в терминале
 */
function executeCommand(command) {
    console.log('🚀 Выполнение команды:', command);
    
    // Отправка команды в Swift через webkit.messageHandlers
    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.executeCommand) {
        webkit.messageHandlers.executeCommand.postMessage({
            command: command
        });
    } else {
        console.log('⚠️ webkit.messageHandlers недоступен, команда:', command);
    }
}

/**
 * Закрыть оверлей
 */
function closeOverlay() {
    console.log('👋 Закрытие оверлея');
    
    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.closeOverlay) {
        webkit.messageHandlers.closeOverlay.postMessage({});
    } else {
        console.log('⚠️ webkit.messageHandlers.closeOverlay недоступен');
    }
}

/**
 * Переключить категорию стрелками
 */
function switchCategory(direction) {
    const tabs = document.querySelectorAll('.category-tab');
    const activeTab = document.querySelector('.category-tab.active');
    
    if (!activeTab || tabs.length === 0) return;
    
    const currentIndex = Array.from(tabs).indexOf(activeTab);
    const newIndex = (currentIndex + direction + tabs.length) % tabs.length;
    
    tabs[newIndex].click();
}

/**
 * Переключить режим редактирования
 */
function toggleEditMode() {
    isEditMode = !isEditMode;
    const overlay = document.querySelector('.overlay');
    
    if (isEditMode) {
        overlay.classList.add('edit-mode');
        showEditModeIndicator();
        console.log('✏️ Режим редактирования включен');
    } else {
        overlay.classList.remove('edit-mode');
        hideEditModeIndicator();
        console.log('👁️ Режим просмотра включен');
    }
}

/**
 * Показать индикатор режима редактирования
 */
function showEditModeIndicator() {
    // Создаем индикатор если его нет
    if (!document.querySelector('.edit-mode-indicator')) {
        const indicator = document.createElement('div');
        indicator.className = 'edit-mode-indicator';
        indicator.innerHTML = `
            <div class="edit-mode-badge">
                <span class="edit-mode-icon">✏️</span>
                <span class="edit-mode-text">Режим редактирования</span>
            </div>
            <div class="edit-mode-hint">Нажмите на команду для редактирования</div>
        `;
        document.body.appendChild(indicator);
    }
}

/**
 * Скрыть индикатор режима редактирования
 */
function hideEditModeIndicator() {
    const indicator = document.querySelector('.edit-mode-indicator');
    if (indicator) {
        indicator.remove();
    }
}

// ============================================
//   Загрузка и рендер данных
// ============================================

/**
 * Загрузить команды и отрендерить интерфейс
 */
function loadCommands(commandsData) {
    console.log('📂 Загрузка команд:', commandsData);
    
    // Сохранить данные глобально
    currentCommands = commandsData;
    
    renderCategories(commandsData.categories);
    
    // Показать первую категорию по умолчанию
    if (commandsData.categories && commandsData.categories.length > 0) {
        showCategory(commandsData.categories[0]);
    }
}

/**
 * Отрендерить табы категорий
 */
function renderCategories(categories) {
    const categoriesContainer = document.getElementById('categories');
    categoriesContainer.innerHTML = '';
    
    categories.forEach((category, index) => {
        const tab = document.createElement('div');
        tab.className = `category-tab ${index === 0 ? 'active' : ''}`;
        tab.dataset.categoryId = category.id;
        
        tab.innerHTML = `
            <span class="category-icon">${category.icon}</span>
            <span class="category-name">${category.name}</span>
        `;
        
        tab.addEventListener('click', () => {
            // Убрать активный класс у всех табов
            document.querySelectorAll('.category-tab').forEach(t => t.classList.remove('active'));
            tab.classList.add('active');
            
            showCategory(category);
        });
        
        categoriesContainer.appendChild(tab);
    });
}

/**
 * Показать команды категории
 */
function showCategory(category) {
    const container = document.getElementById('commands-container');
    container.innerHTML = '';
    
    category.groups.forEach(group => {
        const groupDiv = document.createElement('div');
        groupDiv.className = 'group';
        
        groupDiv.innerHTML = `
            <h3 class="group-title">${group.name}</h3>
            <div class="commands"></div>
        `;
        
        const commandsDiv = groupDiv.querySelector('.commands');
        
        group.commands.forEach(command => {
            const commandBtn = document.createElement('button');
            commandBtn.className = 'command';
            
            commandBtn.innerHTML = `
                <div class="command-label">${command.label}</div>
                <div class="command-code">${command.command}</div>
                ${command.description ? `<div class="command-description">${command.description}</div>` : ''}
            `;
            
            commandsDiv.appendChild(commandBtn);
        });
        
        container.appendChild(groupDiv);
    });
    
    // Переинициализируем hover эффекты для новых элементов
    initializeHoverEffects();
}

// ============================================
//   Тестовые данные
// ============================================

function loadTestData() {
    const testData = {
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
                            {
                                "label": "Статус",
                                "command": "git status",
                                "description": "Показать состояние репозитория"
                            },
                            {
                                "label": "Лог",
                                "command": "git log --oneline -10",
                                "description": "Последние 10 коммитов"
                            },
                            {
                                "label": "Изменения",
                                "command": "git diff",
                                "description": "Показать изменения в файлах"
                            }
                        ]
                    },
                    {
                        "name": "Ветки",
                        "commands": [
                            {
                                "label": "Список веток",
                                "command": "git branch -a",
                                "description": "Все ветки (локальные и удалённые)"
                            },
                            {
                                "label": "Новая ветка",
                                "command": "git checkout -b feature/new-feature",
                                "description": "Создать и переключиться на новую ветку"
                            }
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
                            {
                                "label": "Список файлов",
                                "command": "ls -la",
                                "description": "Подробный список всех файлов"
                            },
                            {
                                "label": "Текущая папка",
                                "command": "pwd",
                                "description": "Показать текущий путь"
                            },
                            {
                                "label": "Дерево файлов",
                                "command": "tree -L 3",
                                "description": "Структура папок (3 уровня)"
                            }
                        ]
                    },
                    {
                        "name": "Поиск",
                        "commands": [
                            {
                                "label": "Найти файл",
                                "command": "find . -name '*.js' -type f",
                                "description": "Найти все JS файлы"
                            },
                            {
                                "label": "Поиск в файлах",
                                "command": "grep -r 'TODO' .",
                                "description": "Найти строку во всех файлах"
                            }
                        ]
                    }
                ]
            }
        ]
    };
    
    loadCommands(testData);
    
    // Тест режима редактирования (включаем сразу для демо)
    setTimeout(() => {
        console.log('🧪 Включаем режим редактирования для демонстрации');
        toggleEditMode();
    }, 1000);
}

// ============================================
//   Кастомные селекты
// ============================================

/**
 * Инициализация кастомных селектов
 */
function initializeSelects() {
    initializeCustomSelect('category-select-wrapper', 'category-select', onCategoryChange);
    initializeCustomSelect('group-select-wrapper', 'group-select', onGroupChange);
}

/**
 * Инициализация одного кастомного селекта
 */
function initializeCustomSelect(wrapperId, hiddenInputId, onChange) {
    const wrapper = document.getElementById(wrapperId);
    const button = wrapper.querySelector('.custom-select-button');
    const options = wrapper.querySelector('.custom-select-options');
    const hiddenInput = document.getElementById(hiddenInputId);
    
    // Открытие/закрытие селекта
    button.addEventListener('click', function() {
        if (button.disabled) return;
        
        const isOpen = wrapper.classList.contains('open');
        
        // Закрыть все остальные селекты
        closeAllSelects();
        
        if (!isOpen) {
            wrapper.classList.add('open');
        }
    });
    
    // Обработка кликов по опциям
    options.addEventListener('click', function(e) {
        const option = e.target.closest('.custom-select-option');
        if (!option) return;
        
        if (option.classList.contains('create-new')) {
            showCreateNewOption(option, hiddenInputId);
        } else {
            selectOption(wrapper, option, hiddenInput, onChange);
        }
    });
    
    // Закрытие при клике вне селекта
    document.addEventListener('click', function(e) {
        if (!wrapper.contains(e.target)) {
            wrapper.classList.remove('open');
        }
    });
}

/**
 * Закрыть все открытые селекты
 */
function closeAllSelects() {
    document.querySelectorAll('.custom-select.open').forEach(select => {
        select.classList.remove('open');
    });
}

/**
 * Выбрать опцию
 */
function selectOption(wrapper, optionElement, hiddenInput, onChange) {
    const value = optionElement.dataset.value;
    const text = optionElement.querySelector('.option-text')?.textContent || optionElement.textContent;
    
    // Обновить отображение
    const valueDisplay = wrapper.querySelector('.custom-select-value');
    valueDisplay.textContent = text;
    
    // Обновить скрытое поле
    hiddenInput.value = value;
    
    // Отметить выбранную опцию
    wrapper.querySelectorAll('.custom-select-option').forEach(opt => {
        opt.classList.remove('selected');
    });
    optionElement.classList.add('selected');
    
    // Закрыть селект
    wrapper.classList.remove('open');
    
    // Вызвать callback
    if (onChange) {
        onChange(value, text);
    }
    
    // Обновить индикаторы
    updateFieldIndicators();
}

/**
 * Показать поле создания новой опции
 */
function showCreateNewOption(optionElement, selectId) {
    const existingInput = optionElement.querySelector('.custom-select-create-input');
    if (existingInput) {
        existingInput.focus();
        return;
    }
    
    const input = document.createElement('input');
    input.type = 'text';
    input.className = 'custom-select-create-input';
    input.placeholder = selectId.includes('category') ? 'Новая категория' : 'Новая группа';
    
    // Заменить содержимое
    const originalContent = optionElement.innerHTML;
    optionElement.innerHTML = '';
    optionElement.appendChild(input);
    
    input.focus();
    
    // Обработка создания
    const handleCreate = () => {
        const newValue = input.value.trim();
        if (newValue) {
            createNewOption(selectId, newValue);
        } else {
            // Восстановить оригинальное содержимое
            optionElement.innerHTML = originalContent;
        }
    };
    
    input.addEventListener('keydown', function(e) {
        e.stopPropagation();
        
        if (e.key === 'Enter') {
            e.preventDefault();
            handleCreate();
        } else if (e.key === 'Escape') {
            e.preventDefault();
            optionElement.innerHTML = originalContent;
        }
    });
    
    input.addEventListener('blur', handleCreate);
}

/**
 * Создать новую опцию
 */
function createNewOption(selectId, newValue) {
    if (selectId.includes('category')) {
        createNewCategory(newValue);
    } else if (selectId.includes('group')) {
        createNewGroup(newValue);
    }
}

/**
 * Создать новую категорию
 */
function createNewCategory(categoryName) {
    console.log('➕ Создание новой категории:', categoryName);
    
    // Генерация ID
    const categoryId = categoryName.toLowerCase().replace(/[^a-z0-9]/g, '-');
    
    // Добавить в currentCommands
    if (!currentCommands.categories) {
        currentCommands.categories = [];
    }
    
    const newCategory = {
        id: categoryId,
        name: categoryName,
        icon: '🔄', // Общая иконка для новых категорий
        groups: []
    };
    
    currentCommands.categories.push(newCategory);
    
    // Обновить селект и выбрать
    populateCategorySelect();
    selectCategoryById(categoryId);
}

/**
 * Создать новую группу
 */
function createNewGroup(groupName) {
    if (!selectedCategory) {
        alert('Сначала выберите категорию');
        return;
    }
    
    console.log('➕ Создание новой группы:', groupName, 'в категории', selectedCategory);
    
    // Найти категорию
    const category = currentCommands.categories.find(cat => cat.name === selectedCategory);
    if (!category) return;
    
    // Проверить, нет ли уже такой группы
    const existingGroup = category.groups.find(group => group.name.toLowerCase() === groupName.toLowerCase());
    if (existingGroup) {
        alert('Группа с таким именем уже существует');
        return;
    }
    
    // Добавить новую группу
    const newGroup = {
        name: groupName,
        commands: []
    };
    
    category.groups.push(newGroup);
    
    // Обновить селект и выбрать
    populateGroupSelect();
    selectGroupByName(groupName);
}

/**
 * Заполнить селект категорий
 */
function populateCategorySelect() {
    const optionsContainer = document.getElementById('category-select-options');
    optionsContainer.innerHTML = '';
    
    if (!currentCommands.categories) return;
    
    // Добавить существующие категории
    currentCommands.categories.forEach(category => {
        const option = document.createElement('button');
        option.className = 'custom-select-option';
        option.type = 'button';
        option.dataset.value = category.id;
        
        // Пометить рекомендуемое
        if (recommendedPlacement && category.name === recommendedPlacement.category) {
            option.classList.add('recommended');
        }
        
        option.innerHTML = `
            <span class="option-icon">${category.icon}</span>
            <span class="option-text">${category.name}</span>
        `;
        
        optionsContainer.appendChild(option);
    });
    
    // Добавить опцию создания новой
    const createOption = document.createElement('button');
    createOption.className = 'custom-select-option create-new';
    createOption.type = 'button';
    createOption.innerHTML = `+ Создать категорию`;
    
    optionsContainer.appendChild(createOption);
}

/**
 * Заполнить селект групп
 */
function populateGroupSelect() {
    const optionsContainer = document.getElementById('group-select-options');
    optionsContainer.innerHTML = '';
    
    if (!selectedCategory) return;
    
    // Найти категорию
    const category = currentCommands.categories.find(cat => cat.name === selectedCategory);
    if (!category || !category.groups) return;
    
    // Добавить группы
    category.groups.forEach(group => {
        const option = document.createElement('button');
        option.className = 'custom-select-option';
        option.type = 'button';
        option.dataset.value = group.name;
        
        // Пометить рекомендуемое
        if (recommendedPlacement && group.name === recommendedPlacement.group && selectedCategory === recommendedPlacement.category) {
            option.classList.add('recommended');
        }
        
        option.innerHTML = `<span class="option-text">${group.name}</span>`;
        optionsContainer.appendChild(option);
    });
    
    // Добавить опцию создания новой
    const createOption = document.createElement('button');
    createOption.className = 'custom-select-option create-new';
    createOption.type = 'button';
    createOption.innerHTML = `+ Создать группу`;
    
    optionsContainer.appendChild(createOption);
}

/**
 * Обработчик смены категории
 */
function onCategoryChange(categoryId, categoryName) {
    selectedCategory = categoryName;
    
    console.log('🏷️ Выбрана категория:', selectedCategory);
    
    // Обновить стиль категорий
    updateCategorySelectStyle();
    
    // Активировать селект групп
    const groupButton = document.getElementById('group-select-button');
    groupButton.disabled = false;
    groupButton.querySelector('.custom-select-value').textContent = 'Выберите группу';
    
    // Сбросить выбранную группу
    selectedGroup = null;
    document.getElementById('group-select').value = '';
    
    // Перезаполнить список групп
    populateGroupSelect();
    
    // Если есть рекомендация, автовыбор группы
    if (recommendedPlacement && selectedCategory === recommendedPlacement.category) {
        selectGroupByName(recommendedPlacement.group);
    }
    
    // Обновить индикаторы
    updateFieldIndicators();
}

/**
 * Обработчик смены группы
 */
function onGroupChange(groupName, groupDisplayName) {
    selectedGroup = groupName;
    console.log('📋 Выбрана группа:', selectedGroup);
    
    // Обновить индикаторы
    updateFieldIndicators();
}

/**
 * Выбрать категорию по ID
 */
function selectCategoryById(categoryId) {
    if (!categoryId) return;
    
    const category = currentCommands.categories?.find(cat => cat.id === categoryId);
    if (!category) return;
    
    const wrapper = document.getElementById('category-select-wrapper');
    const valueDisplay = wrapper.querySelector('.custom-select-value');
    const hiddenInput = document.getElementById('category-select');
    
    valueDisplay.textContent = category.name;
    hiddenInput.value = categoryId;
    
    // Отметить выбранную опцию
    wrapper.querySelectorAll('.custom-select-option').forEach(opt => {
        opt.classList.remove('selected');
        if (opt.dataset.value === categoryId) {
            opt.classList.add('selected');
        }
    });
    
    onCategoryChange(categoryId, category.name);
}

/**
 * Выбрать группу по имени
 */
function selectGroupByName(groupName) {
    if (!groupName || !selectedCategory) return;
    
    const wrapper = document.getElementById('group-select-wrapper');
    const valueDisplay = wrapper.querySelector('.custom-select-value');
    const hiddenInput = document.getElementById('group-select');
    
    valueDisplay.textContent = groupName;
    hiddenInput.value = groupName;
    
    // Отметить выбранную опцию
    wrapper.querySelectorAll('.custom-select-option').forEach(opt => {
        opt.classList.remove('selected');
        if (opt.dataset.value === groupName) {
            opt.classList.add('selected');
        }
    });
    
    onGroupChange(groupName, groupName);
}

/**
 * Получить имя категории по ID
 */
function getCategoryName(categoryId) {
    const category = currentCommands.categories?.find(cat => cat.id === categoryId);
    return category ? category.name : categoryId;
}

/**
 * Сбросить состояние селектов
 */
function resetSelects() {
    selectedCategory = null;
    selectedGroup = null;
    recommendedPlacement = null;
    
    // Сбросить категорию
    const categoryButton = document.getElementById('category-select-button');
    const categoryValue = categoryButton.querySelector('.custom-select-value');
    const categoryInput = document.getElementById('category-select');
    
    categoryValue.textContent = 'Выберите категорию';
    categoryInput.value = '';
    categoryButton.classList.remove('recommended-choice', 'user-choice');
    categoryButton.classList.remove('field-active', 'field-recommended', 'field-match', 'field-custom', 'field-conflict');
    
    // Сбросить группу
    const groupButton = document.getElementById('group-select-button');
    const groupValue = groupButton.querySelector('.custom-select-value');
    const groupInput = document.getElementById('group-select');
    
    groupValue.textContent = 'Сначала выберите категорию';
    groupInput.value = '';
    groupButton.disabled = true;
    groupButton.classList.remove('field-active', 'field-recommended', 'field-match', 'field-custom', 'field-conflict');
    
    // Очистить выделения опций
    document.querySelectorAll('.custom-select-option.selected').forEach(opt => {
        opt.classList.remove('selected');
    });
    
    // Очистить списки
    document.getElementById('category-select-options').innerHTML = '';
    document.getElementById('group-select-options').innerHTML = '';
    
    // Очистить поле команды от индикаторов
    const commandInput = document.getElementById('command-input');
    commandInput.classList.remove('field-active', 'field-recommended', 'field-match', 'field-custom', 'field-conflict');
}
