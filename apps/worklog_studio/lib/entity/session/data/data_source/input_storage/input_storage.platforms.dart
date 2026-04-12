// // text_storage_io.dart
// import 'dart:io';

// import 'package:file_picker/file_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:worklog_studio/feature/input/domain/i_input_storage.dart';

// class RawInputStorageIO implements RawInputStorage {
//   static const _pathKey = 'saved_file_path';

//   @override
//   Future<void> save(String text) async {
//     final path = await FilePicker.platform.saveFile(
//       dialogTitle: 'Сохранить текст',
//       fileName: 'note.txt',
//       type: FileType.custom,
//       allowedExtensions: ['txt'],
//     );

//     if (path == null) return;

//     final file = File(path);
//     await file.writeAsString(text);

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_pathKey, path);
//   }

//   @override
//   Future<String?> load() async {
//     final prefs = await SharedPreferences.getInstance();
//     final path = prefs.getString(_pathKey);
//     if (path == null) return null;

//     final file = File(path);
//     if (!await file.exists()) return null;

//     return file.readAsString();
//   }
// }

// RawInputStorage getRawInputStorage() => RawInputStorageIO();
