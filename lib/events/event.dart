import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hockey_union/home/home_drawer.dart';

class EventPage extends StatelessWidget {
  const EventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HomeDrawer(),
      appBar: AppBar(title: const Text("All Events")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('Game')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text("Error loading events"));
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final events = snapshot.data!.docs;

          if (events.isEmpty)
            return const Center(child: Text("No events available"));

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(event['nameOfEvent'] ?? 'Unnamed Event'),
                subtitle: Text(
                  "Date: ${event['date']} | Location: ${event['location']}",
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await snapshot.data!.docs[index].reference.delete();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
