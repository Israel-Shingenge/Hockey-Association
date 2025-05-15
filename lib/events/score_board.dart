import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hockey_union/home/home_drawer.dart';

class ScoreBoardPage extends StatelessWidget {
  const ScoreBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HomeDrawer(),
      appBar: AppBar(title: const Text("Score Board")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('Scores')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text("Error loading scores"));
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

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
}
