import '../models/song.dart';

class MockDataService {
  static final List<Song> songs = [
    Song(
      id: '1',
      title: 'Mock Song A',
      artist: 'Artist One',
      mood: 'chill',
      votes: 2,
    ),
    Song(
      id: '2',
      title: 'Mock Song B',
      artist: 'Artist Two',
      mood: 'hype',
      votes: 4,
    ),
    Song(
      id: '3',
      title: 'Mock Song C',
      artist: 'Artist Three',
      mood: 'focus',
      votes: 1,
    ),
  ];
}