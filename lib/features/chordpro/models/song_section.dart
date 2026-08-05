import 'chord_line_segment.dart';

/// The type of section within a song.
enum SectionType {
  verse,
  chorus,
  bridge,
  tab,
  /// A section without explicit start/end markers.
  none,
}

/// A section of a song (e.g., Verse 1, Chorus) containing lyric [lines].
///
/// Each line is a `List<ChordLineSegment>` representing the chords
/// and lyrics on that line.
class SongSection {
  /// The type of this section.
  final SectionType type;

  /// An optional label (e.g., "Verse 1", "Coro").
  final String? label;

  /// The lyric lines in this section.
  /// Each line is a list of [ChordLineSegment]s.
  final List<List<ChordLineSegment>> lines;

  const SongSection({
    required this.type,
    this.label,
    this.lines = const [],
  });

  /// Human-readable display name for this section type.
  String get displayName {
    if (label != null && label!.isNotEmpty) return label!;
    switch (type) {
      case SectionType.verse:
        return 'Verso';
      case SectionType.chorus:
        return 'Coro';
      case SectionType.bridge:
        return 'Puente';
      case SectionType.tab:
        return 'Tab';
      case SectionType.none:
        return '';
    }
  }

  @override
  String toString() => 'SongSection($type, label: $label, ${lines.length} lines)';
}
