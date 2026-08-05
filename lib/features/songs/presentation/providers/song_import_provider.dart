import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chordly/features/chordpro/parser/chordpro_parser.dart';
import 'package:chordly/features/songs/data/datasources/local_song_storage.dart';
import 'package:chordly/features/songs/data/services/song_import_service.dart';

final songImportServiceProvider = Provider<SongImportService>((ref) {
  return const SongImportService(
    storage: LocalSongStorage(),
    parser: ChordProParser(),
  );
});
