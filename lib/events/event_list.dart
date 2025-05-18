/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hockey_union/home/home_drawer.dart';

class EventsListPage extends StatelessWidget {
  const EventsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HomeDrawer(userRole: 'Player'),
      appBar: AppBar(title: const Text('Upcoming Events')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('Game')
                .orderBy('date', descending: false)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final events = snapshot.data?.docs ?? [];

          if (events.isEmpty) {
            return const Center(child: Text('No events scheduled.'));
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.event),
                title: Text(event['nameOfEvent'] ?? 'Unnamed'),
                subtitle: Text(event['date'] ?? ''),
                trailing: Text(event['location'] ?? ''),
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

class EventsListPage extends StatelessWidget {
  const EventsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HomeDrawer(userRole: 'Player'),
      appBar: AppBar(title: const Text('Upcoming Events')),
      body: ListView.builder(
        itemCount: 5, // Dummy list
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.event),
            title: Text('Event ${index + 1}'),
            subtitle: Text('2025-06-01 15:00'),
            trailing: Text('Field A'),
          );
        },
      ),
    );
  }
}
