/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hockey_union/home/home_page.dart';
import 'package:hockey_union/authentication/login.dart';

class RoleWidgetTree extends StatefulWidget {
  const RoleWidgetTree({super.key});

  @override
  State<RoleWidgetTree> createState() => _RoleWidgetTreeState();
}

class _RoleWidgetTreeState extends State<RoleWidgetTree> {
  String? role;

  Future<void> getUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      setState(() {
        role = doc['role'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUserRole();
  }

  @override
  Widget build(BuildContext context) {
    if (role == null) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (role) {
      case 'Admin':
      case 'Manager':
      case 'Player':
        return HomePage(); // Customize home for each role later if needed
      default:
        return const LoginPage();
    }
  }
}*/

import 'package:flutter/material.dart';
import 'package:hockey_union/home/home_page.dart';
import 'package:hockey_union/authentication/login.dart';

class RoleWidgetTree extends StatefulWidget {
  const RoleWidgetTree({super.key});

  @override
  State<RoleWidgetTree> createState() => _RoleWidgetTreeState();
}

class _RoleWidgetTreeState extends State<RoleWidgetTree> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    if (_selectedRole == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Select a Role to Continue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => setState(() => _selectedRole = 'Admin'),
                  child: const Text('Login as Admin'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => setState(() => _selectedRole = 'Manager'),
                  child: const Text('Login as Manager'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => setState(() => _selectedRole = 'Player'),
                  child: const Text('Login as Player'),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed:
                      () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      ),
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return HomePage(userRole: _selectedRole!);
  }
}
