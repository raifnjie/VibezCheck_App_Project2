import 'package:flutter/material.dart';

class PlaylistRoomScreen extends StatelessWidget {
  const PlaylistRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final songs = [
      'Song One - Artist A',
      'Song Two - Artist B',
      'Song Three - Artist C',
    ];

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
            Expanded(
              child: ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(songs[index]),
                      subtitle: const Text('Votes: 0 | Mood: chill'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.thumb_up),
                          ),
                          IconButton(
                            onPressed: () {},
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