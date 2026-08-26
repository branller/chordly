import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chordly/features/songs/presentation/providers/song_import_provider.dart';
import 'package:chordly/features/songs/presentation/providers/songs_provider.dart';

Future<void> importSong(BuildContext context, WidgetRef ref) async {
  try {
    final importer = ref.read(songImportServiceProvider);

    final imported = await importer.importSong();

    if (!context.mounted) return;

    if (imported) {
      ref.invalidate(songsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Canción importada correctamente')),
      );
    }
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(e.toString())));
  }
}
