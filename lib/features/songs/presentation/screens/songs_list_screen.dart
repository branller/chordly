import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chordly/app/app.dart';
import 'package:chordly/features/chordpro/models/parsed_song.dart';
import 'package:chordly/features/songs/presentation/providers/songs_provider.dart';
import 'package:chordly/features/songs/presentation/screens/song_detail_screen.dart';
import 'package:chordly/features/songs/presentation/widgets/import_song_button.dart';
import 'package:chordly/features/songs/presentation/widgets/song_card.dart';

/// The main screen showing all imported songs.
class SongsListScreen extends ConsumerWidget {
  const SongsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.library_music_rounded,
              color: colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text(
              'Chordly',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            tooltip: 'Cambiar tema',
            onPressed: () {
              final currentMode = ref.read(themeModeProvider);

              ref
                  .read(themeModeProvider.notifier)
                  .state = currentMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
        ],
      ),
      floatingActionButton: songsAsync.maybeWhen(
        data: (songs) => songs.isNotEmpty ? const ImportSongButton() : null,
        orElse: () => null,
      ),

      body: songsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar canciones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),

        data: (songs) => _SongsList(songs: songs),
      ),
    );
  }
}

class _SongsList extends ConsumerWidget {
  final List<ParsedSong> songs;

  const _SongsList({required this.songs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (songs.isEmpty) {
      return const _EmptySongsView();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: songs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final song = songs[index];

        return SongCard(
          song: song,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SongDetailScreen(song: song)),
            );
          },
        );
      },
    );
  }
}

class _EmptySongsView extends StatelessWidget {
  const _EmptySongsView();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_music_outlined, size: 96, color: colors.primary),
            const SizedBox(height: 24),
            Text(
              'Tu biblioteca está vacía',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Importa un archivo .cho para comenzar a crear tu cancionero.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            const ImportSongButton(extended: false),
          ],
        ),
      ),
    );
  }
}
