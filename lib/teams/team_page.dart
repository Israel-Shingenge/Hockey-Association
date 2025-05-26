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

  String? userRole;
  bool _loadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadAllPlayerImages();
  }

  Future<void> _loadUserRole() async {
    print('*** _loadUserRole started');
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No logged-in user found.');
        setState(() {
          userRole = null;
          _loadingRole = false;
        });
        return;
      }

      print('Fetching user role for uid: ${user.uid}');
      final doc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();

      if (!doc.exists) {
        print('User document does not exist for uid: ${user.uid}');
        setState(() {
          userRole = 'player'; // fallback role
          _loadingRole = false;
        });
        return;
      }

      final role = doc.data()?['role'] as String?;
      print('Role fetched from Firestore: $role');

      setState(() {
        userRole = role ?? 'player'; // Default to player if no role found
        _loadingRole = false;
      });
      print('User role set to: $userRole');
    } catch (e, st) {
      print('Error fetching user role: $e');
      print('Stack trace: $st');
      setState(() {
        userRole = 'player'; // fallback role on error
        _loadingRole = false;
      });
    }
    print('*** _loadUserRole ended');
  }

  Future<void> _loadAllPlayerImages() async {
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPlayerPage()),
    ).then((_) {
      // Reload images after returning
      _loadAllPlayerImages();
    });
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
    if (_loadingRole) {
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
          if (userRole == 'Admin' || userRole == 'Manager')
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
          const SizedBox(height: 16.0),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Players (0)',
                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            _buildSortMenu(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      const Expanded(child: Center(child: Text("No players found."))),
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
    // Only Admin & Manager can open player details
    final canViewDetails = userRole == 'Admin' || userRole == 'Manager';

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
              _loadAllPlayerImages();
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
