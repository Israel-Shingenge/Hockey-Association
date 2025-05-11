import 'package:firebase_auth/firebase_auth.dart';
import 'package:hockey_union/authentication/auth.dart';
import 'package:flutter/material.dart';
import 'home_drawer.dart';
import 'package:hockey_union/teams/team_popup.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final User? user = Auth().currentUser;
  // ignore: unused_field
  final String _selectedLeague = 'Dunes'; // Initial league selection

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign out'),
    );
  }

  Widget _buildRoundedBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      height: 100,
      child: const Center(
        child: Text(
          'Content Placeholder',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showAddPopupMenu() {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(
          1000, // Adjust based on the plus icon's position
          120, // Adjust based on the plus icon's position
          1000,
          1000),
      items: [
        PopupMenuItem(
          value: 'team',
          child: Row(
            children: const [
              Icon(Icons.group_add),
              SizedBox(width: 8),
              Text('Team'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'event',
          child: Row(
            children: const [
              Icon(Icons.event),
              SizedBox(width: 8),
              Text('Event'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'player',
          child: Row(
            children: const [
              Icon(Icons.person_add),
              SizedBox(width: 8),
              Text('Player'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'team') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CreateTeamPopup();
          },
        );
      } else if (value == 'event') {
        // Navigate to create event page/popup
        print('Create Event');
      } else if (value == 'player') {
        // Navigate to create player page/popup
        print('Create Player');
      }
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
        title: Center(
          child: Image.asset(
            'assets/images/NHU.png', // Replace with your small logo asset path
            height: 30,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.blue[900], // Match the bar's background color
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Text(
                        'Dunes', // Current league
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.white),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: _showAddPopupMenu,
                ),
              ],
            ),
          ),
        ),
        actions: const [
          SizedBox(width: 56),
        ],
      ),
      drawer: const HomeDrawer(), // Use the HomeDrawer here
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Standings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildRoundedBox(),
            const SizedBox(height: 16),
            const Text(
              'Fixtures',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildRoundedBox(),
            const SizedBox(height: 16),
            const Text(
              'News',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildRoundedBox(),
            const SizedBox(height: 16),
            const Text(
              'View Events (Upcoming, Ongoing, Past)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildRoundedBox(),
            const Spacer(), // Keep this if you want Sign Out at the bottom
            _signOutButton(),
          ],
        ),
      ),
    );
  }
}