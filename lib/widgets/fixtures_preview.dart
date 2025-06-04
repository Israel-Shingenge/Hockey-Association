import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hockey_union/standings/fixtures.dart';
import 'package:intl/intl.dart';

class FixturesPreviewCard extends StatelessWidget {
  const FixturesPreviewCard({super.key});

  String _getTeamLogoPath(String teamName) {
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
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Fixtures')
                    .where('timestamp', isGreaterThanOrEqualTo: Timestamp.now())
                    .orderBy('timestamp', descending: false)
                    .limit(3)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    if (kDebugMode) {
                      print("Fixtures Stream Error: ${snapshot.error}");
                    }
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                          child: Text('Error loading fixtures. Please try again later.',
                              style: TextStyle(color: Colors.red))),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event_busy_outlined, 
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No upcoming games scheduled.',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Check back soon for new matchups!',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
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
                        final dateString = fixture['date'] ?? '';
                        final timeString = fixture['time'] ?? '';
                        try {
                          fixtureDateTime = DateFormat('yyyy-MM-dd HH:mm')
                              .parse('$dateString $timeString');
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
                                  Flexible(
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
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  Text(displayTime, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                  Text(displayDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible(
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