import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hockey_union/home/home_drawer.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 

enum LeagueType {
  mensDivision('Mens Division'),
  womensDivision('Womens Division');

  final String displayName;
  const LeagueType(this.displayName);
}

enum LeagueFilter {
  mensDivision('Mens Division'),
  womensDivision('Womens Division');

  final String displayName;
  const LeagueFilter(this.displayName);
}

class StandingsPage extends StatefulWidget {
  const StandingsPage({super.key});

  @override
  _StandingsPageState createState() => _StandingsPageState();
}

class _StandingsPageState extends State<StandingsPage> {
  final CollectionReference _standings = FirebaseFirestore.instance.collection('Standings');
  LeagueFilter _selectedLeagueFilter = LeagueFilter.mensDivision; 

  String? _currentUserRole; 

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserRole(); 
  }

  // Fetches the role of the currently logged-in user
  Future<void> _fetchCurrentUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _currentUserRole = userDoc.data()?['role'];
        });
      }
    } else {
      setState(() {
        _currentUserRole = 'Guest';
      });
    }
  }

  Future<void> _updateTeamField(String docId, String field, dynamic value) async {
    if (_currentUserRole == 'Admin') {
      await _standings.doc(docId).update({field: value});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission Denied: Only Admins can modify standings.')),
      );
    }
  }

  Future<void> _addTeamDialog(BuildContext context) async {
    if (_currentUserRole != 'Admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission Denied: Only Admins can add teams to standings.')),
      );
      return;
    }

    final TextEditingController nameController = TextEditingController();
    final TextEditingController pointsController = TextEditingController(text: '0');
    final TextEditingController winsController = TextEditingController(text: '0');
    final TextEditingController lossesController = TextEditingController(text: '0');
    final TextEditingController drawsController = TextEditingController(text: '0');
    final TextEditingController gamesPlayedController = TextEditingController(text: '0');
    final TextEditingController goalsForController = TextEditingController(text: '0');
    final TextEditingController goalsAgainstController = TextEditingController(text: '0');

    LeagueType? dialogSelectedLeagueType;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setStateModal) {
          return AlertDialog(
            title: const Text('Add New Team'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Team Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<LeagueType>(
                    value: dialogSelectedLeagueType,
                    decoration: const InputDecoration(
                      labelText: 'League Type',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), 
                    ),
                    items: LeagueType.values.map((LeagueType league) {
                      return DropdownMenuItem<LeagueType>(
                        value: league,
                        child: Text(league.displayName),
                      );
                    }).toList(),
                    onChanged: (LeagueType? newValue) {
                      setStateModal(() {
                        dialogSelectedLeagueType = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a league type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
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
                  if (nameController.text.isEmpty || dialogSelectedLeagueType == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter team name and select a league type.')),
                    );
                    return;
                  }

                  await _standings.add({
                    'clubName': nameController.text,
                    'leagueType': dialogSelectedLeagueType!.displayName,
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
          );
        },
      ),
    );
  }

  // Widget to build an editable number field for standings stats
  Widget _buildNumberEditableField(String docId, String field, int value, {bool isPoints = false}) {
    final bool canEdit = _currentUserRole == 'Admin';

    return SizedBox(
      width: 50,
      child: TextFormField(
        initialValue: value.toString(),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        readOnly: !canEdit, 
        onFieldSubmitted: canEdit ? (val) {
          int parsed = int.tryParse(val) ?? 0;
          _updateTeamField(docId, field, parsed); 
          FocusScope.of(context).unfocus();
        } : null, 
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
          border: InputBorder.none,
          focusedBorder: canEdit ? const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent, width: 1.0), 
          ) : InputBorder.none, 
          enabledBorder: InputBorder.none, 
          disabledBorder: InputBorder.none, 
        ),
        style: TextStyle(
          fontWeight: isPoints ? FontWeight.bold : FontWeight.normal,
          color: isPoints ? Colors.blue[800] : Colors.black87,
          fontSize: 14.0,
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredStandingsStream() {
    Query query = _standings;
    query = query.where('leagueType', isEqualTo: _selectedLeagueFilter.displayName);
    query = query.orderBy('points', descending: true).orderBy('goalsFor', descending: true);
    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: const Text('Standings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue[900], 
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white), 
            onPressed: () {
              setState(() {}); 
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const HomeDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<LeagueFilter>(
                segments: LeagueFilter.values.map((LeagueFilter league) {
                  return ButtonSegment<LeagueFilter>(
                    value: league,
                    label: Text(league.displayName),
                  );
                }).toList(),
                selected: <LeagueFilter>{_selectedLeagueFilter},
                onSelectionChanged: (Set<LeagueFilter> newSelection) {
                  setState(() {
                    _selectedLeagueFilter = newSelection.first;
                  });
                },
                style: SegmentedButton.styleFrom(
                  foregroundColor: Colors.blue[900],
                  selectedForegroundColor: Colors.white,
                  selectedBackgroundColor: Colors.blue[900],
                  side: BorderSide(color: Colors.blue[900]!),
                  textStyle: const TextStyle(fontSize: 14), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), 
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredStandingsStream(),
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
                        Text(
                          'No teams in standings yet for ${_selectedLeagueFilter.displayName}.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey, fontSize: 18, fontStyle: FontStyle.italic),
                        ),
                        const Text('Tap the "+" button to add one (Admins only)!', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  );
                }

                final teams = snapshot.data!.docs;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 6.0, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue[800],
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(0.7),
                              1: FlexColumnWidth(3),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(1),
                              4: FlexColumnWidth(1),
                              5: FlexColumnWidth(1),
                              6: FlexColumnWidth(1),
                              7: FlexColumnWidth(1),
                              8: FlexColumnWidth(1.2),
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
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: teams.length,
                          itemBuilder: (context, index) {
                            final team = teams[index];
                            final id = team.id;
                            final data = team.data() as Map<String, dynamic>;

                            final String clubName = data['clubName'] ?? 'Unknown Team';
                            final int points = data['points'] ?? 0;
                            final int wins = data['wins'] ?? 0;
                            final int losses = data['losses'] ?? 0;
                            final int draws = data['draws'] ?? 0;
                            final int gamesPlayed = data['gamesPlayed'] ?? (wins + losses + draws);
                            final int goalsFor = data['goalsFor'] ?? 0;
                            final int goalsAgainst = data['goalsAgainst'] ?? 0;

                            final Color rowColor = index % 2 == 0 ? Colors.white : Colors.blue[50]!;
                            final int rank = index + 1;

                            return Container(
                              color: rowColor,
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                              child: Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(0.7),
                                  1: FlexColumnWidth(3),
                                  2: FlexColumnWidth(1),
                                  3: FlexColumnWidth(1),
                                  4: FlexColumnWidth(1),
                                  5: FlexColumnWidth(1),
                                  6: FlexColumnWidth(1),
                                  7: FlexColumnWidth(1),
                                  8: FlexColumnWidth(1.2),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      TableCell(child: Center(child: Text('$rank', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 14)))),
                                      TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 4.0),
                                          child: Text(
                                            clubName,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey[800], fontSize: 14),
                                          ),
                                        ),
                                      ),
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
          ),
        ],
      ),
      floatingActionButton: _currentUserRole == 'Admin' 
          ? FloatingActionButton(
              onPressed: () => _addTeamDialog(context),
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: const Icon(Icons.add, size: 30),
            )
          : null, 
    );
  }
}