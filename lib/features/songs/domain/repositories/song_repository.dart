import 'package:chordly/features/chordpro/models/parsed_song.dart';

abstract class SongRepository {
  Future<List<ParsedSong>> getSongs();
}
