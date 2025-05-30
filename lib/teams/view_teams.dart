import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hockey_union/teams/edit_team.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeamSelectionPage extends StatefulWidget {
  const TeamSelectionPage({super.key});

  @override
  State<TeamSelectionPage> createState() => _TeamSelectionPageState();
}

class _TeamSelectionPageState extends State<TeamSelectionPage> {
  List<DocumentSnapshot> _userTeams = [];
  final Map<String, File?> _localLogos = {};
  bool _localLogosLoadedForCurrentTeams = false;

  @override
  void initState() {
    super.initState();
  }

  // Modified to take a list of teams, so it can be called when data is available
  Future<void> _loadLocalLogos(List<DocumentSnapshot> teams) async {
    if (teams.isEmpty) return; 

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, File?> newLocalLogos = {}; 

    for (var team in teams) {
      final teamData = team.data() as Map<String, dynamic>;
      final clubName = teamData['clubName'];
      if (clubName != null && !_localLogos.containsKey(clubName)) {
        final logoPath = prefs.getString('team_logo_$clubName');
        if (logoPath != null && File(logoPath).existsSync()) {
          newLocalLogos[clubName] = File(logoPath);
        } else {
          newLocalLogos[clubName] = null; 
        }
      } else if (clubName != null && _localLogos.containsKey(clubName)) {
        newLocalLogos[clubName] = _localLogos[clubName]; 
      }
    }

    // Only call setState if there are new logos to add
    if (newLocalLogos.isNotEmpty && !mapEquals(_localLogos, newLocalLogos)) {
      setState(() {
        _localLogos.clear();
        _localLogos.addAll(newLocalLogos);
        _localLogosLoadedForCurrentTeams = true; // Set flag
      });
    } else if (newLocalLogos.isEmpty && _localLogos.isNotEmpty) {
       setState(() {
        _localLogos.clear();
        _localLogosLoadedForCurrentTeams = true;
       });
    } else {
      _localLogosLoadedForCurrentTeams = true; 
    }
  }

  // Helper to compare maps (optional, but good for efficiency)
  bool mapEquals(Map<String, File?> m1, Map<String, File?> m2) {
    if (m1.length != m2.length) return false;
    for (final key in m1.keys) {
      if (!m2.containsKey(key) || m1[key] != m2[key]) {
        return false;
      }
    }
    return true;
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
    ).then((_) {
        _loadLocalLogos(_userTeams); 
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(), 
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
      body: uid == null
          ? const Center(child: Text('No user is logged in.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Teams')
                  .where('managerFirebaseUid', isEqualTo: uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading teams: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  // If no data, ensure logos are cleared and flag reset
                  _userTeams = [];
                  if (_localLogos.isNotEmpty || _localLogosLoadedForCurrentTeams) {
                    _localLogos.clear();
                    _localLogosLoadedForCurrentTeams = false;
                  }
                  return const Center(child: Text('No teams available.'));
                } else {
                  _userTeams = snapshot.data!.docs;

                  if (!_localLogosLoadedForCurrentTeams || _userTeams.length != _localLogos.length) {
                    _localLogosLoadedForCurrentTeams = false;
                    _loadLocalLogos(_userTeams);
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
                              : const AssetImage('assets/images/NHU.png') as ImageProvider,
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