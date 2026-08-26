import 'package:flutter/material.dart';

import 'package:chordly/features/chordpro/models/parsed_song.dart';
import 'package:chordly/features/chordpro/parser/chordpro_parser.dart';
import 'package:chordly/features/chordpro/writer/chordpro_writer.dart';
import 'package:chordly/features/songs/data/datasources/local_song_storage.dart';
import 'package:chordly/features/songs/presentation/widgets/chord_sheet.dart';

/// Screen for editing a song's ChordPro content.
///
/// Provides two tabs:
/// - **Editor**: raw ChordPro text editing
/// - **Preview**: live rendered preview using [ChordSheet]
///
/// Returns the edited [ParsedSong] via [Navigator.pop] when saved.
/// Persists changes to the original `.cho` file if [ParsedSong.filePath] is set.
class SongEditScreen extends StatefulWidget {
  final ParsedSong song;

  const SongEditScreen({super.key, required this.song});

  @override
  State<SongEditScreen> createState() => _SongEditScreenState();
}

class _SongEditScreenState extends State<SongEditScreen>
    with SingleTickerProviderStateMixin {
  static const _parser = ChordProParser();
  static const _writer = ChordProWriter();

  late final TabController _tabController;
  late final TextEditingController _textController;

  /// The parsed preview of the current editor content.
  ParsedSong? _preview;

  /// Whether the content has been modified.
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Use rawContent if available; otherwise generate from the model.
    final initialContent = widget.song.rawContent.isNotEmpty
        ? widget.song.rawContent
        : _writer.write(widget.song);

    _textController = TextEditingController(text: initialContent);
    _preview = widget.song;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  static const _storage = LocalSongStorage();

  /// Whether a save operation is in progress.
  bool _isSaving = false;

  void _onTextChanged() {
    setState(() {
      _isDirty = true;
      try {
        _preview = _parser.parse(_textController.text);
      } catch (_) {
        // Keep last valid preview on parse error.
      }
    });
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final content = _textController.text;
      final parsed = _parser.parse(content);

      String? filePath = widget.song.filePath;

      if (filePath != null) {
        // Overwrite existing file.
        await _storage.writeContent(filePath, content);
      } else {
        // Create new .cho file.
        filePath = await _storage.createSong(parsed.title, content);
      }

      if (!mounted) return;
      final result = parsed.copyWith(
        rawContent: content,
        filePath: filePath,
      );
      Navigator.of(context).pop(result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar cambios?'),
        content: const Text(
          'Tenés cambios sin guardar. ¿Querés descartarlos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );

    return shouldDiscard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Editar canción',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check_rounded),
              tooltip: 'Guardar',
              onPressed: _save,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.edit_rounded), text: 'Editor'),
              Tab(icon: Icon(Icons.visibility_rounded), text: 'Preview'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // ── Editor tab ────────────────────────────────────────
            _EditorTab(
              controller: _textController,
              onChanged: _onTextChanged,
              colorScheme: colorScheme,
            ),
            // ── Preview tab ───────────────────────────────────────
            _PreviewTab(preview: _preview),
          ],
        ),
      ),
    );
  }
}

/// The raw text editor tab.
class _EditorTab extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  final ColorScheme colorScheme;

  const _EditorTab({
    required this.controller,
    required this.onChanged,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: controller,
        onChanged: (_) => onChanged(),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          color: colorScheme.onSurface,
          height: 1.5,
        ),
        decoration: InputDecoration(
          hintText: 'Escribí el contenido ChordPro aquí...',
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: colorScheme.surfaceContainerLowest,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

/// The live preview tab using the existing [ChordSheet] widget.
class _PreviewTab extends StatelessWidget {
  final ParsedSong? preview;

  const _PreviewTab({required this.preview});

  @override
  Widget build(BuildContext context) {
    if (preview == null) {
      return const Center(
        child: Text('No se puede generar la vista previa.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ChordSheet(song: preview!),
    );
  }
}
