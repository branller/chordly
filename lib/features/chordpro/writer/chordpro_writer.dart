import '../models/chord_line_segment.dart';
import '../models/parsed_song.dart';
import '../models/song_section.dart';

/// Converts a [ParsedSong] back into ChordPro (.cho) formatted text.
///
/// Reconstructs:
/// - Metadata directives (`{title:}`, `{artist:}`, `{key:}`, etc.)
/// - Section start/end directives (`{start_of_verse}` / `{end_of_verse}`, etc.)
/// - Inline chords (`[Am]lyrics here`)
class ChordProWriter {
  const ChordProWriter();

  /// Converts a [ParsedSong] into a ChordPro string.
  String write(ParsedSong song) {
    final buffer = StringBuffer();

    // ── Metadata directives ──────────────────────────────────
    buffer.writeln('{title: ${song.title}}');
    if (song.artist.isNotEmpty) {
      buffer.writeln('{artist: ${song.artist}}');
    }
    if (song.key != null) {
      buffer.writeln('{key: ${song.key}}');
    }
    if (song.capo != null) {
      buffer.writeln('{capo: ${song.capo}}');
    }
    if (song.tempo != null) {
      buffer.writeln('{tempo: ${song.tempo}}');
    }
    if (song.timeSignature != null) {
      buffer.writeln('{time: ${song.timeSignature}}');
    }
    if (song.category != null) {
      buffer.writeln('{category: ${song.category}}');
    }

    // ── Sections ─────────────────────────────────────────────
    for (final section in song.sections) {
      buffer.writeln();
      _writeSection(buffer, section);
    }

    return buffer.toString();
  }

  void _writeSection(StringBuffer buffer, SongSection section) {
    final directive = _sectionDirective(section.type);

    if (directive != null) {
      final label = section.label ?? '';
      buffer.writeln(
        label.isNotEmpty ? '{start_of_$directive: $label}' : '{start_of_$directive}',
      );
    } else if (section.label != null && section.label!.isNotEmpty) {
      buffer.writeln('{comment: ${section.label}}');
    }

    for (final line in section.lines) {
      if (line.isEmpty) {
        buffer.writeln();
      } else {
        buffer.writeln(_writeLineSegments(line));
      }
    }

    if (directive != null) {
      buffer.writeln('{end_of_$directive}');
    }
  }

  /// Converts a list of [ChordLineSegment]s back into a ChordPro line.
  String _writeLineSegments(List<ChordLineSegment> segments) {
    final buffer = StringBuffer();

    for (final segment in segments) {
      if (segment.hasChord) {
        buffer.write('[${segment.chord!.display}]');
      }
      buffer.write(segment.lyrics);
    }

    return buffer.toString();
  }

  /// Maps a [SectionType] to its ChordPro directive name.
  String? _sectionDirective(SectionType type) {
    switch (type) {
      case SectionType.verse:
        return 'verse';
      case SectionType.chorus:
        return 'chorus';
      case SectionType.bridge:
        return 'bridge';
      case SectionType.tab:
        return 'tab';
      case SectionType.none:
        return null;
    }
  }
}
