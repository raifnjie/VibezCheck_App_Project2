import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore_service.dart';

class PlaylistRoomScreen extends StatefulWidget {
  const PlaylistRoomScreen({super.key});

  @override
  State<PlaylistRoomScreen> createState() => _PlaylistRoomScreenState();
}

class _PlaylistRoomScreenState extends State<PlaylistRoomScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    firestoreService.createDefaultPlaylistIfMissing();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

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

  Future<void> sendChatMessage() async {
    final text = messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    await firestoreService.sendMessage(text);
    messageController.clear();
  }

  Widget buildSongsSection() {
    return StreamBuilder<QuerySnapshot>(
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

            ...recommendations.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final votes = data['votes'] ?? 0;
              final mood = data['mood'] ?? '';
              final score = firestoreService.calculateRecommendationScore(
                votes: votes,
                mood: mood,
              );

              return ListTile(
                title: Text('${data['title']} - ${data['artist']}'),
                subtitle: Text('Mood: $mood | Score: $score'),
              );
            }),

            const Divider(height: 24),

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
    );
  }

  Widget buildChatSection() {
    return Column(
      children: [
        const Divider(height: 24),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Playlist Chat',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),

        SizedBox(
          height: 120,
          child: StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getMessagesStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error loading chat: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final messages = snapshot.data?.docs ?? [];

              if (messages.isEmpty) {
                return const Center(child: Text('No messages yet.'));
              }

              return ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final data = messages[index].data() as Map<String, dynamic>;
                  final sender = data['senderEmail'] ?? 'Unknown';
                  final text = data['text'] ?? '';

                  return ListTile(
                    dense: true,
                    title: Text(text),
                    subtitle: Text(sender),
                  );
                },
              );
            },
          ),
        ),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Type a message',
                ),
              ),
            ),
            IconButton(
              onPressed: sendChatMessage,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlist Room'),
      ),
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
            const SizedBox(height: 12),
            Expanded(
              flex: 3,
              child: buildSongsSection(),
            ),
            Expanded(
              flex: 2,
              child: buildChatSection(),
            ),
          ],
        ),
      ),
    );
  }
}