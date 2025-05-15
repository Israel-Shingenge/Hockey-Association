import 'package:flutter/material.dart';

class PlayerProfilePage extends StatelessWidget {
  final String playerName;

  const PlayerProfilePage({super.key, required this.playerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Player Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 16),
            Text(
              playerName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const ListTile(
              leading: Icon(Icons.email),
              title: Text("Email: johndoe@gmail.com"),
            ),
            const ListTile(
              leading: Icon(Icons.phone),
              title: Text("Phone: +264 812345678"),
            ),
          ],
        ),
      ),
    );
  }
}
