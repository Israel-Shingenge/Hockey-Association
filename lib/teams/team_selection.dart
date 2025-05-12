import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hockey_union/home/home_drawer.dart';
// Adjust the import path

class TeamSelectionPage extends StatefulWidget {
  const TeamSelectionPage({super.key});

  @override
  State<TeamSelectionPage> createState() => _TeamSelectionPageState();
}

class _TeamSelectionPageState extends State<TeamSelectionPage> {
  // ignore: unused_field
  late Future<List<DocumentSnapshot>> _userTeamsFuture;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isTeamMenuVisible = false;
  List<DocumentSnapshot> _userTeams = []; // List to store teams for the current user

  // Function to fetch teams for the current user
   Future<List<DocumentSnapshot>> _fetchUserTeams() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      print('No user is logged in');
      return [];
    }

    try {
      final teamsSnapshot = await FirebaseFirestore.instance
          .collection('Teams')
          .where('uid', isEqualTo: uid) // Retrieve teams for the logged-in user
          .orderBy('createdAt', descending: true)
          .get();

      return teamsSnapshot.docs;
    } catch (e) {
      print('Error fetching teams: $e');
      return [];
    }
  }


  // Call the fetch function when the page loads
  @override
  void initState() {
    super.initState();
    _fetchUserTeams();
  }

  void _toggleTeamMenu() {
    setState(() {
      _isTeamMenuVisible = !_isTeamMenuVisible;
    });
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
        title: const Text('Teams'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: GestureDetector(
            onTap: _toggleTeamMenu,
            child: Container(
              color: const Color.fromARGB(255, 13, 60, 161),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Text(
                          'Dunes', // Current league (can be dynamic)
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                  ),
                  // You might add a filter or search icon here later
                ],
              ),
            ),
          ),
        ),
      ),
      drawer: const HomeDrawer(),
      body: Stack(
        children: [
          // Main content of the Teams page
          // Display user's teams
          if (_userTeams.isEmpty)
            const Center(child: Text('No teams available. Create one!'))
          else
            ListView.builder(
              itemCount: _userTeams.length,
              itemBuilder: (context, index) {
                final teamData = _userTeams[index].data() as Map<String, dynamic>;
                final teamName = teamData['teamName'] ?? 'Unnamed Team';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                  title: Text(teamName),
                  onTap: () {
                    setState(() {
                      _isTeamMenuVisible = false;
                      // Navigate to team profile or perform other actions
                    });
                    print('$teamName selected');
                  },
                );
              },
            ),
          // Pop-up menu for team selection
          if (_isTeamMenuVisible)
            GestureDetector(
              onTap: _toggleTeamMenu, // Close when tapping outside
              behavior: HitTestBehavior.opaque, // Make the whole area tappable
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                      .animate(CurvedAnimation(
                    parent: ModalRoute.of(context)!.animation!,
                    curve: Curves.easeInOut,
                    reverseCurve: Curves.easeOut,
                  )),
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: ModalRoute.of(context)!.animation!,
                      curve: Curves.easeInOut,
                      reverseCurve: Curves.easeOut,
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 450.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8.0,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            color: const Color.fromARGB(255, 238, 238, 238),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: _toggleTeamMenu,
                                  child: const Text('Close', style: TextStyle(color: Colors.black87)),
                                ),
                                const Text('My teams', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextButton(
                                  onPressed: () async {
                                    // Handle team editing here
                                  },
                                  child: const Text('Edit', style: TextStyle(color: Colors.black87)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
