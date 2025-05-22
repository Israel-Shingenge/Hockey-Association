import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hockey_union/home/home_drawer.dart';
import 'package:hockey_union/teams/edit_team.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeamSelectionPage extends StatefulWidget {
  const TeamSelectionPage({super.key});

  @override
  State<TeamSelectionPage> createState() => _TeamSelectionPageState();
}

class _TeamSelectionPageState extends State<TeamSelectionPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<DocumentSnapshot> _userTeams = [];
  Map<String, File?> _localLogos = {};

  @override
  void initState() {
    super.initState();
    _loadLocalLogos();
  }

  Future<void> _loadLocalLogos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var team in _userTeams) {
      final teamData = team.data() as Map<String, dynamic>;
      final teamName = teamData['clubName'];
      final logoPath = prefs.getString('team_logo_$teamName');
      if (logoPath != null && File(logoPath).existsSync()) {
        _localLogos[teamName] = File(logoPath);
      }
    }
    setState(() {});
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
    ).then((_) => _loadLocalLogos()); // Refresh local logos after editing
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Center(
          child: SizedBox(
            height: 30,
            child: Image.asset('assets/images/NHU.png', fit: BoxFit.contain),
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
                  style: TextStyle(color: Colors.black87),
                ),
                TextButton(
                  onPressed: () {
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
        actions: const [SizedBox(width: 56)],
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
                    if (_localLogos.isEmpty) {
                      _loadLocalLogos();
                    }
                  return ListView.builder(
                    itemCount: _userTeams.length,
                    itemBuilder: (context, index) {
                      final team = _userTeams[index];
                      final teamData = team.data() as Map<String, dynamic>;
                      final clubName = teamData['clubName'] ?? 'Unnamed Club';
                      final logoFile = _localLogos[clubName];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: logoFile != null
                              ? FileImage(logoFile)
                              : const AssetImage('assets/images/default_team_logo.png') as ImageProvider,
                        ),
                        title: Text(clubName),
                        onTap: () {
                          print('$clubName selected');
                          Navigator.pop(context, clubName);
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                          onPressed: () => _navigateToEditTeamPage(team),
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
