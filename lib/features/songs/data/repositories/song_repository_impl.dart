import 'package:chordly/features/chordpro/models/parsed_song.dart';
import 'package:chordly/features/chordpro/parser/chordpro_parser.dart';
import 'package:chordly/features/songs/data/datasources/local_song_storage.dart';
import 'package:chordly/features/songs/domain/repositories/song_repository.dart';

class SongRepositoryImpl implements SongRepository {
  final LocalSongStorage storage;
  final ChordProParser parser;

  const SongRepositoryImpl({required this.storage, required this.parser});

  @override
  Future<List<ParsedSong>> getSongs() async {
    final files = await storage.getSongFiles();

    final songs = <ParsedSong>[];

    for (final file in files) {
      final content = await storage.readSong(file);

      final song = parser.parse(content);

      songs.add(song);
    }

    songs.sort((a, b) => a.title.compareTo(b.title));

    return songs;
  }
}
