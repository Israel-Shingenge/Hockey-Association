/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamProfilePage extends StatelessWidget {
  final String teamId;

  const TeamProfilePage({super.key, required this.teamId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('Teams').doc(teamId).get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Error loading team")),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final team = snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(title: Text(team['teamName'] ?? 'Team')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Age: ${team['teamAge']}"),
                Text("Country: ${team['country']}"),
                Text("Time Zone: ${team['timeZone']}"),
                const SizedBox(height: 20),
                const Text(
                  "Players",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('Player')
                            .where('teamId', isEqualTo: teamId)
                            .snapshots(),
                    builder: (context, playerSnapshot) {
                      if (!playerSnapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      final players = playerSnapshot.data!.docs;
                      return ListView.builder(
                        itemCount: players.length,
                        itemBuilder: (context, index) {
                          final p =
                              players[index].data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text("${p['firstName']} ${p['lastName']}"),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}*/

import 'package:flutter/material.dart';

class TeamProfilePage extends StatelessWidget {
  final String teamId;

  const TeamProfilePage({super.key, required this.teamId});

  @override
  Widget build(BuildContext context) {
    // Mock data for demo purposes
    final team = {
      'teamName': 'Namibia Lions',
      'teamAge': 'U18',
      'country': 'Namibia',
      'timeZone': 'UTC+2',
      'players': [
        {'firstName': 'Paul', 'lastName': 'Kash'},
        {'firstName': 'Martin', 'lastName': 'Sinkanda'},
        {'firstName': 'Mike', 'lastName': 'Jackson'},
      ],
    };

    final List<Map<String, dynamic>> players =
        (team['players'] as List<dynamic>).cast<Map<String, dynamic>>();
    if (players.isEmpty) {
      return const Scaffold(body: Center(child: Text("No players found")));
    }

    return Scaffold(
      appBar: AppBar(title: Text(team['teamName']?.toString() ?? 'Team')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Age: ${team['teamAge']}"),
            Text("Country: ${team['country']}"),
            Text("Time Zone: ${team['timeZone']}"),
            const SizedBox(height: 20),
            const Text(
              "Players",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text("${player['firstName']} ${player['lastName']}"),
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
