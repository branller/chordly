import 'package:flutter/services.dart' show rootBundle;
import 'package:chordly/features/chordpro/parser/chordpro_parser.dart';
import 'package:chordly/features/chordpro/models/parsed_song.dart';

/// Loads ChordPro (.cho) song files bundled as Flutter assets.
///
/// In the current phase, this is the sole data source. When Drift is
/// added, this class will be reused as the initial seed loader that
/// populates the database on first launch.
class SongAssetLoader {
  const SongAssetLoader();

  static const _parser = ChordProParser();

  /// The manifest of bundled song asset paths.
  ///
  /// Flutter doesn't provide a way to list asset directory contents at
  /// runtime, so we maintain an explicit list. When adding new .cho files,
  /// add their asset path here.
  static const List<String> _songAssets = [
    'assets/songs/santo_santo_santo.cho',
    'assets/songs/cordero_de_dios.cho',
    'assets/songs/pescador_de_hombres.cho',
    'assets/songs/alma_misionera.cho',
    'assets/songs/juntos_como_hermanos.cho',
  ];

  /// Loads and parses all bundled songs.
  ///
  /// Returns a list of [ParsedSong] sorted alphabetically by title.
  Future<List<ParsedSong>> loadAll() async {
    final songs = <ParsedSong>[];

    for (final assetPath in _songAssets) {
      try {
        final content = await rootBundle.loadString(assetPath);
        final parsed = _parser.parse(content);
        songs.add(parsed);
      } catch (e) {
        // Skip files that fail to load — don't crash the app
        // In production, we'd log this error
        continue;
      }
    }

    songs.sort((a, b) => a.title.compareTo(b.title));
    return songs;
  }
}
