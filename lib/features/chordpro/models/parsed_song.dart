import 'song_section.dart';

/// The complete result of parsing a ChordPro (.cho) file.
///
/// Contains both the song's metadata (title, artist, key, etc.)
/// and its structured content as a list of [SongSection]s.
class ParsedSong {
  /// Song title from `{title:}` or `{t:}` directive.
  final String title;

  /// Artist/composer from `{artist:}` or `{subtitle:}` directive.
  final String artist;

  /// Musical key from `{key:}` directive (e.g., "Am", "D").
  final String? key;

  /// Capo position from `{capo:}` directive.
  final int? capo;

  /// Tempo from `{tempo:}` directive.
  final String? tempo;

  /// Time signature from `{time:}` directive (e.g., "4/4", "3/4").
  final String? timeSignature;

  /// Liturgical category (custom metadata, e.g., "Comunión", "Entrada").
  final String? category;

  /// The structured sections of the song.
  final List<SongSection> sections;

  /// The original raw ChordPro content.
  final String rawContent;

  const ParsedSong({
    required this.title,
    this.artist = '',
    this.key,
    this.capo,
    this.tempo,
    this.timeSignature,
    this.category,
    this.sections = const [],
    this.rawContent = '',
  });

  /// Returns a copy of this song with modified fields.
  ParsedSong copyWith({
    String? title,
    String? artist,
    String? key,
    int? capo,
    String? tempo,
    String? timeSignature,
    String? category,
    List<SongSection>? sections,
    String? rawContent,
  }) {
    return ParsedSong(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      key: key ?? this.key,
      capo: capo ?? this.capo,
      tempo: tempo ?? this.tempo,
      timeSignature: timeSignature ?? this.timeSignature,
      category: category ?? this.category,
      sections: sections ?? this.sections,
      rawContent: rawContent ?? this.rawContent,
    );
  }

  @override
  String toString() => 'ParsedSong("$title" by $artist, key: $key, '
      '${sections.length} sections)';
}
