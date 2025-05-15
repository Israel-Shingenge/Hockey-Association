/*import 'package:cloud_firestore/cloud_firestore.dart';
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
}*/

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hockey_union/home/home_drawer.dart';
import 'package:hockey_union/home/home_drawer.dart';

class EventDetailsPage extends StatelessWidget {
  final String eventId;

  const EventDetailsPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HomeDrawer(),
      appBar: AppBar(title: const Text('Event Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('Game').doc(eventId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final event = snapshot.data?.data() as Map<String, dynamic>?;

          if (event == null) {
            return const Center(child: Text('Event not found.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text(
                  event['nameOfEvent'] ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Date: ${event['date'] ?? ''}'),
                Text('Time Zone: ${event['timeZone'] ?? ''}'),
                Text('Location: ${event['location'] ?? ''}'),
                Text('Duration: ${event['duration'] ?? ''}'),
                const SizedBox(height: 12),
                Text('Notes: ${event['notes'] ?? 'None'}'),
                Text('Volunteer: ${event['volunteerAssignments'] ?? 'None'}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
