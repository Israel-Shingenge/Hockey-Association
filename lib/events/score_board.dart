/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hockey_union/home/home_drawer.dart';

class ScoreBoardPage extends StatelessWidget {
  const ScoreBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HomeDrawer(userRole: 'Player'),
      appBar: AppBar(title: const Text("Score Board")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('Scores')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading scores"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final scores = snapshot.data!.docs;

          return ListView.builder(
            itemCount: scores.length,
            itemBuilder: (context, index) {
              final score = scores[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text("${score['team1']} vs ${score['team2']}"),
                subtitle: Text("${score['score1']} - ${score['score2']}"),
              );
            },
          );
        },
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:hockey_union/home/home_drawer.dart';

class ScoreBoardPage extends StatelessWidget {
  const ScoreBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dummyScores = [
      {'team1': 'Lions', 'team2': 'Tigers', 'score1': 3, 'score2': 2},
      {'team1': 'Sharks', 'team2': 'Wolves', 'score1': 1, 'score2': 4},
    ];

    return Scaffold(
      drawer: HomeDrawer(userRole: 'Player'),
      appBar: AppBar(title: const Text("Score Board")),
      body: ListView.builder(
        itemCount: dummyScores.length,
        itemBuilder: (context, index) {
          final score = dummyScores[index];
          return ListTile(
            leading: const Icon(Icons.sports_hockey),
            title: Text("${score['team1']} vs ${score['team2']}"),
            subtitle: Text("${score['score1']} - ${score['score2']}"),
          );
        },
      ),
    );
  }
}
