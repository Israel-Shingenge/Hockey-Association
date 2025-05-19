import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hockey_union/home/home_drawer.dart';
import 'package:hockey_union/teams/edit_team.dart';

class TeamSelectionPage extends StatefulWidget {
  const TeamSelectionPage({super.key});

  @override
  State<TeamSelectionPage> createState() => _TeamSelectionPageState();
}

class _TeamSelectionPageState extends State<TeamSelectionPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isTeamMenuVisible = false;
  List<DocumentSnapshot> _userTeams = [];

  void _toggleTeamMenu() {
    setState(() {
      _isTeamMenuVisible = !_isTeamMenuVisible;
    });
  }

  void _navigateToEditTeamPage(DocumentSnapshot team) {
    final teamData = team.data() as Map<String, dynamic>;
    final clubName = teamData['clubName'];
    final contactPerson = teamData['contactPerson'];
    final email = teamData['email'];
    final description = teamData['clubDescription'];
    final logoUrl = teamData['logoUrl'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTeamPage(
          teamName: clubName,
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
    final uid = FirebaseAuth.instance.currentUser?.uid;

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
              'assets/images/NHU.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            color: const Color.fromARGB(255, 238, 238, 238),
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
                    if (_userTeams.isNotEmpty) {
                      _navigateToEditTeamPage(_userTeams.first);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No teams available to edit.')),
                      );
                    }
                  },
                  child: const Text('Edit', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
        ),
        actions: const [
          SizedBox(width: 56),
        ],
      ),
      drawer: const HomeDrawer(),
      body: uid == null
          ? const Center(child: Text('No user is logged in.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Teams')
                  .where('uid', isEqualTo: uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading teams: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No teams available.'));
                } else {
                  _userTeams = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: _userTeams.length,
                    itemBuilder: (context, index) {
                      final team = _userTeams[index];
                      final teamData = team.data() as Map<String, dynamic>;
                      final clubName = teamData['clubName'] ?? 'Unnamed Club';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                        title: Text(clubName),
                        onTap: () {
                          print('$clubName selected');
                          Navigator.pop(context, clubName);
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                          onPressed: () {
                            _navigateToEditTeamPage(team);
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
