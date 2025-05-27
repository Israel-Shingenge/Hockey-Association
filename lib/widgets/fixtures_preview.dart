import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hockey_union/standings/fixtures.dart';
import 'package:intl/intl.dart'; 

class FixturesPreviewCard extends StatelessWidget {
  const FixturesPreviewCard({super.key});

  // Helper to get logo path from team name
  String _getTeamLogoPath(String teamName) {
    // Ensure the team name matches your file naming convention (e.g., "Team Name" -> "TeamName.png")
    final formattedTeamName = teamName.replaceAll(' ', '');
    return 'assets/images/$formattedTeamName.png';
  }

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
            MaterialPageRoute(builder: (context) => const FixturesPage()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Fixtures') // Ensure 'Fixtures' is correct
                    .where('timestamp', isGreaterThanOrEqualTo: Timestamp.now())
                    .orderBy('timestamp', descending: false)
                    .limit(3) // Limit to 3 for preview
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    if (kDebugMode) {
                      print("Fixtures Stream Error: ${snapshot.error}");
                    }
                    return const Text('Error loading fixtures.',
                        style: TextStyle(color: Colors.red));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No upcoming fixtures.',
                            style: TextStyle(color: Colors.grey)));
                  }

                  final fixtures = snapshot.data!.docs;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: fixtures.map((doc) {
                      final fixture = doc.data() as Map<String, dynamic>;
                      final team1Name = fixture['team1Name'] ?? 'Team 1';
                      final team2Name = fixture['team2Name'] ?? 'Team 2';
                      final rawTimestamp = fixture['timestamp'];

                      // Derive logo paths
                      final String team1LogoPath = _getTeamLogoPath(team1Name);
                      final String team2LogoPath = _getTeamLogoPath(team2Name);

                      DateTime fixtureDateTime;
                      String displayTime = 'N/A';
                      String displayDate = 'N/A';

                      if (rawTimestamp is Timestamp) {
                        fixtureDateTime = rawTimestamp.toDate();
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final tomorrow =
                            DateTime(now.year, now.month, now.day + 1);
                        final fixtureDateOnly = DateTime(
                            fixtureDateTime.year,
                            fixtureDateTime.month,
                            fixtureDateTime.day);

                        displayTime = DateFormat('hh:mm a').format(fixtureDateTime);

                        if (fixtureDateOnly == today) {
                          displayDate = 'Today';
                        } else if (fixtureDateOnly == tomorrow) {
                          displayDate = 'Tomorrow';
                        } else {
                          displayDate = DateFormat('MMM dd, yyyy').format(fixtureDateTime);
                        }
                      } else {
                        // Fallback if timestamp is not a Timestamp (though it should be)
                        final dateString = fixture['date'] ?? '';
                        final timeString = fixture['time'] ?? '';
                        try {
                          fixtureDateTime = DateFormat('yyyy-MM-dd HH:mm')
                              .parse('$dateString $timeString'); // Assuming 24-hour format
                          displayTime = DateFormat('hh:mm a').format(fixtureDateTime);
                          final now = DateTime.now();
                          final today = DateTime(now.year, now.month, now.day);
                          final tomorrow = DateTime(now.year, now.month, now.day + 1);
                          final fixtureDateOnly = DateTime(fixtureDateTime.year, fixtureDateTime.month, fixtureDateTime.day);

                          if (fixtureDateOnly == today) {
                            displayDate = 'Today';
                          } else if (fixtureDateOnly == tomorrow) {
                            displayDate = 'Tomorrow';
                          } else {
                            displayDate = DateFormat('MMM dd, yyyy').format(fixtureDateTime);
                          }
                        } catch (e) {
                          if (kDebugMode) {
                            print("Error parsing fixture date/time string: $e");
                          }
                          displayDate = 'Invalid Date';
                          displayTime = 'Invalid Time';
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Team 1 Logo and Name
                            Expanded(
                              flex: 3,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    team1LogoPath,
                                    height: 30,
                                    width: 30,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.sports_hockey,
                                            size: 30, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible( // Use Flexible to prevent overflow
                                    child: Text(
                                      team1Name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 15),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Time/Date in Middle
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  Text(displayTime, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                  Text(displayDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            // Team 2 Logo and Name
                            Expanded(
                              flex: 3,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible( // Use Flexible to prevent overflow
                                    child: Text(
                                      team2Name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 15),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Image.asset(
                                    team2LogoPath,
                                    height: 30,
                                    width: 30,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.sports_hockey,
                                            size: 30, color: Colors.grey),
                                  ),
                                ],
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
            ],
          ),
        ),
      ),
    );
  }
}