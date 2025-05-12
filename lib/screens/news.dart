import 'package:flutter/material.dart';

class NewsPage extends StatefulWidget {
  final String userRole; // 'player', 'manager', 'admin'

  const NewsPage({super.key, required this.userRole});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final TextEditingController messageController = TextEditingController();

  // Mock messages (replace with DB logic)
  List<Map<String, String>> newsMessages = [
    {'sender': 'Coach Joseph', 'content': 'Practice starts at 7am tomorrow.'},
    {'sender': 'Admin', 'content': 'Tournament rescheduled to June 20.'},
  ];

  void _postMessage() {
    if (messageController.text.trim().isEmpty) return;

    setState(() {
      newsMessages.insert(0, {
        'sender': 'You',
        'content': messageController.text.trim(),
      });
    });

    messageController.clear();
  }

  void _deleteMessage(int index) {
    setState(() {
      newsMessages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isManager = widget.userRole == 'manager';
    final bool isAdmin = widget.userRole == 'admin';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Image.asset('lib/images/logo.jpg', height: 50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'News & Messages',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            if (isManager)
              Column(
                children: [
                  TextField(
                    controller: messageController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Write a message to your team',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: _postMessage,
                      child: const Text('POST'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            Expanded(
              child:
                  newsMessages.isEmpty
                      ? const Center(child: Text('No messages available.'))
                      : ListView.builder(
                        itemCount: newsMessages.length,
                        itemBuilder: (context, index) {
                          final message = newsMessages[index];
                          return Card(
                            child: ListTile(
                              title: Text(message['content']!),
                              subtitle: Text('From: ${message['sender']}'),
                              trailing:
                                  (isAdmin ||
                                          (isManager &&
                                              message['sender'] == 'You'))
                                      ? IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _deleteMessage(index),
                                      )
                                      : null,
                            ),
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
