import 'package:flutter/material.dart';
import 'package:hockey_union/events/event_location.dart';
import 'package:intl/intl.dart'; // For date formatting

class EventTeamsPage extends StatefulWidget {
  final Map<String, dynamic> event; // The event data passed from EventDetailPage

  const EventTeamsPage({super.key, required this.event});

  @override
  State<EventTeamsPage> createState() => _EventTeamsPageState();
}

class _EventTeamsPageState extends State<EventTeamsPage> {
  // Dummy data for teams. In a real app, you'd fetch this from Firebase
  // based on event['id'] and 'teams' collection.
  // I've added a 'division' field for sorting.
  final  List<Map<String, String>> _teams = [
      {
        'name': 'Wanderers',
        'division': 'Womans Division',
        'image': 'assets/images/wanderers.png', // Placeholder
      },
      {
        'name': 'Bolton',
        'division': 'Mens Division',
        'image': 'assets/images/Sparta.png', // Generic placeholder
      },
      {
        'name': 'Boca Junior',
        'division': 'Mens Division',
        'image': 'assets/images/Saints.png', // Generic placeholder
      },
      {
        'name': 'Stars',
        'division': 'Womans Division',
        'image': 'assets/images/DTS.png', // Generic placeholder
      },
    ];

  String _currentSortDivision = 'all'; // 'all', 'men', 'women'

  List<Map<String, String>> get _sortedTeams {
    if (_currentSortDivision == 'men') {
      return _teams.where((team) => team['division'] == 'Mens Division').toList();
    } else if (_currentSortDivision == 'women') {
      return _teams.where((team) => team['division'] == 'Womans Division').toList();
    }
    return _teams; // 'all' or default
  }

  @override
  Widget build(BuildContext context) {
    // Assuming event['date'] is a Timestamp from Firebase
    final DateTime eventDate = (widget.event['date'] as dynamic)?.toDate() ?? DateTime.now();

    return Scaffold(
      backgroundColor: Colors.grey[100], // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // White Card Container
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/FNB-Classic-Clashes.png', // Your logo asset
                          height: 350, // Adjust size as needed
                          fit: BoxFit.fill,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.event['nameOfEvent'] ?? 'Event Name', // Use event name
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Number of participants: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${_teams.length}', // Display current number of teams
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(), // Pushes "Location" to the right
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventLocationPage(
                                    locationName: widget.event['location'] ?? 'Windhoek',
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[700],
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),

                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            DateFormat('dd MMMM yyyy').format(eventDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(), // Pushes "Sort" to the right
                          PopupMenuButton<String>(
                            onSelected: (String result) {
                              setState(() {
                                _currentSortDivision = result;
                              });
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'all',
                                child: Text('All Divisions'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'men',
                                child: Text('Men\'s Division'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'women',
                                child: Text('Women\'s Division'),
                              ),
                            ],
                            child: Text(
                              'Sort',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[700],
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Teams',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // List of teams
                      Column(
                        children: _sortedTeams.map((team) => _buildTeamListItem(team)).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamListItem(Map<String, String> team) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
              // If you have actual team logos, use DecorationImage
              image: team['image'] != null && team['image']!.isNotEmpty
                  ? DecorationImage(
                      image: AssetImage(team['image']!),
                      fit: BoxFit.cover,
                    )
                  : null, // No image if path is null/empty
            ),
            child: team['image'] == null || team['image']!.isEmpty
                ? const Icon(Icons.group, size: 30, color: Colors.grey) // Placeholder icon
                : null, // Don't show icon if image is present
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team['name']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  team['division']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}