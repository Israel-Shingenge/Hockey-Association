import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF060f7a),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const AppLogo(size: 100),
          const SizedBox(height: 20),
          const Text(
            'Welcome Admin!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ListTile(
                  leading: const Icon(Icons.group),
                  title: const Text('Manage Managers'),
                  onTap: () {
                    // Navigate to manager management
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.event),
                  title: const Text('View All Events'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.sports),
                  title: const Text('Manage Teams'),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
