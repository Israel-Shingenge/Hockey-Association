import 'package:flutter/material.dart';


class PlayerProfilePage extends StatelessWidget {
  final String playerName;

  const PlayerProfilePage({super.key, required this.playerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team'), // Or maybe display the team name
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              color: Colors.blue[900], // Match the top section's background
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.person, size: 40.0, color: Colors.white),
                  const SizedBox(width: 16.0),
                  Text(
                    playerName,
                    style: const TextStyle(fontSize: 24.0, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            ListTile(
              title: const Text('Date of Birth'),
              trailing: TextButton.icon(
                onPressed: () {
                  // Implement add date of birth logic
                  print('Add Date of Birth');
                },
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Gender'),
              trailing: TextButton.icon(
                onPressed: () {
                  // Implement add gender logic
                  print('Add Gender');
                },
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Contact Information',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            ListTile(
              title: const Text('johndoe@gmail.com'), // Replace with actual email
              trailing: const Icon(Icons.email_outlined),
            ),
            const SizedBox(height: 8.0),
            TextButton.icon(
              onPressed: () {
                // Implement add to contacts logic
                print('Add to Contacts');
              },
              icon: const Icon(Icons.add),
              label: const Text('Add to Contacts'),
            ),
          ],
        ),
      ),
    );
  }
}