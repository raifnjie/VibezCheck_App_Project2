import 'package:flutter/material.dart';

import '../models/song.dart';
import '../services/mock_data_service.dart';

class PlaylistRoomScreen extends StatefulWidget {
  const PlaylistRoomScreen({super.key});

  @override
  State<PlaylistRoomScreen> createState() => _PlaylistRoomScreenState();
}

class _PlaylistRoomScreenState extends State<PlaylistRoomScreen> {
  late List<Song> songs;

  @override
  void initState() {
    super.initState();
    songs = List.from(MockDataService.songs);
    _sortSongs();
  }

  void _sortSongs() {
    songs.sort((a, b) => b.votes.compareTo(a.votes));
  }

  void _upvoteSong(Song song) {
    setState(() {
      song.votes++;
      _sortSongs();
    });
  }

  void _downvoteSong(Song song) {
    setState(() {
      song.votes--;
      _sortSongs();
    });
  }

  List<Song> get topRecommendations {
    final rankedSongs = List<Song>.from(songs);
    rankedSongs.sort(
      (a, b) => b.recommendationScore.compareTo(a.recommendationScore),
    );
    return rankedSongs.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = topRecommendations;

    return Scaffold(
      appBar: AppBar(title: const Text('Playlist Room')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/song-search');
              },
              child: const Text('Add Song'),
            ),
            const SizedBox(height: 16),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recommended Next Songs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

            ...recommendations.map(
              (song) => ListTile(
                title: Text('${song.title} - ${song.artist}'),
                subtitle: Text(
                  'Mood: ${song.mood} | Score: ${song.recommendationScore}',
                ),
              ),
            ),

            const Divider(height: 32),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Playlist Queue',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];

                  return Card(
                    child: ListTile(
                      title: Text('${song.title} - ${song.artist}'),
                      subtitle: Text(
                        'Votes: ${song.votes} | Mood: ${song.mood}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _upvoteSong(song),
                            icon: const Icon(Icons.thumb_up),
                          ),
                          IconButton(
                            onPressed: () => _downvoteSong(song),
                            icon: const Icon(Icons.thumb_down),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}