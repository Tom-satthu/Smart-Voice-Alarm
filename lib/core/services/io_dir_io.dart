import 'dart:io';

Future<void> ensureDirectoryExists(String path) async {
  final dir = Directory(path);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
}

Future<bool> fileExists(String path) async {
  try {
    return await File(path).exists();
  } catch (_) {
    return false;
  }
}

Future<int> fileLength(String path) async {
  try {
    return await File(path).length();
  } catch (_) {
    return 0;
  }
}

Future<void> deleteFileIfExists(String path) async {
  try {
    final file = File(path);
    if (await file.exists()) await file.delete();
  } catch (_) {}
}

Future<void> writeBytes(String path, List<int> bytes) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes, flush: true);
}
