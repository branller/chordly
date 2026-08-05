import '../models/chord.dart';
import '../models/chord_line_segment.dart';
import '../models/parsed_song.dart';
import '../models/song_section.dart';

/// Parses ChordPro (.cho) formatted text into a [ParsedSong].
///
/// Supports the following directives:
/// - Metadata: `{title:}`, `{t:}`, `{artist:}`, `{subtitle:}`, `{st:}`,
///   `{key:}`, `{capo:}`, `{tempo:}`, `{time:}`, `{category:}`
/// - Sections: `{start_of_verse}` / `{sov}`, `{start_of_chorus}` / `{soc}`,
///   `{start_of_bridge}` / `{sob}`, `{start_of_tab}` / `{sot}`
/// - Comments: `{comment:}` / `{c:}` — used as section labels
///
/// Inline chords are enclosed in square brackets: `[Am]lyrics here`.
class ChordProParser {
  const ChordProParser();

  /// Parses raw ChordPro [content] into a structured [ParsedSong].
  ParsedSong parse(String content) {
    final lines = content.split(RegExp(r'\r?\n'));

    // ── Metadata accumulators ──────────────────────────────────
    String title = 'Sin título';
    String artist = '';
    String? key;
    int? capo;
    String? tempo;
    String? timeSignature;
    String? category;

    // ── Section accumulators ───────────────────────────────────
    final List<SongSection> sections = [];
    SectionType currentSectionType = SectionType.none;
    String? currentSectionLabel;
    List<List<ChordLineSegment>> currentLines = [];

    for (final line in lines) {
      final trimmed = line.trim();

      // Skip empty lines (but preserve them as empty lines in the section)
      if (trimmed.isEmpty) {
        if (currentLines.isNotEmpty) {
          currentLines.add([]);
        }
        continue;
      }

      // ── Try to parse as a directive ───────────────────────────
      final directive = _parseDirective(trimmed);
      if (directive != null) {
        final name = directive.key.toLowerCase();
        final value = directive.value;

        switch (name) {
          // Metadata directives
          case 'title':
          case 't':
            title = value;
          case 'artist':
          case 'subtitle':
          case 'st':
            artist = value;
          case 'key':
            key = value;
          case 'capo':
            capo = int.tryParse(value);
          case 'tempo':
            tempo = value;
          case 'time':
            timeSignature = value;
          case 'category':
            category = value;

          // Section start directives
          case 'start_of_verse':
          case 'sov':
            _flushSection(sections, currentSectionType, currentSectionLabel, currentLines);
            currentSectionType = SectionType.verse;
            currentSectionLabel = value.isNotEmpty ? value : null;
            currentLines = [];
          case 'start_of_chorus':
          case 'soc':
            _flushSection(sections, currentSectionType, currentSectionLabel, currentLines);
            currentSectionType = SectionType.chorus;
            currentSectionLabel = value.isNotEmpty ? value : null;
            currentLines = [];
          case 'start_of_bridge':
          case 'sob':
            _flushSection(sections, currentSectionType, currentSectionLabel, currentLines);
            currentSectionType = SectionType.bridge;
            currentSectionLabel = value.isNotEmpty ? value : null;
            currentLines = [];
          case 'start_of_tab':
          case 'sot':
            _flushSection(sections, currentSectionType, currentSectionLabel, currentLines);
            currentSectionType = SectionType.tab;
            currentSectionLabel = value.isNotEmpty ? value : null;
            currentLines = [];

          // Section end directives
          case 'end_of_verse':
          case 'eov':
          case 'end_of_chorus':
          case 'eoc':
          case 'end_of_bridge':
          case 'eob':
          case 'end_of_tab':
          case 'eot':
            _flushSection(sections, currentSectionType, currentSectionLabel, currentLines);
            currentSectionType = SectionType.none;
            currentSectionLabel = null;
            currentLines = [];

          // Comment directive — used as section label
          case 'comment':
          case 'c':
            _flushSection(sections, currentSectionType, currentSectionLabel, currentLines);
            currentSectionType = SectionType.none;
            currentSectionLabel = value;
            currentLines = [];
        }
        continue;
      }

      // ── Parse as a lyric line with inline chords ──────────────
      final segments = _parseLyricLine(trimmed);
      currentLines.add(segments);
    }

    // Flush any remaining section
    _flushSection(sections, currentSectionType, currentSectionLabel, currentLines);

    return ParsedSong(
      title: title,
      artist: artist,
      key: key,
      capo: capo,
      tempo: tempo,
      timeSignature: timeSignature,
      category: category,
      sections: sections,
      rawContent: content,
    );
  }

  /// Attempts to parse a line as a ChordPro directive.
  ///
  /// Returns a key-value pair if successful, `null` otherwise.
  /// Handles both `{directive: value}` and `{directive}` forms.
  MapEntry<String, String>? _parseDirective(String line) {
    final regex = RegExp(r'^\{([^}:]+)(?:\s*:\s*([^}]*))?\}$');
    final match = regex.firstMatch(line);
    if (match == null) return null;

    final key = match.group(1)!.trim();
    final value = (match.group(2) ?? '').trim();
    return MapEntry(key, value);
  }

  /// Parses a lyric line containing inline chords like `[Am]text[G]more`.
  ///
  /// Returns a list of [ChordLineSegment]s.
  List<ChordLineSegment> _parseLyricLine(String line) {
    final segments = <ChordLineSegment>[];
    final regex = RegExp(r'\[([^\]]*)\]');
    int lastEnd = 0;

    for (final match in regex.allMatches(line)) {
      // Text before this chord (belongs to previous segment or standalone)
      if (match.start > lastEnd) {
        final textBefore = line.substring(lastEnd, match.start);
        if (segments.isNotEmpty) {
          // Append to previous segment's lyrics
          final prev = segments.removeLast();
          segments.add(ChordLineSegment(
            chord: prev.chord,
            lyrics: prev.lyrics + textBefore,
          ));
        } else {
          // Leading text with no chord
          segments.add(ChordLineSegment(lyrics: textBefore));
        }
      }

      // Start a new segment with this chord
      final chordStr = match.group(1)!;
      final chord = Chord.parse(chordStr);
      segments.add(ChordLineSegment(chord: chord, lyrics: ''));

      lastEnd = match.end;
    }

    // Trailing text after the last chord
    if (lastEnd < line.length) {
      final trailing = line.substring(lastEnd);
      if (segments.isNotEmpty) {
        final prev = segments.removeLast();
        segments.add(ChordLineSegment(
          chord: prev.chord,
          lyrics: prev.lyrics + trailing,
        ));
      } else {
        segments.add(ChordLineSegment(lyrics: trailing));
      }
    }

    // Edge case: line with no chords at all
    if (segments.isEmpty && line.isNotEmpty) {
      segments.add(ChordLineSegment(lyrics: line));
    }

    return segments;
  }

  /// Flushes the accumulated lines into a new [SongSection] if non-empty.
  void _flushSection(
    List<SongSection> sections,
    SectionType type,
    String? label,
    List<List<ChordLineSegment>> lines,
  ) {
    // Remove trailing empty lines
    while (lines.isNotEmpty && lines.last.isEmpty) {
      lines.removeLast();
    }

    if (lines.isNotEmpty) {
      sections.add(SongSection(
        type: type,
        label: label,
        lines: List.unmodifiable(lines),
      ));
    }
  }
}
