import 'package:flutter/material.dart';

class SongSearchScreen extends StatelessWidget {
  const SongSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final results = [
      'Mock Song A - Artist One',
      'Mock Song B - Artist Two',
      'Mock Song C - Artist Three',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Song Search')),
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
                  return Card(
                    child: ListTile(
                      title: Text(results[index]),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
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