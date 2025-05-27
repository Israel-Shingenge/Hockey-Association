import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hockey_union/announcements/view_announcements.dart';
import 'package:hockey_union/home/home_drawer.dart';
import 'package:hockey_union/profile/player_profile.dart';
import 'package:hockey_union/teams/add_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _sortBy = 'firstName';
  bool _sortDescending = false;

  final Map<String, String?> _profileImageCache = {};

  String? _userRole;
  String? _currentUserTeamId; // Stores the document ID of the manager's team
  bool _loadingRoleAndTeam = true; // Combined loading state

  @override
  void initState() {
    super.initState();
    _loadUserRoleAndTeam();
    _loadAllPlayerImages();
  }

  Future<void> _loadUserRoleAndTeam() async {
    print('*** _loadUserRoleAndTeam started');
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No logged-in user found.');
        setState(() {
          _userRole = null;
          _loadingRoleAndTeam = false;
        });
        return;
      }

      // 1. Fetch User Role
      print('Fetching user role for uid: ${user.uid}');
      final userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();

      if (!userDoc.exists) {
        print('User document does not exist for uid: ${user.uid}. Defaulting to player.');
        setState(() {
          _userRole = 'player'; // fallback role
          _loadingRoleAndTeam = false;
        });
        return;
      }

      final role = userDoc.data()?['role'] as String?;
      print('Role fetched from Firestore: $role');

      setState(() {
        _userRole = role ?? 'player'; // Default to player if no role found
      });

      // 2. If Manager, fetch their team ID
      if (_userRole == 'Manager') {
        print('User is a Manager. Fetching their team ID...');
        final teamSnapshot = await FirebaseFirestore.instance
            .collection('Teams')
            .where('managerFirebaseUid', isEqualTo: user.uid)
            .limit(1) // Assuming one manager per team
            .get();

        if (teamSnapshot.docs.isNotEmpty) {
          _currentUserTeamId = teamSnapshot.docs.first.id; // Get the document ID
          print('Manager team ID found: $_currentUserTeamId');
        } else {
          print('No team found for manager with UID: ${user.uid}');
          _currentUserTeamId = null; // No team found for this manager
        }
      } else {
        _currentUserTeamId = null; // Not applicable for Admin or Player
      }

      setState(() {
        _loadingRoleAndTeam = false;
      });
      print('User role set to: $_userRole, Team ID: $_currentUserTeamId');
    } catch (e, st) {
      print('Error fetching user role or team: $e');
      print('Stack trace: $st');
      setState(() {
        _userRole = 'player'; // fallback role on error
        _loadingRoleAndTeam = false;
      });
    }
    print('*** _loadUserRoleAndTeam ended');
  }

  Future<void> _loadAllPlayerImages() async {
    // This method might need adjustment if you want to only cache images for the current team
    // or if image URLs are stored directly in Firestore and not SharedPreferences.
    // For now, keeping it as is, assuming it works globally.
    final prefs = await SharedPreferences.getInstance();
    final snapshot = await FirebaseFirestore.instance.collection('Player').get();
    if (!mounted) return;

    setState(() {
      for (var doc in snapshot.docs) {
        final path = prefs.getString('profile_image_${doc.id}');
        _profileImageCache[doc.id] = path;
      }
    });
  }

  void _showAddPlayerPage() {
    // Only navigate if a team ID is available for managers, or if Admin
    if (_userRole == 'Admin' || (_userRole == 'Manager' && _currentUserTeamId != null)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPlayerPage(
            teamId: _currentUserTeamId, // Pass the teamId, will be null for Admin, handled in AddPlayerPage
          ),
        ),
      ).then((_) {
        // Reload images and re-evaluate roles/teams after returning
        _loadAllPlayerImages();
        _loadUserRoleAndTeam();
      });
    } else {
      // Potentially show a snackbar for managers who don't have a team yet
      if (_userRole == 'Manager' && _currentUserTeamId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please create your team first to add players.')),
        );
      }
    }
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
    if (_loadingRoleAndTeam) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Center(
          child: Image.asset('assets/images/NHU.png', height: 30),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.notifications, color: Colors.black87),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AnnouncementPage()),
                );
              },
            ),
          ),
        ],
      ),
      drawer: const HomeDrawer(),
      body: Column(
        children: [
          // Show "Add Your Team" card only for Admin or Manager
          if (_userRole == 'Admin' || (_userRole == 'Manager' && _currentUserTeamId != null))
            Card(
              margin: const EdgeInsets.all(16.0),
              color: Colors.white,
              elevation: 2.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Add Your Team',
                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10.0),
                    const Icon(Icons.people_alt, size: 40.0, color: Colors.grey),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Register your team members and invite\nthem to join you on NHA',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.0, color: Colors.grey),
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: _showAddPlayerPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 11, 71, 182),
                        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      child: const Text(
                        'ADD TEAM MEMBER',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Add a message for managers without a team
          if (_userRole == 'Manager' && _currentUserTeamId == null)
            Card(
              margin: const EdgeInsets.all(16.0),
              color: Colors.orange.shade50,
              elevation: 2.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 30),
                    SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        'You need to create your team first before you can add players.',
                        style: TextStyle(fontSize: 14.0, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16.0),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: (_userRole == 'Admin')
                  ? FirebaseFirestore.instance.collection('Player').orderBy(_sortBy, descending: _sortDescending).snapshots()
                  : (_userRole == 'Manager' && _currentUserTeamId != null)
                      ? FirebaseFirestore.instance
                          .collection('Player')
                          .where('teamId', isEqualTo: _currentUserTeamId) // Filter by teamId
                          .orderBy(_sortBy, descending: _sortDescending)
                          .snapshots()
                      : (_userRole == 'Player' && FirebaseAuth.instance.currentUser != null)
                          ? FirebaseFirestore.instance
                              .collection('Player')
                              .where('firebaseAuthUid', isEqualTo: FirebaseAuth.instance.currentUser!.uid) // Player sees their own profile
                              .orderBy(_sortBy, descending: _sortDescending) // Still sort if fetching own profile
                              .snapshots()
                          : Stream.empty(), // No stream for unauthenticated or non-team-associated players
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  String message = "No players found.";
                  if (_userRole == 'Manager' && _currentUserTeamId == null) {
                    message = "No team registered for this manager yet. Create one to add players.";
                  } else if (_userRole == 'Player' && FirebaseAuth.instance.currentUser == null) {
                    message = "Please log in to view your profile.";
                  } else if (_userRole == 'Player' && snapshot.data!.docs.isEmpty) {
                    message = "Your player profile is not linked or does not exist.";
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Players (0)',
                              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            _buildSortMenu(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Expanded(child: Center(child: Text(message))),
                    ],
                  );
                }

                final players = snapshot.data!.docs;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Players (${players.length})',
                            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          _buildSortMenu(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: ListView.separated(
                        itemCount: players.length,
                        itemBuilder: (context, index) {
                          final document = players[index];
                          final data = document.data()! as Map<String, dynamic>;
                          final String docId = document.id;
                          final fullName = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}';

                          if (docId.isEmpty) {
                            debugPrint('Warning: Document ID is empty for a player. Skipping this entry.');
                            return const SizedBox.shrink();
                          }

                          final String? profileImagePath = _profileImageCache[docId];

                          return _buildPlayerListItem(docId, fullName, data, profileImagePath);
                        },
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey,
                          indent: 16,
                          endIndent: 16,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerListItem(
      String playerId,
      String playerName,
      Map<String, dynamic> playerData,
      String? profileImagePath,
      ) {
    // Admin & Manager can open player details, Players can only open their own if linked
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    final bool isPlayerSelf = _userRole == 'Player' && playerData['firebaseAuthUid'] == currentUserUid;
    final bool canViewDetails = _userRole == 'Admin' || _userRole == 'Manager' || isPlayerSelf;


    return InkWell(
      onTap: canViewDetails
          ? () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerProfilePage(
              playerId: playerId,
              playerData: playerData,
              playerName: playerName,
            ),
          ),
        );
        _loadAllPlayerImages(); // Reload images after returning
      }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            ClipOval(
              child: profileImagePath != null && profileImagePath.isNotEmpty && File(profileImagePath).existsSync()
                  ? Image.file(
                File(profileImagePath),
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              )
                  : Container(
                width: 48,
                height: 48,
                color: Colors.grey[300],
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playerName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Jersey: ${playerData['jerseyNumber'] ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Position: ${playerData['position'] ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (canViewDetails)
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}