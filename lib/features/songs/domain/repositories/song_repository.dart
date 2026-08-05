/// Represents a musical chord parsed from ChordPro notation.
///
/// A chord like `Cm7/G` is decomposed into:
/// - [root] = `C`
/// - [quality] = `m7`
/// - [bass] = `G`
class Chord {
  /// The root note (e.g., `C`, `F#`, `Bb`).
  final String root;

  /// The chord quality/type (e.g., `m`, `7`, `maj7`, `dim`, `sus4`).
  /// Empty string for major chords.
  final String quality;

  /// Optional bass note for slash chords (e.g., `G` in `C/G`).
  final String? bass;

  const Chord({
    required this.root,
    this.quality = '',
    this.bass,
  });

  /// The chromatic scale using sharps.
  static const List<String> sharpNotes = [
    'C', 'C#', 'D', 'D#', 'E', 'F',
    'F#', 'G', 'G#', 'A', 'A#', 'B',
  ];

  /// The chromatic scale using flats.
  static const List<String> flatNotes = [
    'C', 'Db', 'D', 'Eb', 'E', 'F',
    'Gb', 'G', 'Ab', 'A', 'Bb', 'B',
  ];

  /// Returns the full chord string (e.g., `Cm7/G`).
  String get display {
    final buffer = StringBuffer('$root$quality');
    if (bass != null) {
      buffer.write('/$bass');
    }
    return buffer.toString();
  }

  /// Parses a chord string like `Cm7/G` into a [Chord] object.
  ///
  /// Returns `null` if the string cannot be parsed as a valid chord.
  static Chord? parse(String input) {
    if (input.isEmpty) return null;

    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    // Match: root note (with optional # or b) + quality + optional /bass
    final regex = RegExp(
      r'^([A-Ga-g][#b]?)(.*?)(?:/([A-Ga-g][#b]?))?$',
    );

    final match = regex.firstMatch(trimmed);
    if (match == null) return null;

    final root = _normalizeNote(match.group(1)!);
    final quality = match.group(2) ?? '';
    final bassRaw = match.group(3);
    final bass = bassRaw != null ? _normalizeNote(bassRaw) : null;

    return Chord(root: root, quality: quality, bass: bass);
  }

  /// Normalizes a note to have an uppercase letter (e.g., `c#` → `C#`).
  static String _normalizeNote(String note) {
    if (note.isEmpty) return note;
    return note[0].toUpperCase() + note.substring(1);
  }

  @override
  String toString() => 'Chord($display)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Chord &&
          root == other.root &&
          quality == other.quality &&
          bass == other.bass;

  @override
  int get hashCode => Object.hash(root, quality, bass);
}
