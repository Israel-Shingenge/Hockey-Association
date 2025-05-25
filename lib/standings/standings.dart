import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hockey_union/home/home_drawer.dart'; // Assuming you have a HomeDrawer

class StandingsPage extends StatefulWidget {
  const StandingsPage({super.key});

  @override
  _StandingsPageState createState() => _StandingsPageState();
}

class _StandingsPageState extends State<StandingsPage> {
  // Collection reference pointing to your 'standings' collection
  final CollectionReference _standings = FirebaseFirestore.instance.collection('Standings');

  // Function to update a specific field for a team in the standings
  Future<void> _updateTeamField(String docId, String field, dynamic value) async {
    await _standings.doc(docId).update({field: value});
  }

  // Dialog to add a new team to the standings
  Future<void> _addTeamDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController pointsController = TextEditingController(text: '0');
    final TextEditingController winsController = TextEditingController(text: '0');
    final TextEditingController lossesController = TextEditingController(text: '0');
    final TextEditingController drawsController = TextEditingController(text: '0');
    final TextEditingController gamesPlayedController = TextEditingController(text: '0');
    final TextEditingController goalsForController = TextEditingController(text: '0');
    final TextEditingController goalsAgainstController = TextEditingController(text: '0');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Team'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Team Name')),
              TextField(controller: pointsController, decoration: const InputDecoration(labelText: 'Points'), keyboardType: TextInputType.number),
              TextField(controller: winsController, decoration: const InputDecoration(labelText: 'Wins'), keyboardType: TextInputType.number),
              TextField(controller: lossesController, decoration: const InputDecoration(labelText: 'Losses'), keyboardType: TextInputType.number),
              TextField(controller: drawsController, decoration: const InputDecoration(labelText: 'Draws'), keyboardType: TextInputType.number),
              TextField(controller: gamesPlayedController, decoration: const InputDecoration(labelText: 'Games Played'), keyboardType: TextInputType.number),
              TextField(controller: goalsForController, decoration: const InputDecoration(labelText: 'Goals For'), keyboardType: TextInputType.number),
              TextField(controller: goalsAgainstController, decoration: const InputDecoration(labelText: 'Goals Against'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _standings.add({
                'clubName': nameController.text, // Ensure this matches your JSON field name
                'points': int.tryParse(pointsController.text) ?? 0,
                'wins': int.tryParse(winsController.text) ?? 0,
                'losses': int.tryParse(lossesController.text) ?? 0,
                'draws': int.tryParse(drawsController.text) ?? 0,
                'gamesPlayed': int.tryParse(gamesPlayedController.text) ?? 0,
                'goalsFor': int.tryParse(goalsForController.text) ?? 0,
                'goalsAgainst': int.tryParse(goalsAgainstController.text) ?? 0,
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Widget to build an editable number field for standings stats
  Widget _buildNumberEditableField(String docId, String field, int value, {bool isPoints = false}) {
    return SizedBox(
      width: 50, // Adjust width as needed for proper alignment
      child: TextFormField(
        initialValue: value.toString(),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        onFieldSubmitted: (val) {
          int parsed = int.tryParse(val) ?? 0;
          _updateTeamField(docId, field, parsed);
          FocusScope.of(context).unfocus(); // Dismiss keyboard on submit
        },
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 4.0),
          border: InputBorder.none, // Remove the default underline
          focusedBorder: UnderlineInputBorder( // Show a subtle underline when focused
            borderSide: BorderSide(color: Colors.blue, width: 1.0),
          ),
          enabledBorder: InputBorder.none, // No border when not focused
        ),
        style: TextStyle(
          fontWeight: isPoints ? FontWeight.bold : FontWeight.normal,
          color: isPoints ? Colors.blue[800] : Colors.black87,
          fontSize: 14.0, // Consistent font size
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The leading icon (drawer)
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white), // Drawer button is white
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: const Text('Standings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        elevation: 0, // Flat app bar look.
        actions: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white), // Back button is white
            onPressed: () {
              Navigator.pop(context); // Navigates back to the previous screen
            },
          ),
          const SizedBox(width: 8), // Padding on the right
        ],
      ),
      drawer: const HomeDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        // Order by 'points' descending, then by 'goalsFor' descending for tie-breaking
        stream: _standings.orderBy('points', descending: true).orderBy('goalsFor', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Firestore Error: ${snapshot.error}");
            return const Center(child: Text('Error loading data', style: TextStyle(color: Colors.red)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.leaderboard, size: 80, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text('No teams in standings yet.', style: TextStyle(color: Colors.grey, fontSize: 18, fontStyle: FontStyle.italic)),
                  const Text('Tap the "+" button to add one!', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            );
          }

          final teams = snapshot.data!.docs;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card( // Wrap the entire table in a Card
              elevation: 4.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              clipBehavior: Clip.antiAlias, // Ensures content respects rounded corners
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Standings Header Row
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[800], // Dark blue background for header
                      // Only apply top rounded corners for the header
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(0.7), // Rank
                        1: FlexColumnWidth(3), // Team Name
                        2: FlexColumnWidth(1), // GP
                        3: FlexColumnWidth(1), // W
                        4: FlexColumnWidth(1), // L
                        5: FlexColumnWidth(1), // D
                        6: FlexColumnWidth(1), // GF
                        7: FlexColumnWidth(1), // GA
                        8: FlexColumnWidth(1.2), // Pts (slightly wider for prominence)
                      },
                      children: const [
                        TableRow(
                          children: [
                            TableCell(child: Center(child: Text('Rank', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)))),
                            TableCell(child: Center(child: Text('Team', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)))),
                            TableCell(child: Center(child: Text('GP', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)))),
                            TableCell(child: Center(child: Text('W', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)))),
                            TableCell(child: Center(child: Text('L', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)))),
                            TableCell(child: Center(child: Text('D', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)))),
                            TableCell(child: Center(child: Text('GF', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)))),
                            TableCell(child: Center(child: Text('GA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)))),
                            TableCell(child: Center(child: Text('Pts', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Standings List (Data Rows)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // Prevent nested scrolling
                    itemCount: teams.length,
                    itemBuilder: (context, index) {
                      final team = teams[index];
                      final id = team.id; // Document ID
                      final data = team.data() as Map<String, dynamic>;

                      // Retrieve data with null checks and default values
                      final String clubName = data['clubName'] ?? 'Unknown Team';
                      final int points = data['points'] ?? 0;
                      final int wins = data['wins'] ?? 0;
                      final int losses = data['losses'] ?? 0;
                      final int draws = data['draws'] ?? 0;
                      final int gamesPlayed = data['gamesPlayed'] ?? (wins + losses + draws); // Calculate if not present
                      final int goalsFor = data['goalsFor'] ?? 0;
                      final int goalsAgainst = data['goalsAgainst'] ?? 0;

                      final Color rowColor = index % 2 == 0 ? Colors.white : Colors.blue[50]!; // Alternate row colors
                      final int rank = index + 1; // Calculate rank based on sorted order

                      return Container(
                        color: rowColor, // Apply alternating background color
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(0.7), // Rank
                            1: FlexColumnWidth(3), // Team Name
                            2: FlexColumnWidth(1), // GP
                            3: FlexColumnWidth(1), // W
                            4: FlexColumnWidth(1), // L
                            5: FlexColumnWidth(1), // D
                            6: FlexColumnWidth(1), // GF
                            7: FlexColumnWidth(1), // GA
                            8: FlexColumnWidth(1.2), // Pts
                          },
                          children: [
                            TableRow(
                              children: [
                                TableCell(child: Center(child: Text('$rank', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 14)))),
                                // Team Name
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4.0), // Slight padding for text
                                    child: Text(
                                      clubName,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey[800], fontSize: 14),
                                    ),
                                  ),
                                ),
                                // Editable Fields
                                TableCell(child: _buildNumberEditableField(id, 'gamesPlayed', gamesPlayed)),
                                TableCell(child: _buildNumberEditableField(id, 'wins', wins)),
                                TableCell(child: _buildNumberEditableField(id, 'losses', losses)),
                                TableCell(child: _buildNumberEditableField(id, 'draws', draws)),
                                TableCell(child: _buildNumberEditableField(id, 'goalsFor', goalsFor)),
                                TableCell(child: _buildNumberEditableField(id, 'goalsAgainst', goalsAgainst)),
                                TableCell(child: _buildNumberEditableField(id, 'points', points, isPoints: true)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTeamDialog(context),
        backgroundColor: Colors.blue[700], // Consistent blue color
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}