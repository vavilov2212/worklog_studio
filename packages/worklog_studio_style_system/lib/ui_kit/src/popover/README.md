# Popover Component

**Popover** — это низкоуровневый строительный блок (примитив) для создания всплывающих элементов интерфейса. Он служит фундаментом для таких компонентов, как `Select`, `Combobox`, `Dropdown` и кастомных меню.

## 🏗 Архитектурная концепция

В нашей системе Popover разделен на две части:
1.  **PopoverPrimitive**: Логика позиционирования, управление состоянием (открыт/закрыт) и обработка кликов вне области.
2.  **PopoverSurface**: Визуальная оболочка (стили, тени, скругления) согласно дизайн-системе.

### Разрешено к размещению внутри:
* **Actions**: Списки кнопок и иконок.
* **Forms**: Инпуты, текстовые поля (например, настройка размеров).
* **Selectors**: Списки вариантов для выбора.
* **Information**: Контекстные подсказки и описания.

### Не рекомендуется:
* Полноценные страницы и тяжелые сценарии.
* Критические флоу (для этого используйте `Dialog`).

---

## 🚀 Использование

### Базовый пример (Custom Panel)
Используется для создания кастомных интерфейсов, как в блоке "Dimensions".

```dart
PopoverPrimitive(
  trigger: PrimaryButton(label: 'Open Dimensions'), <-- можно прокинуть controller из вне
  contentBuilder: (context) => PopoverSurface(
    child: Column(
      children: [
        Text('Dimensions', style: AppTextStyle.bold),
        AppTextField(label: 'Width'),
        AppTextField(label: 'Height'),
      ],
    ),
  ),
)
```

## Реализация Select (Composition)
Для селектов важно, чтобы ширина выпадающего списка совпадала с шириной инпута.

```
PopoverPrimitive(
  matchTriggerWidth: true, // Растягивает поповер по ширине триггера
  trigger: SelectTrigger(value: 'Option 1'),
  contentBuilder: (context) => PopoverSurface(
    child: OptionList(items: ['Option 1', 'Option 2']),
  ),
)
```

## ⚙️ Свойства (API)

```
Параметр	Тип	Описание
trigger	Widget	Элемент, при клике на который открывается поповер.
contentBuilder	WidgetBuilder	Функция, возвращающая содержимое поповера.
controller	PopoverController?	Опциональный контроллер для программного открытия/закрытия.
matchTriggerWidth	bool	Если true, ширина контента будет равна ширине триггера.
offset	Offset	Смещение относительно триггера (по умолчанию Offset(0, 4)).

```

## 🛠 Управление состоянием
Для закрытия поповера изнутри (например, после выбора элемента или нажатия кнопки "Сохранить"), используйте контроллер:

```
final controller = PopoverController();

// Внутри триггера или контента:
controller.hide(); // Закрыть
controller.show(); // Открыть
```

Можно контроллер прокинуть извне в `PopoverPrimitive`.