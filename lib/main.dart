import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/playlist_room_screen.dart';
import 'screens/song_search_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const VibezCheckApp());
}

class VibezCheckApp extends StatelessWidget {
  const VibezCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VibezCheck',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/playlist': (context) => const PlaylistRoomScreen(),
        '/song-search': (context) => const SongSearchScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}