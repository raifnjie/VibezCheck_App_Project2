import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String defaultPlaylistId = 'default_playlist';

  Future<void> createDefaultPlaylistIfMissing() async {
    final playlistRef = _db.collection('playlists').doc(defaultPlaylistId);
    final snapshot = await playlistRef.get();

    if (!snapshot.exists) {
      await playlistRef.set({
        'name': 'Main VibezCheck Room',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<QuerySnapshot> getSongsStream() {
    return _db
        .collection('playlists')
        .doc(defaultPlaylistId)
        .collection('songs')
        .orderBy('votes', descending: true)
        .snapshots();
  }

  Future<void> addSong({
    required String title,
    required String artist,
    required String mood,
  }) async {
    await createDefaultPlaylistIfMissing();

    await _db
        .collection('playlists')
        .doc(defaultPlaylistId)
        .collection('songs')
        .add({
      'title': title,
      'artist': artist,
      'mood': mood,
      'votes': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateSongVotes({
    required String songId,
    required int currentVotes,
    required int change,
  }) async {
    await _db
        .collection('playlists')
        .doc(defaultPlaylistId)
        .collection('songs')
        .doc(songId)
        .update({
      'votes': currentVotes + change,
    });
  }

  int calculateRecommendationScore({
    required int votes,
    required String mood,
  }) {
    final moodBonus = mood == 'hype' || mood == 'chill' ? 2 : 1;
    return (votes * 2) + moodBonus;
  }
  Stream<QuerySnapshot> getMessagesStream() {
    return _db
        .collection('playlists')
        .doc(defaultPlaylistId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
    }

    Future<void> sendMessage(String text) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || text.trim().isEmpty) {
        return;
    }

    await createDefaultPlaylistIfMissing();

    await _db
        .collection('playlists')
        .doc(defaultPlaylistId)
        .collection('messages')
        .add({
        'text': text.trim(),
        'senderId': user.uid,
        'senderEmail': user.email ?? 'Unknown user',
        'timestamp': FieldValue.serverTimestamp(),
    });
    }
}