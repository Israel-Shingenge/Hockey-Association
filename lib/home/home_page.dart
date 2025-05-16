import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:hockey_union/authentication/auth.dart';
import 'package:hockey_union/home/home_drawer.dart';

class HomePage extends StatefulWidget {
  final String userRole;

  const HomePage({super.key, this.userRole = 'Player'});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> signOut() async {
    await Auth().signOut();

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HomeDrawer(userRole: widget.userRole),
      appBar: AppBar(
        title: Image.asset('assets/images/logo.png', height: 30),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => signOut),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              'Standings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Placeholder(fallbackHeight: 100),
            SizedBox(height: 16),
            Text(
              'Fixtures',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Placeholder(fallbackHeight: 100),
            SizedBox(height: 16),
            Text(
              'News',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Placeholder(fallbackHeight: 100),
          ],
        ),
      ),
    );
  }
}
