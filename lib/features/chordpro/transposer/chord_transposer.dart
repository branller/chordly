import '../models/chord.dart';
import '../models/chord_line_segment.dart';
import '../models/parsed_song.dart';
import '../models/song_section.dart';

/// Transposes chords within a [ParsedSong] by a number of semitones.
///
/// Handles:
/// - All natural notes and accidentals (sharps and flats)
/// - Chord qualities (m, 7, maj7, dim, aug, sus, etc.)
/// - Slash chords (bass note transposition)
/// - Song key transposition
class ChordTransposer {
  const ChordTransposer();

  /// The chromatic scale — maps note names to semitone indices.
  static const Map<String, int> _noteToIndex = {
    'C': 0, 'B#': 0,
    'C#': 1, 'Db': 1,
    'D': 2,
    'D#': 3, 'Eb': 3,
    'E': 4, 'Fb': 4,
    'F': 5, 'E#': 5,
    'F#': 6, 'Gb': 6,
    'G': 7,
    'G#': 8, 'Ab': 8,
    'A': 9,
    'A#': 10, 'Bb': 10,
    'B': 11, 'Cb': 11,
  };

  /// Preferred note names when transposing up (sharps).
  static const List<String> _sharpScale = [
    'C', 'C#', 'D', 'D#', 'E', 'F',
    'F#', 'G', 'G#', 'A', 'A#', 'B',
  ];

  /// Preferred note names when transposing down (flats).
  static const List<String> _flatScale = [
    'C', 'Db', 'D', 'Eb', 'E', 'F',
    'Gb', 'G', 'Ab', 'A', 'Bb', 'B',
  ];

  /// Keys that conventionally use flats.
  static const Set<String> _flatKeys = {
    'F', 'Bb', 'Eb', 'Ab', 'Db', 'Gb',
    'Dm', 'Gm', 'Cm', 'Fm', 'Bbm', 'Ebm',
  };

  /// Transposes an entire [ParsedSong] by [semitones].
  ///
  /// Returns a new [ParsedSong] with all chords and the key transposed.
  ParsedSong transposeSong(ParsedSong song, int semitones) {
    if (semitones == 0) return song;

    final useFlats = _shouldUseFlats(song.key, semitones);

    final transposedSections = song.sections.map((section) {
      return SongSection(
        type: section.type,
        label: section.label,
        lines: section.lines.map((line) {
          return line.map((segment) {
            return _transposeSegment(segment, semitones, useFlats);
          }).toList();
        }).toList(),
      );
    }).toList();

    // Transpose the key itself
    String? newKey;
    if (song.key != null && song.key!.isNotEmpty) {
      newKey = _transposeKeyString(song.key!, semitones, useFlats);
    }

    return song.copyWith(
      key: newKey,
      sections: transposedSections,
    );
  }

  /// Transposes a single [Chord] by [semitones].
  Chord transposeChord(Chord chord, int semitones, {bool useFlats = false}) {
    final newRoot = _transposeNote(chord.root, semitones, useFlats);
    final newBass = chord.bass != null
        ? _transposeNote(chord.bass!, semitones, useFlats)
        : null;

    return Chord(root: newRoot, quality: chord.quality, bass: newBass);
  }

  /// Transposes a single note name by [semitones].
  String _transposeNote(String note, int semitones, bool useFlats) {
    final index = _noteToIndex[note];
    if (index == null) return note; // Unknown note, return unchanged

    final newIndex = (index + semitones) % 12;
    // Ensure positive modulo
    final normalizedIndex = newIndex < 0 ? newIndex + 12 : newIndex;

    return useFlats ? _flatScale[normalizedIndex] : _sharpScale[normalizedIndex];
  }

  /// Transposes a key string (e.g., "Am" → "Bbm").
  String _transposeKeyString(String keyStr, int semitones, bool useFlats) {
    // Separate the note from the quality (e.g., "Am" → "A" + "m")
    final chord = Chord.parse(keyStr);
    if (chord == null) return keyStr;

    final transposed = transposeChord(chord, semitones, useFlats: useFlats);
    return transposed.display;
  }

  /// Determines whether to use flats based on the original key and direction.
  bool _shouldUseFlats(String? key, int semitones) {
    if (key != null && _flatKeys.contains(key)) {
      return true;
    }
    // When going down, prefer flats; when going up, prefer sharps
    return semitones < 0;
  }

  /// Transposes a single [ChordLineSegment].
  ChordLineSegment _transposeSegment(
    ChordLineSegment segment,
    int semitones,
    bool useFlats,
  ) {
    if (segment.chord == null) return segment;

    return ChordLineSegment(
      chord: transposeChord(segment.chord!, semitones, useFlats: useFlats),
      lyrics: segment.lyrics,
    );
  }
}
