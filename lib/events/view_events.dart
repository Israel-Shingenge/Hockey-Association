import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hockey_union/home/home_drawer.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({super.key});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool _showRegistrationPopup = false;
  Map<String, dynamic>? selectedEvent;
  String _currentView = 'all'; // 'all' or 'my'

  // Simulated current user info; replace with your auth system's current user id/email
  final String userId = 'CURRENT_USER_ID';
  final String userEmail = 'user@example.com';

  void _toggleRegistrationPopup(Map<String, dynamic> event) {
    setState(() {
      selectedEvent = event;
      _showRegistrationPopup = !_showRegistrationPopup;
    });
  }

  Future<void> _registerForEvent(String eventId) async {
    final regRef = FirebaseFirestore.instance
        .collection('Events')
        .doc(eventId)
        .collection('registration')
        .doc(userId);

    await regRef.set({
      'userID': userId,
      'email': userEmail,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _showRegistrationPopup = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Successfully registered for event')),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final Timestamp timestamp = event['date'];
    final DateTime eventDate = timestamp.toDate();

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('d').format(eventDate),
                    style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat('E').format(eventDate),
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('HH:mm (zzz)').format(eventDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(event['nameOfEvent'] ?? 'Untitled'),
                  Text(event['location'] ?? 'No location'),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _toggleRegistrationPopup(event),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllEventsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Events').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Error loading events'));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        final events = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();

        if (events.isEmpty) {
          return const Center(child: Text('No events available.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) => _buildEventCard(events[index]),
        );
      },
    );
  }

  Widget _buildMyEventsList() {
  return FutureBuilder<QuerySnapshot>(
    future: FirebaseFirestore.instance.collection('Events').get(),
    builder: (context, allEventsSnapshot) {
      if (allEventsSnapshot.hasError) {
        return const Center(child: Text('Error loading events'));
      }
      if (allEventsSnapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      final allEvents = allEventsSnapshot.data!.docs;

      return FutureBuilder<List<Map<String, dynamic>?>>(
        future: Future.wait(allEvents.map((eventDoc) async {
          final regDoc = await FirebaseFirestore.instance
              .collection('Events')
              .doc(eventDoc.id)
              .collection('registration')
              .doc(userId)
              .get();

          if (regDoc.exists) {
            final eventData = eventDoc.data()! as Map<String, dynamic>;
            eventData['id'] = eventDoc.id;
            return eventData;
          }
          return null;
        }).toList()),
        builder: (context, regEventsSnapshot) {
          if (regEventsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (regEventsSnapshot.hasError) {
            return const Center(child: Text('Error loading registered events'));
          }

          // Filter out nulls here
          final registeredEvents = regEventsSnapshot.data!.whereType<Map<String, dynamic>>().toList();

          if (registeredEvents.isEmpty) {
            return const Center(child: Text('You have not registered for any events.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: registeredEvents.length,
            itemBuilder: (context, index) => _buildEventCard(registeredEvents[index]),
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        },
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () => setState(() => _currentView = 'all'),
            child: Text(
              'All events',
              style: TextStyle(
                color: _currentView == 'all' ? Colors.white : Colors.white70,
                fontWeight: _currentView == 'all' ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () => setState(() => _currentView = 'my'),
            child: Text(
              'My events',
              style: TextStyle(
                color: _currentView == 'my' ? Colors.white : Colors.white70,
                fontWeight: _currentView == 'my' ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
      centerTitle: true,
      backgroundColor: Colors.blue[900],
    ),
    drawer: const HomeDrawer(),
      body: Stack(
        children: [
          _currentView == 'all' ? _buildAllEventsList() : _buildMyEventsList(),
          if (_showRegistrationPopup && selectedEvent != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _showRegistrationPopup = false),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Event Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Text('Name: ${selectedEvent!['nameOfEvent'] ?? 'N/A'}'),
                          Text('Location: ${selectedEvent!['location'] ?? 'N/A'}'),
                          Text('Date: ${DateFormat('yyyy-MM-dd – kk:mm').format((selectedEvent!['date'] as Timestamp).toDate())}'),
                          Text('Volunteers: ${selectedEvent!['volunteers'] ?? 'N/A'}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _registerForEvent(selectedEvent!['id']),
                            child: const Text('Register for this event'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => setState(() => _showRegistrationPopup = false),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
