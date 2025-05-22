import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';

class ManagerHome extends StatelessWidget {
  const ManagerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        backgroundColor: const Color(0xFF060f7a),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const AppLogo(size: 100),
          const SizedBox(height: 20),
          const Text(
            'Welcome Manager!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: const Text('Add/Remove Players'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.event_available),
                  title: const Text('Create Game/Event'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.bar_chart),
                  title: const Text('View Match Stats'),
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
