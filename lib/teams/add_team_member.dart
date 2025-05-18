/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTeamMemberPage extends StatefulWidget {
  final String teamId;
  const AddTeamMemberPage({super.key, required this.teamId});

  @override
  State<AddTeamMemberPage> createState() => _AddTeamMemberPageState();
}

class _AddTeamMemberPageState extends State<AddTeamMemberPage> {
  final _emailController = TextEditingController();

  Future<void> _sendInvite() async {
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      await FirebaseFirestore.instance.collection('TeamInvites').add({
        'teamId': widget.teamId,
        'email': email,
        'status': 'pending',
        'sentAt': Timestamp.now(),
      });
      _emailController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invite sent!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Invite Player")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Player Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _sendInvite,
              child: const Text("Send Invite"),
            ),
          ],
        ),
      ),
    );
  }
}*/

import 'package:flutter/material.dart';

class AddTeamMemberPage extends StatefulWidget {
  final String teamId;
  const AddTeamMemberPage({super.key, required this.teamId});

  @override
  State<AddTeamMemberPage> createState() => _AddTeamMemberPageState();
}

class _AddTeamMemberPageState extends State<AddTeamMemberPage> {
  final _emailController = TextEditingController();

  void _sendInviteMock() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      _emailController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invite for "$email" sent (mocked).')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Invite Player")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Player Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _sendInviteMock,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF060F7A),
              ),
              child: const Text(
                "Send Invite",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
