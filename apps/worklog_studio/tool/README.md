Release Guide (macOS + Sparkle)

## 📌 Требования
- Установлен Flutter
- Настроен Sparkle
- Sandbox выключен в entitlements

---

## 🚀 Быстрый релиз

```bash
cd apps/worklog_studio
./tool/release.sh
```

Можно указать тип версии:
- ./tool/release.sh patch (по умолчанию)
- ./tool/release.sh minor
- ./tool/release.sh major
- ./tool/release.sh 1.2.0 (ручная версия)

Что делает скрипт:
- повышает версию в `pubspec.yaml`
- билдит macOS
- собирает DMG
- подписывает
- обновляет `release/appcast.xml`

---

## 🧠 Версионирование

Формат:

```
MAJOR.MINOR.PATCH+BUILD
```

Пример:

```
1.2.3+10
```

---

## 🔼 Как повышать версию

### PATCH (багфиксы)
```
1.0.1 → 1.0.2
```

### MINOR (новый функционал)
```
1.1.0 → 1.2.0
```

### MAJOR (breaking changes)
```
1.0.0 → 2.0.0
```

---

## ⚙️ Поведение скрипта

По умолчанию:
- увеличивает PATCH
- увеличивает BUILD

```
1.0.1+2 → 1.0.2+3
```

Тип версии можно передать аргументом:

```bash
./tool/release.sh patch
./tool/release.sh minor
./tool/release.sh major
```

Ручная установка версии:

```bash
./tool/release.sh 2.0.0
```

В этом случае build number всё равно увеличится автоматически.

---

## ✏️ Ручное изменение версии

Открой:

```
pubspec.yaml
```

И задай нужную:

```
version: 1.2.0+15
```

После этого:

```bash
./tool/release.sh
```

---

## 📦 Пути

```
build/macos/Build/Products/Release/worklog_studio.app
```

```
dmg/WorklogStudio.dmg
```

```
release/appcast.xml
```

---

## 🌐 Локальное тестирование

```bash
npx serve .
```

URL:

```
http://localhost:3000/release/appcast.xml
```

---

## ⚠️ Важно

- ❌ не использовать `file://`
- ❗ запускать приложение из `/Applications`
- ❗ всегда увеличивать BUILD

---

## 🧪 Проверка обновления

```dart
SparkleBridge.checkForUpdates();
```

---

## ✅ Чеклист

- [ ] Обновил версию
- [ ] Запустил `./tool/release.sh` (с нужным типом версии)
- [ ] Запустил сервер
- [ ] Установил в `/Applications`
- [ ] Проверил обновление