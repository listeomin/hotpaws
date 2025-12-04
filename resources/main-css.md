Структура CSS

Overlay (общий контейнер)
│
├─ .overlay-backdrop       → тёмный/размытый фон, pointer-events: none
│
├─ .overlay               → основной контейнер контента
│   ├─ .categories        → горизонтальный список категорий (tabs)
│   │   ├─ .category-tab [active/hover] → отдельная вкладка
│   │
│   ├─ .commands          → grid команд
│   │   ├─ .command [hover/active/edit-mode]
│   │   │   ├─ .command-label
│   │   │   └─ .command-description
│   │   └─ (повтор)
│   │
│   ├─ .autocomplete-container [visible]
│   │   ├─ .suggestion [highlighted]
│   │   └─ data-indicator → число вариантов
│   │
│   ├─ .custom-select
│   │   ├─ .select-button [hover/active]
│   │   ├─ .select-arrow
│   │   └─ .select-options [scrollable]
│   │       ├─ .option [hover/selected/recommended/create-new]
│   │       └─ (повтор)
│   │
│   └─ .edit-mode (класс overlay)
│       ├─ .command → scale + glow + пунктирная рамка
│       └─ ✏️ иконка редактирования
│
└─ .modal-overlay (по требованию)
    └─ .modal
        ├─ .modal-header
        ├─ .modal-body
        └─ .modal-footer
            ├─ .btn-primary [hover/active]
            └─ .btn-secondary [hover/active]
