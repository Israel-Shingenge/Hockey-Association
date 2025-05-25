import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:hockey_union/standings/fixtures.dart'; // Make sure this path is correct for your FixturesPage
import 'package:intl/intl.dart'; // For date and time formatting

class FixturesPreviewCard extends StatelessWidget {
  const FixturesPreviewCard({super.key}); // Removed the 'fixtures' parameter

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
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
              // Removed 'Upcoming Fixtures' header and icon as HomePage provides it.
              // The entire card is now tappable to navigate to all fixtures.
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('fixtures')
                    .where('timestamp', isGreaterThanOrEqualTo: Timestamp.now())
                    .orderBy('timestamp', descending: false)
                    .limit(3) // Limit to 3 for preview
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print("Fixtures Stream Error: ${snapshot.error}");
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
                      final team1Logo = fixture['team1Logo'] ?? 'assets/images/placeholder_team_logo.png'; // Placeholder
                      final team2Logo = fixture['team2Logo'] ?? 'assets/images/placeholder_team_logo.png'; // Placeholder
                      final rawTimestamp = fixture['timestamp'];

                      DateTime fixtureDateTime;

                      if (rawTimestamp is Timestamp) {
                        fixtureDateTime = rawTimestamp.toDate();
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final tomorrow = DateTime(now.year, now.month, now.day + 1);
                        final fixtureDateOnly = DateTime(fixtureDateTime.year, fixtureDateTime.month, fixtureDateTime.day);

                        if (fixtureDateOnly == today) {
                        } else if (fixtureDateOnly == tomorrow) {
                        } else {
                        }
                      } else {
                        // Fallback if timestamp is not a Timestamp
                        final dateString = fixture['date'] ?? '';
                        final timeString = fixture['time'] ?? '';
                        try {
                           fixtureDateTime = DateFormat('yyyy-MM-dd hh:mm a').parse('$dateString $timeString');
                           final now = DateTime.now();
                           final today = DateTime(now.year, now.month, now.day);
                           final tomorrow = DateTime(now.year, now.month, now.day + 1);
                           final fixtureDateOnly = DateTime(fixtureDateTime.year, fixtureDateTime.month, fixtureDateTime.day);

                           if (fixtureDateOnly == today) {
                           } else if (fixtureDateOnly == tomorrow) {
                           } else {
                           }
                         } catch (e) {
                           print("Error parsing fixture date/time string: $e");
                         }
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0), // Increased vertical padding
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
                          children: [
                            // Team 1 Logo and Name
                            Row(
                              children: [
                                Image.asset(team1Logo, height: 30, width: 30,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.sports_hockey, size: 30, color: Colors.grey),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  team1Name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  overflow: TextOverflow.ellipsis, // Prevent overflow
                                ),
                              ],
                            ),
                            // Score (Placeholder for now)
                            const Text('vs', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            // Team 2 Logo and Name
                            Row(
                              children: [
                                Text(
                                  team2Name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  overflow: TextOverflow.ellipsis, // Prevent overflow
                                ),
                                const SizedBox(width: 8),
                                Image.asset(team2Logo, height: 30, width: 30,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.sports_hockey, size: 30, color: Colors.grey),
                                ),
                              ],
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
                  'Tap to view all fixtures >', // This text indicates the card is tappable
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