import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/import_song.dart';

class ImportSongButton extends ConsumerWidget {
  final bool extended;

  const ImportSongButton({super.key, this.extended = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (extended) {
      return FloatingActionButton.extended(
        onPressed: () => importSong(context, ref),
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Importar'),
      );
    }

    return FilledButton.icon(
      onPressed: () => importSong(context, ref),
      icon: const Icon(Icons.upload_file_rounded),
      label: const Text('Importar canción'),
    );
  }
}
