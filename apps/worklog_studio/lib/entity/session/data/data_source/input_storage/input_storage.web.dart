import 'dart:js_interop';
import 'package:worklog_studio/entity/session/data/data_source/session_handle/web/session_handle_db_web.dart';
import 'package:worklog_studio/entity/session/domain/i_input_storage.dart';
import 'package:worklog_studio/entity/session/session_handle.dart';

import 'package:worklog_studio/core/services/web/web_file_system_api.dart';

class InputStorageWeb implements InputStorage {
  final _db = SessionHandleDbWeb();

  FileSystemDirectoryHandle? _currentDirectoryHandle;

  @override
  Future<void> attachSession(String sessionId) async {
    final dirHandle = await showDirectoryPicker();
    _currentDirectoryHandle = dirHandle as FileSystemDirectoryHandle;

    await _db.save(
      SessionHandle(id: sessionId, title: sessionId, createdAt: DateTime.now()),
    );
  }

  @override
  Future<void> save(String sessionId, String text) async {
    final directoryHandle = _currentDirectoryHandle;
    if (directoryHandle == null) {
      throw Exception('Directory not selected for this session');
    }

    // Запрос прав
    final permission = await requestPermission(directoryHandle);
    if (permission != 'granted') {
      throw Exception('Write permission not granted');
    }

    // Сохранение
    final fileHandle = await showSaveFilePicker() as FileSystemFileHandle;

    final writableJs = await fileHandle.createWritable().toDart;
    final writable = writableJs as dynamic;
    await writable.write(text);
    await writable.close();
  }

  @override
  Future<String?> load(String sessionId, String fileDescriptor) async {
    final directoryHandle = _currentDirectoryHandle;
    if (directoryHandle == null) {
      throw StateError('Directory not selected for this session');
    }
    final permission = await requestPermission(directoryHandle);

    if (permission != 'granted') return null;

    final fileHandleJs = await directoryHandle
        .getFileHandle(
          fileDescriptor,
          GetFileHandleOptions(create: true) as JSAny,
        )
        .toDart;

    final fileHandle = fileHandleJs as FileSystemFileHandle;
    final file = await fileHandle.getFile().toDart;
    final text = await (file as File).text().toDart;
    return (text as JSString).toDart;
  }

  @override
  Future<bool> isSessionAvailable(String sessionId) async {
    return _currentDirectoryHandle != null;
  }
}

InputStorage getInputStorage() => InputStorageWeb();

/*
Вопрос: а почему мы вообще работает с JSAny и dynamic? нельзя ли типизироватьт конкретно?
Это относится к 43 строчке
    final writableJs = await fileHandle.createWritable().toDart;
    final writable = writableJs as dynamic;
    await writable.write(text);
    await writable.close();

Короткий ответ: можно типизировать, но только до границы, которую реально описывает Web API + dart:js_interop. Всё, что за этой границей — либо JSAny, либо dynamic. И это не из-за лени, а из-за устройства API.

Ниже — почему так происходит именно у тебя и где реально можно усилить типизацию, а где — нет.

⸻

1. Почему вообще появляется JSAny

dart:js_interop работает по очень строгому принципу:

Dart не знает реальных JS-типов во время компиляции
→ он знает только shape, который ты сам ему описал

Если JS API возвращает:

Promise<any>

то в Dart это:

JSPromise<JSAny?>

А File System Access API как раз такой:
	•	requestPermission() → Promise<"granted" | "denied" | "prompt">
	•	createWritable() → Promise<FileSystemWritableFileStream>
	•	getFile() → Promise<File>

В спецификации нет классов, есть structural types. Dart не может их вывести автоматически.

⸻

2. Почему dynamic появляется в writable / file

Пример:

final writableJs = await fileHandle.createWritable().toDart;
final writable = writableJs as dynamic;
await writable.write(text);

Почему dynamic?

Потому что:
	•	createWritable() возвращает JS-объект
	•	у него есть методы write() и close()
	•	но ты их не описал как interop-класс

Пока ты не сделал вот это ⬇️, Dart не знает, что у объекта есть write.

⸻

3. Да, можно типизировать — вот КАК ПРАВИЛЬНО

3.1 Типизируем FileSystemWritableFileStream

@JS()
@staticInterop
class FileSystemWritableFileStream {}

extension FileSystemWritableFileStreamExt
    on FileSystemWritableFileStream {
  external JSPromise write(JSAny data);
  external JSPromise close();
}

Теперь можно убрать dynamic:

final writable =
    await fileHandle.createWritable().toDart
        as FileSystemWritableFileStream;

await writable.write(text.toJS);
await writable.close();


⸻

3.2 Типизируем File

@JS()
@staticInterop
class File {}

extension FileExt on File {
  external JSPromise text();
}

Использование:

final file =
    await fileHandle.getFile().toDart as File;

final text =
    await file.text().toDart as JSString;

return text.toDart;

👉 никакого dynamic

⸻

4. Почему requestPermission возвращает JSString, а не enum

JS возвращает строку, не enum:

"granted" | "denied" | "prompt"

Dart не может автоматически сопоставить это с enum.

Правильный Dart-вариант:

enum PermissionState {
  granted,
  denied,
  prompt;

  static PermissionState fromJs(String value) =>
      PermissionState.values.firstWhere(
        (e) => e.name == value,
        orElse: () => PermissionState.denied,
      );
}

Использование:

final result =
    (await jsPromise.toDart as JSString).toDart;

return PermissionState.fromJs(result);

Теперь никаких строк в бизнес-коде.

⸻

5. Почему нельзя «просто типизировать всё»

Потому что:
	1.	Web API:
	•	не классы
	•	не sealed
	•	не гарантируют стабильную форму
	2.	dart:js_interop:
	•	не делает runtime-проверок
	•	доверяет только твоему описанию
	3.	Dart:
	•	не поддерживает structural typing
	•	только nominal typing (по имени)

Поэтому:
	•	❌ Dart не может «угадать» тип
	•	✅ ты обязан описать каждый JS-объект сам

⸻

6. Правильная архитектурная граница (важно)

Ты сейчас сделал правильно:

input_storage.web.dart
        ↓
web_file_system_api.dart   ← ВСЯ грязь тут
        ↓
JS

Именно здесь допустимы:
	•	JSAny
	•	toDart
	•	interop
	•	browser-специфика

❗️В domain / application коде этого быть не должно

⸻

Итог
	•	❓ Почему JSAny / dynamic?
→ потому что JS API возвращает any, и Dart не знает тип
	•	✅ Можно ли типизировать?
→ да, через @staticInterop + extension
	•	🎯 Что делать дальше правильно
	•	типизировать File, WritableStream, PermissionState
	•	убрать dynamic полностью
	•	оставить JSAny только внутри interop-файла

Если хочешь, следующим шагом я могу:
	•	полностью завершить типизацию web_file_system_api.dart
	•	или помочь вынести всё это за InputStorage так, чтобы web/desktop вообще не знали друг о друге.
*/
