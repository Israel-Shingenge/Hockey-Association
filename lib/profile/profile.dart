import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hockey_union/authentication/auth.dart';
import 'edit_profile_page.dart';
import 'language_security.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = Auth().currentUser;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;


  @override
  void initState() {
    super.initState();
    // Initialize the controllers
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    // Load user data from Firestore
    _loadUserData();
  }
  

  Future<void> _loadUserData() async {
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user?.uid)
          .get();

      setState(() {
        _firstNameController.text = snapshot['firstName'] ?? '';
        _lastNameController.text = snapshot['lastName'] ?? '';
        _emailController.text = snapshot['email'] ?? '';
        _phoneController.text = snapshot['phone'] ?? '';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    // You might want to load the user's profile image here
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_firstNameController.text} ${_lastNameController.text}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text('+264 ${_phoneController.text}'), // Assuming Namibia country code
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('General', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit profile'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfilePage()),
                );
              },
            ),
              const SizedBox(height: 16),
              const Text('App settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.remove_red_eye_outlined),
                title: const Text('Theme'),
                trailing: Switch(
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (bool value) {
                    // Implement theme switching logic here
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Notifications'),
                trailing: const Text('Allow', style: TextStyle(color: Colors.grey)),
                onTap: () {
                  // Implement notifications settings navigation
                },
              ),
              ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LanguageSecurityPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.security_outlined),
              title: const Text('Security'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LanguageSecurityPage()),
                );
              },
            ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await Auth().signOut();
                    // Navigator will handle the redirection based on WidgetTree
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900], // Match the LOG OUT button color
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: const Text('SIGN OUT', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
      // Removed the bottomNavigationBar here
    );
  }
}