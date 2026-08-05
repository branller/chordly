import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'package:chordly/features/chordpro/parser/chordpro_parser.dart';
import 'package:chordly/features/songs/data/datasources/local_song_storage.dart';

/// Service responsible for importing ChordPro songs into Chordly.
///
/// Responsibilities:
/// - Open the system file picker.
/// - Allow only .cho files.
/// - Validate the file by parsing it.
/// - Copy it into Chordly's local storage.
///
/// It does NOT expose UI and does NOT know about Riverpod.
class SongImportService {
  final LocalSongStorage storage;
  final ChordProParser parser;

  const SongImportService({required this.storage, required this.parser});

  /// Opens the file picker and imports a song.
  ///
  /// Returns:
  /// - true if the song was imported successfully.
  /// - false if the user cancelled.
  ///
  /// Throws an [Exception] if the selected file is invalid.
  Future<bool> importSong() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['cho'],
    );

    if (result == null) {
      return false;
    }

    final path = result.files.single.path;

    if (path == null) {
      throw Exception('Unable to access selected file.');
    }

    final file = File(path);

    final content = await file.readAsString();

    // Validate by parsing.
    parser.parse(content);

    await storage.saveSong(file);

    return true;
  }
}
