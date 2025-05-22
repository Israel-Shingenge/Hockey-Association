import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:hockey_union/standings/fixtures.dart';
import 'package:intl/intl.dart'; // For date and time formatting

class FixturesPreviewCard extends StatelessWidget {
  const FixturesPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8), // Added margin
      child: InkWell( // Makes the entire card tappable
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FixturesPage()), // Navigate to full FixturesPage
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Upcoming Fixtures',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.event_available, color: Colors.blue[900]), // Icon
                ],
              ),
              const Divider(height: 20, thickness: 1), // Separator
              StreamBuilder<QuerySnapshot>(
                // Fetch up to 3 upcoming fixtures, ordered by timestamp
                stream: FirebaseFirestore.instance
                    .collection('fixtures')
                    .where('timestamp', isGreaterThanOrEqualTo: Timestamp.now()) // Only upcoming fixtures
                    .orderBy('timestamp', descending: false) // Order chronologically
                    .limit(3) // Limit to 3 for preview
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print("Fixtures Stream Error: ${snapshot.error}"); // Log the error
                    return const Text('Error loading fixtures.', style: TextStyle(color: Colors.red));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No upcoming fixtures.', style: TextStyle(color: Colors.grey)));
                  }

                  final fixtures = snapshot.data!.docs;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: fixtures.map((doc) {
                      final fixture = doc.data() as Map<String, dynamic>;
                      final team1Name = fixture['team1Name'] ?? 'Team 1';
                      final team2Name = fixture['team2Name'] ?? 'Team 2';
                      final rawTimestamp = fixture['timestamp']; // Get the raw timestamp

                      DateTime fixtureDateTime;
                      String formattedDate = 'N/A';
                      String formattedTime = 'N/A';

                      if (rawTimestamp is Timestamp) {
                        fixtureDateTime = rawTimestamp.toDate(); // Convert Firestore Timestamp to Dart DateTime
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final tomorrow = DateTime(now.year, now.month, now.day + 1);
                        final fixtureDateOnly = DateTime(fixtureDateTime.year, fixtureDateTime.month, fixtureDateTime.day);

                        if (fixtureDateOnly == today) {
                          formattedDate = 'Today';
                        } else if (fixtureDateOnly == tomorrow) {
                          formattedDate = 'Tomorrow';
                        } else {
                          formattedDate = DateFormat('MMM d, y').format(fixtureDateTime);
                        }
                        formattedTime = DateFormat('hh:mm a').format(fixtureDateTime); // e.g., 08:00 PM

                      } else {
                        // Fallback if timestamp is not a Timestamp (e.g., old string format)
                        // This part might not be needed if all your data is correct.
                        final dateString = fixture['date'] ?? '';
                        final timeString = fixture['time'] ?? '';
                        try {
                           fixtureDateTime = DateFormat('yyyy-MM-dd hh:mm a').parse('$dateString $timeString');
                           final now = DateTime.now();
                           final today = DateTime(now.year, now.month, now.day);
                           final tomorrow = DateTime(now.year, now.month, now.day + 1);
                           final fixtureDateOnly = DateTime(fixtureDateTime.year, fixtureDateTime.month, fixtureDateTime.day);

                           if (fixtureDateOnly == today) {
                             formattedDate = 'Today';
                           } else if (fixtureDateOnly == tomorrow) {
                             formattedDate = 'Tomorrow';
                           } else {
                             formattedDate = DateFormat('MMM d, y').format(fixtureDateTime);
                           }
                           formattedTime = DateFormat('hh:mm a').format(fixtureDateTime);
                        } catch (e) {
                          print("Error parsing fixture date/time string: $e");
                          formattedDate = fixture['date'] ?? 'N/A';
                          formattedTime = fixture['time'] ?? 'N/A';
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$formattedDate, $formattedTime: ',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700], fontSize: 14),
                            ),
                            Expanded(
                              child: Text(
                                '$team1Name vs $team2Name',
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Tap to view all fixtures >',
                  style: TextStyle(color: Colors.blue[700], fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}