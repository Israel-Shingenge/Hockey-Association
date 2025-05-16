import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hockey_union/home/home_drawer.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final _newsController = TextEditingController();

  Future<void> _submitNews() async {
    if (_newsController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('News').add({
        'text': _newsController.text.trim(),
        'timestamp': Timestamp.now(),
      });
      _newsController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HomeDrawer(userRole: 'Player'),
      appBar: AppBar(title: const Text("News")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _newsController,
              decoration: InputDecoration(
                labelText: "Add news...",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _submitNews,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('News')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return const Center(child: Text("Error loading news"));
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final news = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: news.length,
                  itemBuilder: (context, index) {
                    final item = news[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: const Icon(Icons.article),
                      title: Text(item['text']),
                      subtitle: Text(item['timestamp'].toDate().toString()),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
