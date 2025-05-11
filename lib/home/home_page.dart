import 'package:firebase_auth/firebase_auth.dart';
import 'package:hockey_union/authentication/auth.dart';
import 'package:flutter/material.dart';
import 'home_drawer.dart'; 

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final User? user = Auth().currentUser;

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