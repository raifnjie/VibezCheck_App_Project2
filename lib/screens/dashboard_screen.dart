import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Widget dashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFEDE7FF),
                child: Icon(icon, color: const Color(0xFF6D5BD0)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F1B2D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6F6882),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VibezCheck'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F1B2D),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage your shared playlist room and group music activity.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6F6882),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              dashboardCard(
                icon: Icons.add_circle_outline,
                title: 'Create Playlist Room',
                subtitle: 'Start the shared VibezCheck room.',
                onTap: () {
                  Navigator.pushNamed(context, '/playlist');
                },
              ),
              const SizedBox(height: 12),
              dashboardCard(
                icon: Icons.group_add_outlined,
                title: 'Join Playlist Room',
                subtitle: 'Open the current shared playlist.',
                onTap: () {
                  Navigator.pushNamed(context, '/playlist');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}