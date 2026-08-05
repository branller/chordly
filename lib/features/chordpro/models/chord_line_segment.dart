import 'chord.dart';

/// A segment of a lyric line: an optional [chord] positioned above [lyrics].
///
/// A full lyric line is composed of a `List<ChordLineSegment>`.
/// For example, `[C]Twinkle, [F]twinkle` becomes:
/// - `ChordLineSegment(chord: C, lyrics: 'Twinkle, ')`
/// - `ChordLineSegment(chord: F, lyrics: 'twinkle')`
class ChordLineSegment {
  /// The chord above this segment. `null` if no chord at this position.
  final Chord? chord;

  /// The lyric text for this segment. Can be empty if only a chord is present.
  final String lyrics;

  const ChordLineSegment({
    this.chord,
    this.lyrics = '',
  });

  /// Whether this segment has a chord.
  bool get hasChord => chord != null;

  /// Whether this segment has lyrics.
  bool get hasLyrics => lyrics.isNotEmpty;

  @override
  String toString() =>
      'ChordLineSegment(chord: ${chord?.display}, lyrics: "$lyrics")';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChordLineSegment &&
          chord == other.chord &&
          lyrics == other.lyrics;

  @override
  int get hashCode => Object.hash(chord, lyrics);
}
