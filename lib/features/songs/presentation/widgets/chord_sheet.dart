import 'package:flutter/material.dart';

import '../../../chordpro/models/chord_line_segment.dart';
import '../../../chordpro/models/parsed_song.dart';
import '../../../chordpro/models/song_section.dart';

/// Renders a [ParsedSong] as a chord sheet with chords above lyrics.
///
/// Sections are visually distinguished with labels and subtle backgrounds.
/// The [fontSize] controls the base text size.
class ChordSheet extends StatelessWidget {
  final ParsedSong song;
  final double fontSize;

  const ChordSheet({
    super.key,
    required this.song,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < song.sections.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          _buildSection(context, song.sections[i], colorScheme),
        ],
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    SongSection section,
    ColorScheme colorScheme,
  ) {
    final isChorus = section.type == SectionType.chorus;
    final sectionLabel = section.displayName;

    return Container(
      width: double.infinity,
      decoration: isChorus
          ? BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color: colorScheme.primary,
                  width: 3,
                ),
              ),
            )
          : null,
      padding: isChorus
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section label ──────────────────────────────────────
          if (sectionLabel.isNotEmpty) ...[
            Text(
              sectionLabel,
              style: TextStyle(
                fontSize: fontSize * 0.8,
                fontWeight: FontWeight.w700,
                color: isChorus
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
          ],
          // ── Lines ──────────────────────────────────────────────
          for (final line in section.lines) ...[
            if (line.isEmpty)
              const SizedBox(height: 8) // Empty line = spacing
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: _buildLine(context, line, colorScheme),
              ),
          ],
        ],
      ),
    );
  }

  /// Builds a single lyric line with chords above.
  ///
  /// Uses a [Wrap] of chord-lyric pairs where each segment shows
  /// the chord (if present) above its lyrics.
  Widget _buildLine(
    BuildContext context,
    List<ChordLineSegment> segments,
    ColorScheme colorScheme,
  ) {
    return Wrap(
      children: segments.map((segment) {
        return _buildSegment(segment, colorScheme);
      }).toList(),
    );
  }

  /// Builds a single chord-lyric segment as a vertical pair.
  Widget _buildSegment(ChordLineSegment segment, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Chord ───────────────────────────────────────────────
        Text(
          segment.hasChord ? segment.chord!.display : ' ',
          style: TextStyle(
            fontSize: fontSize * 0.85,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
            height: 1.3,
          ),
        ),
        // ── Lyrics ──────────────────────────────────────────────
        Text(
          segment.lyrics.isEmpty ? ' ' : segment.lyrics,
          style: TextStyle(
            fontSize: fontSize,
            color: colorScheme.onSurface,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
