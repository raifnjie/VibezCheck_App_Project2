import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore_service.dart';

class PlaylistRoomScreen extends StatelessWidget {
  PlaylistRoomScreen({super.key});

  final FirestoreService firestoreService = FirestoreService();

  List<QueryDocumentSnapshot> getTopRecommendations(
    List<QueryDocumentSnapshot> songs,
  ) {
    final rankedSongs = List<QueryDocumentSnapshot>.from(songs);

    rankedSongs.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;

      final aScore = firestoreService.calculateRecommendationScore(
        votes: aData['votes'] ?? 0,
        mood: aData['mood'] ?? '',
      );

      final bScore = firestoreService.calculateRecommendationScore(
        votes: bData['votes'] ?? 0,
        mood: bData['mood'] ?? '',
      );

      return bScore.compareTo(aScore);
    });

    return rankedSongs.take(3).toList();
  }

  Future<void> changeVote({
    required String songId,
    required int currentVotes,
    required int change,
  }) async {
    await firestoreService.updateSongVotes(
      songId: songId,
      currentVotes: currentVotes,
      change: change,
    );
  }

  @override
  Widget build(BuildContext context) {
    firestoreService.createDefaultPlaylistIfMissing();

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
              child: StreamBuilder<QuerySnapshot>(
                stream: firestoreService.getSongsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error loading songs: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final songs = snapshot.data?.docs ?? [];

                  if (songs.isEmpty) {
                    return const Center(
                      child: Text('No songs yet. Tap Add Song to start.'),
                    );
                  }

                  final recommendations = getTopRecommendations(songs);

                  return Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Recommended Next Songs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      ...recommendations.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final votes = data['votes'] ?? 0;
                        final mood = data['mood'] ?? '';
                        final score =
                            firestoreService.calculateRecommendationScore(
                          votes: votes,
                          mood: mood,
                        );

                        return ListTile(
                          title: Text('${data['title']} - ${data['artist']}'),
                          subtitle: Text('Mood: $mood | Score: $score'),
                        );
                      }),

                      const Divider(height: 32),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Playlist Queue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Expanded(
                        child: ListView.builder(
                          itemCount: songs.length,
                          itemBuilder: (context, index) {
                            final doc = songs[index];
                            final data = doc.data() as Map<String, dynamic>;

                            final title = data['title'] ?? 'Untitled Song';
                            final artist = data['artist'] ?? 'Unknown Artist';
                            final mood = data['mood'] ?? 'none';
                            final votes = data['votes'] ?? 0;

                            return Card(
                              child: ListTile(
                                title: Text('$title - $artist'),
                                subtitle: Text('Votes: $votes | Mood: $mood'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => changeVote(
                                        songId: doc.id,
                                        currentVotes: votes,
                                        change: 1,
                                      ),
                                      icon: const Icon(Icons.thumb_up),
                                    ),
                                    IconButton(
                                      onPressed: () => changeVote(
                                        songId: doc.id,
                                        currentVotes: votes,
                                        change: -1,
                                      ),
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