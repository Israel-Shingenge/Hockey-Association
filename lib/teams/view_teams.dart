import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hockey_union/home/home_drawer.dart';
import 'package:hockey_union/teams/edit_team.dart'; // Import the EditTeamPage

class TeamSelectionPage extends StatefulWidget {
  const TeamSelectionPage({super.key});

  @override
  State<TeamSelectionPage> createState() => _TeamSelectionPageState();
}

class _TeamSelectionPageState extends State<TeamSelectionPage> {
  late Future<List<DocumentSnapshot>> _userTeamsFuture;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isTeamMenuVisible = false;
  List<DocumentSnapshot> _userTeams = [];

  Future<List<DocumentSnapshot>> _fetchUserTeams() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      print('No user is logged in');
      return [];
    }

    try {
      final teamsSnapshot = await FirebaseFirestore.instance
          .collection('Teams')
          .where('uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      return teamsSnapshot.docs;
    } catch (e) {
      print('Error fetching teams: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _userTeamsFuture = _fetchUserTeams();
  }

  // ignore: unused_element
  void _toggleTeamMenu() {
    setState(() {
      _isTeamMenuVisible = !_isTeamMenuVisible;
    });
  }

  void _navigateToEditTeamPage(DocumentSnapshot team) {
    final teamData = team.data() as Map<String, dynamic>;
    final teamName = teamData['teamName'] ?? '';
    final clubName = teamData['clubName'];
    final contactPerson = teamData['contactPerson'];
    final email = teamData['email'];
    final description = teamData['description'];
    final logoUrl = teamData['logoUrl'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTeamPage(
          teamName: teamName,
          initialClubName: clubName,
          initialContactPerson: contactPerson,
          initialEmail: email,
          initialDescription: description,
          teamLogoUrl: logoUrl,
        ),
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
          child: SizedBox(
            height: 30,
            child: Image.asset(
              'assets/images/NHU.png', // Replace with your actual logo path
              fit: BoxFit.contain,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight), // Match standard AppBar bottom height
          child: Container(
            color: const Color.fromARGB(255, 238, 238, 238), // Light grey background
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active teams',
                  style: TextStyle(color: Colors.black87, fontWeight: FontWeight.normal),
                ),
                TextButton(
                  onPressed: () async {
                    // For now, let's navigate to the edit page for the first team in the list
                    if (_userTeams.isNotEmpty) {
                      _navigateToEditTeamPage(_userTeams.first);
                    } else {
                      // Optionally show a message if there are no teams to edit
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No teams available to edit.')),
                      );
                    }
                  },
                  child: const Text('Edit', style: TextStyle(color: Colors.blue)), // Changed text color to blue
                ),
              ],
            ),
          ),
        ),
        actions: const [
          SizedBox(width: 56), // To offset the leading icon if title is centered
        ],
      ),
      drawer: const HomeDrawer(),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _userTeamsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading teams: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No teams available.'));
          } else {
            _userTeams = snapshot.data!;
            return ListView.builder(
              itemCount: _userTeams.length,
              itemBuilder: (context, index) {
                final team = _userTeams[index];
                final teamData = team.data() as Map<String, dynamic>;
                final teamName = teamData['teamName'] ?? 'Unnamed Team';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                  title: Text(teamName),
                  onTap: () {
                    // Handle team selection
                    print('$teamName selected');
                    Navigator.pop(context, teamName); // Go back and pass the selected team name
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.blue), // Added edit icon
                    onPressed: () {
                      _navigateToEditTeamPage(team); // Navigate to edit page
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}