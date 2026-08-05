import 'package:chordly/features/chordpro/models/parsed_song.dart';
import 'package:chordly/features/songs/data/datasources/song_asset_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the list of all songs loaded from assets.
///
/// This is a [FutureProvider] because loading assets is asynchronous.
/// It caches the result so songs are only loaded once per app session.
final songsProvider = FutureProvider<List<ParsedSong>>((ref) async {
  const loader = SongAssetLoader();
  return loader.loadAll();
});
