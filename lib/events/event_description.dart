import 'package:flutter/material.dart';
import 'package:hockey_union/events/event_location.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class EventTeamsPage extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventTeamsPage({super.key, required this.event});

  @override
  State<EventTeamsPage> createState() => _EventTeamsPageState();
}

class _EventTeamsPageState extends State<EventTeamsPage> {
  late List<Map<String, dynamic>> _teams;
  String _currentSortDivision = 'all';

  @override
  void initState() {
    super.initState();

    final teamsFromEvent = widget.event['teams'];
    if (teamsFromEvent != null && teamsFromEvent is List) {
      _teams = teamsFromEvent.map<Map<String, dynamic>>((team) {
        return Map<String, dynamic>.from(team);
      }).toList();
    } else {
      _teams = [];
    }
  }

  List<Map<String, dynamic>> get _sortedTeams {
    if (_currentSortDivision == 'men') {
      return _teams.where((team) => team['division'] == 'Mens Division').toList();
    } else if (_currentSortDivision == 'women') {
      return _teams.where((team) => team['division'] == 'Womans Division').toList();
    }
    return _teams;
  }

  // New method to get the stream of registration count
  Stream<int> _getRegistrationCountStream(String eventId) {
    return FirebaseFirestore.instance
        .collection('Events')
        .doc(eventId)
        .collection('registration')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    final dynamic dateRaw = widget.event['date'];
    final DateTime eventDate = dateRaw is DateTime
        ? dateRaw
        : (dateRaw?.toDate() ?? DateTime.now());

    // Get the event ID
    final String eventId = widget.event['id'];

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.event['nameOfEvent'] ?? 'Event Details',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Info Card
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200.withOpacity(0.6),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.white.withOpacity(0.8),
                    child: Icon(
                      Icons.sports_hockey,
                      size: 90,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.event['nameOfEvent'] ?? 'Event Name',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('dd MMMM yyyy').format(eventDate),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue.shade100,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // StreamBuilder for dynamic participant count
                      StreamBuilder<int>(
                        stream: _getRegistrationCountStream(eventId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ); // Show loading
                          }
                          if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.white),
                            );
                          }
                          final int participantCount = snapshot.data ?? 0;
                          return Chip(
                            backgroundColor: Colors.white70,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            avatar: Icon(Icons.group, color: Colors.blue.shade700),
                            label: Text(
                              '$participantCount Participants',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.9),
                          foregroundColor: Colors.blue.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventLocationPage(
                                locationName: widget.event['location'] ?? 'Windhoek',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.location_on_outlined),
                        label: const Text('Location'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Sort & Teams Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Teams',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.blueGrey.shade700,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (String result) {
                    setState(() {
                      _currentSortDivision = result;
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'all', child: Text('All Divisions')),
                    const PopupMenuItem(value: 'men', child: Text('Men\'s Division')),
                    const PopupMenuItem(value: 'women', child: Text('Women\'s Division')),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade300.withOpacity(0.6),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: const [
                        Text(
                          'Sort',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Teams List
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _sortedTeams.length,
              separatorBuilder: (_, __) => Divider(color: Colors.blueGrey.shade100, height: 20),
              itemBuilder: (context, index) {
                final team = _sortedTeams[index];
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // Handle team tap if needed
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              image: (team['image'] != null && (team['image'] as String).isNotEmpty)
                                  ? DecorationImage(
                                      image: AssetImage(team['image']),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: (team['image'] == null || (team['image'] as String).isEmpty)
                                ? Icon(Icons.group, size: 36, color: Colors.blueGrey.shade300)
                                : null,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  team['name'] ?? 'Unnamed',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  team['division'] ?? 'No division',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blueGrey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.blueGrey),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}