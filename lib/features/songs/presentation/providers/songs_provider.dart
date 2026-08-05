import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chordly/features/chordpro/models/parsed_song.dart';
import 'package:chordly/features/songs/presentation/providers/song_repository_provider.dart';

final songsProvider = FutureProvider<List<ParsedSong>>((ref) async {
  final repository = ref.watch(songRepositoryProvider);

  return repository.getSongs();
});
