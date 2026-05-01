import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isSavingToken = false;
  bool isUploadingProfileFile = false;

  String? savedTokenPreview;
  String? uploadedFileUrlPreview;

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> saveFcmToken() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('No user is signed in.');
      return;
    }

    setState(() {
      isSavingToken = true;
    });

    try {
      await FirebaseMessaging.instance.requestPermission();

      final token = await FirebaseMessaging.instance.getToken();

      if (token == null) {
        showMessage('Could not get FCM token on this device.');
      } else {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        setState(() {
          savedTokenPreview =
              token.length > 20 ? '${token.substring(0, 20)}...' : token;
        });

        showMessage('FCM token saved to Firestore.');
      }
    } catch (e) {
      showMessage('Failed to save FCM token: $e');
    }

    if (mounted) {
      setState(() {
        isSavingToken = false;
      });
    }
  }

  Future<void> uploadProfileFile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('No user is signed in.');
      return;
    }

    setState(() {
      isUploadingProfileFile = true;
    });

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_files')
          .child(user.uid)
          .child('profile_note.txt');

      final fileContent = '''
VibezCheck Profile File
User Email: ${user.email}
Uploaded At: ${DateTime.now().toIso8601String()}
Purpose: Firebase Storage demo for project submission.
''';

      await storageRef.putString(
        fileContent,
        format: PutStringFormat.raw,
        metadata: SettableMetadata(contentType: 'text/plain'),
      );

      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'profileFileUrl': downloadUrl,
        'profileFilePath': storageRef.fullPath,
        'profileFileUploadedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        uploadedFileUrlPreview = downloadUrl.length > 30
            ? '${downloadUrl.substring(0, 30)}...'
            : downloadUrl;
      });

      showMessage('Profile file uploaded to Firebase Storage.');
    } catch (e) {
      showMessage('Storage upload failed: $e');
    }

    if (mounted) {
      setState(() {
        isUploadingProfileFile = false;
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Signed in as: ${user?.email ?? 'No user'}'),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: isSavingToken ? null : saveFcmToken,
              child: Text(
                isSavingToken ? 'Saving token...' : 'Save FCM Token',
              ),
            ),

            if (savedTokenPreview != null) ...[
              const SizedBox(height: 12),
              Text('Saved token: $savedTokenPreview'),
            ],

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
              showMessage(
                'Firebase Storage requires a project plan upgrade, so upload is disabled for this demo.',
              );
            },
              child: Text(
                isUploadingProfileFile
                    ? 'Uploading profile file...'
                    : 'Upload Profile File',
              ),
            ),

            if (uploadedFileUrlPreview != null) ...[
              const SizedBox(height: 12),
              Text('Uploaded file URL: $uploadedFileUrlPreview'),
            ],

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () => logout(context),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}