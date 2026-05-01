import 'package:flutter/material.dart';

import '../services/firestore_service.dart';

class SongSearchScreen extends StatelessWidget {
  SongSearchScreen({super.key});

  final FirestoreService firestoreService = FirestoreService();

  final List<Map<String, String>> results = const [
    {
      'title': 'Mock Song A',
      'artist': 'Artist One',
      'mood': 'chill',
    },
    {
      'title': 'Mock Song B',
      'artist': 'Artist Two',
      'mood': 'hype',
    },
    {
      'title': 'Mock Song C',
      'artist': 'Artist Three',
      'mood': 'focus',
    },
    {
      'title': 'Mock Song D',
      'artist': 'Artist Four',
      'mood': 'party',
    },
    {
      'title': 'Mock Song E',
      'artist': 'Artist Five',
      'mood': 'study',
    },
  ];

  Future<void> addSong(BuildContext context, Map<String, String> song) async {
    await firestoreService.addSong(
      title: song['title']!,
      artist: song['artist']!,
      mood: song['mood']!,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${song['title']} added to playlist')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Song Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Search for a song',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final song = results[index];

                  return Card(
                    child: ListTile(
                      title: Text('${song['title']} - ${song['artist']}'),
                      subtitle: Text('Mood: ${song['mood']}'),
                      trailing: ElevatedButton(
                        onPressed: () => addSong(context, song),
                        child: const Text('Add'),
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