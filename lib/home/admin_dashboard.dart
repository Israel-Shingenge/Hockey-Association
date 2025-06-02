import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:hockey_union/models/team.dart';
import 'package:hockey_union/models/player.dart';
import 'package:hockey_union/models/query.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Team> _teams = [];
  List<Player> _players = [];
  List<UserQuery> _queries = [];

  final Color _primaryBlue = const Color(0xFF144781);

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Function to load dashboard data from Firestore
  void _loadDashboardData() {

    FirebaseFirestore.instance
        .collection('Teams')
        .limit(5)
        .snapshots()
        .listen((snapshot) {
      debugPrint('Fetching teams...');
      if (snapshot.docs.isEmpty) {
        debugPrint('No documents found in Teams collection.');
      } else {
        debugPrint('Found ${snapshot.docs.length} documents in Teams collection.');
      }
      setState(() {
        _teams = snapshot.docs.map((doc) => Team.fromFirestore(doc)).toList();
        _teams.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        debugPrint('Number of teams loaded: ${_teams.length}');
      });
    }, onError: (error) {
      debugPrint('Error fetching teams: $error');
    });

        // Fetch Players
        FirebaseFirestore.instance
            .collection('Player')
            .limit(5)
            .snapshots()
            .listen((snapshot) {
          setState(() {
            _players = snapshot.docs.map((doc) => Player.fromFirestore(doc)).toList();
            _players.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort in-memory
          });
        });

        // Fetch Queries
        FirebaseFirestore.instance
            .collection('Queries')
            .limit(10)
            .snapshots()
            .listen((snapshot) {
          setState(() {
            _queries = snapshot.docs.map((doc) => UserQuery.fromFirestore(doc)).toList();
            _queries.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort in-memory
          });
        });
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: _primaryBlue, 
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recently Registered Teams Section
            _buildSectionTitle(context, 'Recently Registered Teams'),
            _buildTeamList(),
            const SizedBox(height: 32.0),

            // Recently Registered Players Section
            _buildSectionTitle(context, 'Recently Registered Players'),
            _buildPlayerList(),
            const SizedBox(height: 32.0),

            // Submitted Queries Section
            _buildSectionTitle(context, 'Submitted Queries'),
            _buildQueryList(),
          ],
        ),
      ),
    );
  }

  // Helper widget to build section titles
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: _primaryBlue, 
            ),
      ),
    );
  }

  // Widget to display a list of recent teams
  Widget _buildTeamList() {
    if (_teams.isEmpty) {
      return const Center(child: Text('No recent teams found.'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _teams.length,
      itemBuilder: (context, index) {
        final team = _teams[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _primaryBlue,
                  child: const Icon(Icons.sports_hockey_rounded, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.clubName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'League: ${team.clubLeague}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Contact: ${team.contactPerson}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Registered: ${team.createdAt.toLocal().toString().split(' ')[0]}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget to display a list of recent players
  Widget _buildPlayerList() {
    if (_players.isEmpty) {
      return const Center(child: Text('No recent players found.'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _players.length,
      itemBuilder: (context, index) {
        final player = _players[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _primaryBlue, // Applied blue theme here
                  child: const Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${player.firstName} ${player.lastName} (#${player.jerseyNumber})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Position: ${player.position}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Email: ${player.email}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Registered: ${player.createdAt.toLocal().toString().split(' ')[0]}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget to display a list of submitted queries
  Widget _buildQueryList() {
    if (_queries.isEmpty) {
      return const Center(child: Text('No recent queries found.'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _queries.length,
      itemBuilder: (context, index) {
        final query = _queries[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From: ${query.email}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: _primaryBlue), // Applied blue theme here
                ),
                const SizedBox(height: 8.0),
                Text(
                  query.message,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8.0),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    'Submitted: ${query.timestamp.toLocal().toString().split('.')[0]}', // Format timestamp
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}