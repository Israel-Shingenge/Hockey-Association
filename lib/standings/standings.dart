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
  Widget _buildNumberEditableField(String docId, String field, int value) {
    return SizedBox(
      width: 50, // Adjust width as needed for proper alignment
      child: TextFormField(
        initialValue: value.toString(),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        onFieldSubmitted: (val) {
          int parsed = int.tryParse(val) ?? 0;
          _updateTeamField(docId, field, parsed);
        },
        decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 4.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Standings', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
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
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No teams found. Add some teams!', style: TextStyle(color: Colors.grey)));
          }

          final teams = snapshot.data!.docs;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Standings Header Row
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(3), // Team Name
                    1: FlexColumnWidth(1), // GP
                    2: FlexColumnWidth(1), // W
                    3: FlexColumnWidth(1), // L
                    4: FlexColumnWidth(1), // T
                    5: FlexColumnWidth(1), // GF
                    6: FlexColumnWidth(1), // GA
                    8: FlexColumnWidth(1), // Pts
                  },
                  children: const [
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text('Team', style: TextStyle(fontWeight: FontWeight.bold)))),
                        TableCell(child: Center(child: Text('GP', style: TextStyle(fontWeight: FontWeight.bold)))),
                        TableCell(child: Center(child: Text('W', style: TextStyle(fontWeight: FontWeight.bold)))),
                        TableCell(child: Center(child: Text('L', style: TextStyle(fontWeight: FontWeight.bold)))),
                        TableCell(child: Center(child: Text('D', style: TextStyle(fontWeight: FontWeight.bold)))),
                        TableCell(child: Center(child: Text('GF', style: TextStyle(fontWeight: FontWeight.bold)))),
                        TableCell(child: Center(child: Text('GA', style: TextStyle(fontWeight: FontWeight.bold)))),
                        TableCell(child: Center(child: Text('Pts', style: TextStyle(fontWeight: FontWeight.bold)))),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                // Standings List
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

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(3), // Team Name
                          1: FlexColumnWidth(1), // GP
                          2: FlexColumnWidth(1), // W
                          3: FlexColumnWidth(1), // L
                          4: FlexColumnWidth(1), // T
                          5: FlexColumnWidth(1), // GF
                          6: FlexColumnWidth(1), // GA
                          8: FlexColumnWidth(1), // Pts
                        },
                        children: [
                          TableRow(
                            children: [
                              // Team Name (no logo)
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 4.0), // Slight padding for text
                                  child: Text(clubName, overflow: TextOverflow.ellipsis),
                                ),
                              ),
                              // Editable Fields
                              TableCell(child: _buildNumberEditableField(id, 'gamesPlayed', gamesPlayed)),
                              TableCell(child: _buildNumberEditableField(id, 'wins', wins)),
                              TableCell(child: _buildNumberEditableField(id, 'losses', losses)),
                              TableCell(child: _buildNumberEditableField(id, 'draws', draws)),
                              TableCell(child: _buildNumberEditableField(id, 'goalsFor', goalsFor)),
                              TableCell(child: _buildNumberEditableField(id, 'goalsAgainst', goalsAgainst)),
                              TableCell(child: _buildNumberEditableField(id, 'points', points)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTeamDialog(context),
        backgroundColor: const Color.fromARGB(255, 89, 152, 247),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}