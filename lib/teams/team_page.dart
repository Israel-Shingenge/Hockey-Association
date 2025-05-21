import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hockey_union/home/home_drawer.dart';
import 'package:hockey_union/profile/player_profile.dart'; // Make sure this path is correct
import 'package:hockey_union/teams/add_player.dart';
import 'package:hockey_union/teams/view_teams.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _sortBy = 'firstName'; // Default sort by 'firstName'
  bool _sortDescending = false; // Default sort in ascending order

  void _showAddPlayerPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPlayerPage()),
    );
  }

  Widget _buildSortMenu() {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        setState(() {
          if (result == 'name_asc') {
            _sortBy = 'firstName';
            _sortDescending = false;
          } else if (result == 'name_desc') {
            _sortBy = 'firstName';
            _sortDescending = true;
          } else if (result == 'jersey_asc') {
            _sortBy = 'jerseyNumber';
            _sortDescending = false;
          } else if (result == 'jersey_desc') {
            _sortBy = 'jerseyNumber';
            _sortDescending = true;
          } else if (result == 'position_asc') {
            _sortBy = 'position';
            _sortDescending = false;
          } else if (result == 'position_desc') {
            _sortBy = 'position';
            _sortDescending = true;
          }
        });
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'name_asc',
          child: Text('Name (A-Z)'),
        ),
        const PopupMenuItem<String>(
          value: 'name_desc',
          child: Text('Name (Z-A)'),
        ),
        const PopupMenuItem<String>(
          value: 'jersey_asc',
          child: Text('Jersey Number (Low to High)'),
        ),
        const PopupMenuItem<String>(
          value: 'jersey_desc',
          child: Text('Jersey Number (High to Low)'),
        ),
        const PopupMenuItem<String>(
          value: 'position_asc',
          child: Text('Position (A-Z)'),
        ),
        const PopupMenuItem<String>(
          value: 'position_desc',
          child: Text('Position (Z-A)'),
        ),
      ],
      child: const Row(
        children: [
          Text('Sort', style: TextStyle(color: Colors.blue)),
          Icon(Icons.sort, color: Colors.blue),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Center(
          child: Image.asset('assets/images/NHU.png', height: 30),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const TeamSelectionPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    return SlideTransition(position: animation.drive(tween), child: child);
                  },
                ),
              );
            },
            child: Container(
              height: 50.0,
              color: Colors.blue[900],
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Teams',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8.0),
                  Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
        actions: const [SizedBox(width: 56)],
      ),
      drawer: const HomeDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add New Player Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Add New Player',
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _showAddPlayerPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    ),
                    child: const Text('ADD TEAM MEMBER', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Dynamic Player List Section
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Player')
                  .orderBy(_sortBy, descending: _sortDescending)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No players found."));
                }

                final players = snapshot.data!.docs;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Players (${players.length})',
                          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        _buildSortMenu(),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        final document = players[index]; // Get the document snapshot
                        final data = document.data()! as Map<String, dynamic>;
                        final String docId = document.id; // ⭐ Get the document ID here!
                        final fullName = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}';

                        // ⭐ IMPORTANT: Check if document ID is empty before proceeding
                        if (docId.isEmpty) {
                          print('Warning: Document ID is empty for a player. Skipping this entry.');
                          return const SizedBox.shrink(); // Don't build a list item for invalid ID
                        }

                        // ⭐ Pass docId and the full data map
                        return _buildPlayerListItem(docId, fullName, data);
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build individual player list items
  // Now accepts playerId (document.id) and playerData map
  Widget _buildPlayerListItem(String playerId, String playerName, Map<String, dynamic> playerData) {
    return InkWell(
      onTap: () {
        // ⭐ Pass the document ID and player data to PlayerProfilePage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerProfilePage(
              playerId: playerId, // Pass the unique document ID
              playerData: playerData, playerName: '', // Pass the entire player data map
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              const Icon(Icons.person),
              const SizedBox(width: 16.0),
              Expanded(
                child: Text(
                  playerName,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
              // Display jersey number if available
              if (playerData.containsKey('jerseyNumber'))
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '#${playerData['jerseyNumber'].toString()}',
                    style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                ),
              // Display position if available
              if (playerData.containsKey('position'))
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '(${playerData['position']})',
                    style: const TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ),
              const Icon(Icons.arrow_forward_ios, size: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}