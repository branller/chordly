import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalSongStorage {
  const LocalSongStorage();

  Future<Directory> _songsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();

    final songsDir = Directory('${appDir.path}/songs');

    if (!await songsDir.exists()) {
      await songsDir.create(recursive: true);
    }

    return songsDir;
  }

  Future<List<File>> getSongFiles() async {
    final directory = await _songsDirectory();

    return directory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.cho'))
        .toList();
  }

  Future<String> readSong(File file) async {
    return file.readAsString();
  }

  Future<void> saveSong(File source) async {
    final directory = await _songsDirectory();

    final fileName = source.uri.pathSegments.last;

    final destination = File('${directory.path}/$fileName');

    if (await destination.exists()) {
      throw Exception('A song with the same name already exists.');
    }

    await source.copy(destination.path);
  }

  /// Overwrites the content of an existing `.cho` file.
  Future<void> writeContent(String filePath, String content) async {
    final file = File(filePath);
    await file.writeAsString(content);
  }

  /// Creates a new `.cho` file with the given [title] and [content].
  ///
  /// Derives the filename from the title. Throws if a file with the
  /// same name already exists.
  /// Returns the absolute path of the created file.
  Future<String> createSong(String title, String content) async {
    final directory = await _songsDirectory();

    // Sanitize title into a safe filename.
    final safeName = title
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();

    final fileName = safeName.isEmpty ? 'nueva_cancion' : safeName;
    final destination = File('${directory.path}/$fileName.cho');

    if (await destination.exists()) {
      throw Exception('Ya existe una canción con ese nombre.');
    }

    await destination.writeAsString(content);
    return destination.path;
  }
}
