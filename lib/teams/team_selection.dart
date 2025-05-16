import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TeamSelectionPage extends StatefulWidget {
  const TeamSelectionPage({super.key});

  @override
  State<TeamSelectionPage> createState() => _TeamSelectionPageState();
}

class _TeamSelectionPageState extends State<TeamSelectionPage> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  List<DocumentSnapshot> _userTeams = [];

  Future<void> _fetchUserTeams() async {
    if (uid == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('Teams')
            .where('uid', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .get();

    setState(() {
      _userTeams = snapshot.docs;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUserTeams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a Team')),
      body:
          _userTeams.isEmpty
              ? const Center(child: Text('No teams found.'))
              : ListView.builder(
                itemCount: _userTeams.length,
                itemBuilder: (context, index) {
                  final data = _userTeams[index].data() as Map<String, dynamic>;
                  return ListTile(
                    leading: const Icon(Icons.sports_hockey),
                    title: Text(data['teamName'] ?? 'Unnamed'),
                    subtitle: Text(data['country'] ?? ''),
                    onTap: () {
                      // Navigate or store selection logic
                      Navigator.pop(context, data['teamName']);
                    },
                  );
                },
              ),
    );
  }
}
