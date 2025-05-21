import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:hockey_union/standings/standings.dart';

class StandingsPreviewCard extends StatelessWidget {
  const StandingsPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8), // Added margin for spacing
      child: InkWell( // Makes the entire card tappable
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StandingsPage()), // Navigate to full StandingsPage
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
                    'League Standings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.table_chart, color: Colors.blue[900]), // Icon for visual flair
                ],
              ),
              const Divider(height: 20, thickness: 1), // Separator
              // Table header for preview
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: const [
                    SizedBox(width: 15), // For rank number
                    Expanded(child: Text('Team', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    Text('P', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), // Points
                    SizedBox(width: 10),
                    Text('GP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), // Games Played
                    // If you add goalDifference to your JSON, uncomment below:
                    // SizedBox(width: 10),
                    // Text('GD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), // Goal Difference
                  ],
                ),
              ),
              // StreamBuilder to fetch real standings data
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Standings') // Your standings collection name
                    // .where('leagueId', isEqualTo: 'your_league_id') // Uncomment and set if you filter by league
                    .orderBy('points', descending: true) // Order by points descending
                    // If you add goalDifference to your JSON and want to use it for tie-breaking:
                    // .orderBy('goalDifference', descending: true)
                    .limit(3) // Get top 3 teams
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No standings data available.', style: TextStyle(color: Colors.grey)));
                  }

                  final standingsDocs = snapshot.data!.docs;

                  return Column(
                    children: List.generate(standingsDocs.length, (index) {
                      final data = standingsDocs[index].data() as Map<String, dynamic>;
                      final clubName = data['clubName'] ?? 'N/A'; // Use 'clubName'
                      final points = data['points']?.toString() ?? '0';
                      final gamesPlayed = data['gamesPlayed']?.toString() ?? '0';
                      // final goalDifference = data['goalDifference']?.toString() ?? '0'; // Uncomment if using GD

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            SizedBox(
                                width: 15,
                                child: Text('${index + 1}.', style: TextStyle(color: Colors.blue[700]))), // Rank
                            Expanded(child: Text(clubName)),
                            Text(points),
                            SizedBox(width: 10),
                            Text(gamesPlayed),
                            // If you add goalDifference to your JSON, uncomment below:
                            // SizedBox(width: 10),
                            // Text(goalDifference),
                          ],
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Tap to view all standings >',
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