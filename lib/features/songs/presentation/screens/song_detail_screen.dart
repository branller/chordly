import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../chordpro/writer/chordpro_writer.dart';
import '../../../chordpro/models/parsed_song.dart';
import '../../../chordpro/transposer/chord_transposer.dart';
import '../../../../features/song_editor/presentation/screens/song_edit_screen.dart';
import '../providers/songs_provider.dart';
import '../widgets/chord_sheet.dart';
import '../../../../features/songs/data/datasources/local_song_storage.dart';

/// Detail screen for a single song with chord rendering,
/// transposition controls, and font size adjustment.
class SongDetailScreen extends ConsumerStatefulWidget {
  final ParsedSong song;

  const SongDetailScreen({super.key, required this.song});

  @override
  ConsumerState<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends ConsumerState<SongDetailScreen> {
  Future<void> _saveTransposition() async {
    if (_transpose == 0) return;
    final storage = const LocalSongStorage();
    final content = _writer.write(_displaySong);
    await storage.writeContent(_displaySong.filePath!, content);
    setState(() {
      _baseSong = _displaySong;
      _transpose = 0;
    });
    ref.invalidate(songsProvider);
  }

  static const _transposer = ChordTransposer();
  static const _writer = ChordProWriter();

  /// Current transposition in semitones (−6 to +6).
  int _transpose = 0;

  /// Current font size for the chord sheet.
  double _fontSize = 16;

  /// The transposed version of the song.
  late ParsedSong _displaySong;

  /// The base song (may be updated after editing).
  late ParsedSong _baseSong;

  @override
  void initState() {
    super.initState();
    _baseSong = widget.song;
    _displaySong = _baseSong;
  }

  void _updateTranspose(int delta) {
    setState(() {
      _transpose += delta;
      // Re-transpose from original to avoid accumulation errors
      _displaySong = _transposer.transposeSong(_baseSong, _transpose);
    });
  }

  Future<void> _openEditor() async {
    final result = await Navigator.of(context).push<ParsedSong>(
      MaterialPageRoute(builder: (_) => SongEditScreen(song: _baseSong)),
    );

    if (result != null) {
      setState(() {
        _baseSong = result;
        _transpose = 0;
        _displaySong = _baseSong;
      });
      // Refresh the song list so it reflects the changes.
      ref.invalidate(songsProvider);
    }
  }

  void _updateFontSize(double delta) {
    setState(() {
      _fontSize = (_fontSize + delta).clamp(12.0, 28.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              _baseSong.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_baseSong.artist.isNotEmpty)
              Text(
                _baseSong.artist,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Editar',
            onPressed: _openEditor,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Controls bar ─────────────────────────────────────
          _ControlsBar(
            transpose: _transpose,
            displayKey: _displaySong.key,
            originalKey: widget.song.key,
            fontSize: _fontSize,
            colorScheme: colorScheme,
            textTheme: textTheme,
            onTransposeDown: () => _updateTranspose(-1),
            onTransposeUp: () => _updateTranspose(1),
            onTransposeReset: () {
              setState(() {
                _transpose = 0;
                _displaySong = _baseSong;
              });
            },
            onFontDecrease: () => _updateFontSize(-1),
            onFontIncrease: () => _updateFontSize(1),
            onSaveTranspose: _saveTransposition,
          ),

          // ── Chord sheet ──────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ChordSheet(song: _displaySong, fontSize: _fontSize),
            ),
          ),
        ],
      ),
    );
  }
}

/// A horizontal bar with transposition and font size controls.
class _ControlsBar extends StatelessWidget {
  final int transpose;
  final String? displayKey;
  final String? originalKey;
  final double fontSize;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTransposeDown;
  final VoidCallback onTransposeUp;
  final VoidCallback onTransposeReset;
  final VoidCallback onFontDecrease;
  final VoidCallback onFontIncrease;
  final VoidCallback onSaveTranspose;

  const _ControlsBar({
    required this.transpose,
    required this.displayKey,
    required this.originalKey,
    required this.fontSize,
    required this.colorScheme,
    required this.textTheme,
    required this.onTransposeDown,
    required this.onTransposeUp,
    required this.onTransposeReset,
    required this.onFontDecrease,
    required this.onFontIncrease,
    required this.onSaveTranspose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // ── Transpose controls ────────────────────────────────
          Icon(
            Icons.swap_vert_rounded,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          _ControlButton(
            icon: Icons.remove,
            onPressed: onTransposeDown,
            colorScheme: colorScheme,
          ),
          GestureDetector(
            onTap: transpose != 0 ? onTransposeReset : null,
            child: Container(
              constraints: const BoxConstraints(minWidth: 64),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: transpose != 0
                    ? colorScheme.tertiaryContainer
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                displayKey != null
                    ? '$displayKey (${transpose >= 0 ? '+' : ''}$transpose)'
                    : '${transpose >= 0 ? '+' : ''}$transpose',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: transpose != 0
                      ? colorScheme.onTertiaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          _ControlButton(
            icon: Icons.add,
            onPressed: onTransposeUp,
            colorScheme: colorScheme,
          ),

          if (transpose != 0)
            _ControlButton(
              icon: Icons.save_rounded,
              onPressed: onSaveTranspose,
              colorScheme: colorScheme,
            ),
          const Spacer(),

          // ── Font size controls ────────────────────────────────
          Icon(
            Icons.format_size_rounded,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          _ControlButton(
            icon: Icons.text_decrease_rounded,
            onPressed: fontSize > 12 ? onFontDecrease : null,
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 4),
          _ControlButton(
            icon: Icons.text_increase_rounded,
            onPressed: fontSize < 28 ? onFontIncrease : null,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}

/// A small icon button used in the controls bar.
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final ColorScheme colorScheme;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          foregroundColor: onPressed != null
              ? colorScheme.onSurface
              : colorScheme.onSurface.withValues(alpha: 0.3),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
