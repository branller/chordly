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
}
