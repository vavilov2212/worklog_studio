import 'dart:js_interop';

/// JS interop для window.showDirectoryPicker
@JS('window.showDirectoryPicker')
external JSPromise? _showDirectoryPicker([JSAny? options]);

/// JS interop для window.showSaveFilePicker
@JS('window.showSaveFilePicker')
external JSPromise? _showSaveFilePicker([JSAny? options]);

@JS()
@staticInterop
class File {}

extension FileExt on File {
  external JSPromise text();
}

/// JS interop для permissions
@JS()
@staticInterop
class FileSystemHandle {}

extension FileSystemHandleExt on FileSystemHandle {
  external JSPromise queryPermission([JSAny? descriptor]);
  external JSPromise requestPermission([JSAny? descriptor]);
}

@JS()
@staticInterop
@anonymous
class GetFileHandleOptions {
  external factory GetFileHandleOptions({bool create});
}

@JS()
@staticInterop
class FileSystemDirectoryHandle extends FileSystemHandle {}

extension FileSystemDirectoryHandleExt on FileSystemDirectoryHandle {
  external JSPromise getFileHandle(String name, [JSAny? options]);
}

@JS()
@staticInterop
class FileSystemFileHandle extends FileSystemHandle {}

extension FileSystemFileHandleExt on FileSystemFileHandle {
  external JSPromise getFile();
  external JSPromise createWritable();
}

@JS()
@staticInterop
@anonymous
class PermissionDescriptor {
  external factory PermissionDescriptor({String mode});
}

@JS()
@staticInterop
@anonymous
class ShowDirectoryPickerOptions {
  external factory ShowDirectoryPickerOptions({String mode});
}

/// Обёртки в Dart для удобства

Future<JSAny> showDirectoryPicker() async {
  final jsPromise = _showDirectoryPicker(
    ShowDirectoryPickerOptions(mode: 'readwrite') as JSAny,
  )!;
  return (await jsPromise.toDart)!;
}

Future<JSAny> showSaveFilePicker() async {
  final jsPromise = _showSaveFilePicker(null)!;
  return (await jsPromise.toDart)!;
}

Future<String> requestPermission(FileSystemHandle handle) async {
  final jsPromise = handle.requestPermission(
    PermissionDescriptor(mode: 'readwrite') as JSAny,
  );
  final jsResult = await jsPromise.toDart;
  return (jsResult as JSString).toDart;
}

Future<String> queryPermission(FileSystemHandle handle) async {
  final jsPromise = handle.queryPermission(
    PermissionDescriptor(mode: 'readwrite') as JSAny,
  );
  final jsResult = await jsPromise.toDart;
  return (jsResult as JSString).toDart;
}
