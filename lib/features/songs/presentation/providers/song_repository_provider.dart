import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chordly/features/chordpro/parser/chordpro_parser.dart';
import 'package:chordly/features/songs/data/datasources/local_song_storage.dart';
import 'package:chordly/features/songs/data/repositories/song_repository_impl.dart';
import 'package:chordly/features/songs/domain/repositories/song_repository.dart';

final songRepositoryProvider = Provider<SongRepository>((ref) {
  return const SongRepositoryImpl(
    storage: LocalSongStorage(),
    parser: ChordProParser(),
  );
});
