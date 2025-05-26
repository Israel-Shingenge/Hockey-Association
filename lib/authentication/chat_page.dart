import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseChatPage extends StatefulWidget {
  const FirebaseChatPage({super.key});

  @override
  State<FirebaseChatPage> createState() => _FirebaseChatPageState();
}

class _FirebaseChatPageState extends State<FirebaseChatPage> {
  final TextEditingController _messageController = TextEditingController();
  bool isUserA = true;

  final userAEmail = "userA@example.com";
  final userBEmail = "userB@example.com";
  final password = "123456"; // for both users

  late String currentEmail;

  @override
  void initState() {
    super.initState();
    _loginUser(); // sign in user A by default
  }

  Future<void> _loginUser() async {
    try {
      final email = isUserA ? userAEmail : userBEmail;
      final auth = FirebaseAuth.instance;

      final users = await auth.fetchSignInMethodsForEmail(email);
      if (users.isEmpty) {
        await auth.createUserWithEmailAndPassword(email: email, password: password);
      } else {
        await auth.signInWithEmailAndPassword(email: email, password: password);
      }

      setState(() {
        currentEmail = email;
      });
    } catch (e) {
      print("Auth error: $e");
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    FirebaseFirestore.instance.collection('messages').add({
      'text': text,
      'sender': currentEmail,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  Widget _buildMessage(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final isMe = data['sender'] == currentEmail;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "${data['sender']}:\n${data['text']}",
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _switchUser() {
    setState(() {
      isUserA = !isUserA;
    });
    _loginUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase Two-Person Chat"),
        actions: [
          IconButton(
            onPressed: _switchUser,
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Switch User',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: Text(isUserA ? 'User A' : 'User B')),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    return _buildMessage(docs[index]);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Enter message",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Colors.blue,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
