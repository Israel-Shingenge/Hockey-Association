import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hockey_union/authentication/auth.dart';

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
  late TextEditingController _genderController;
  
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Initialize the controllers
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _genderController = TextEditingController();

    // Load user data from Firestore
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user?.uid)
          .get();

      // Assuming the document contains these fields: firstName, lastName, email, phoneNumber, gender
      setState(() {
        _firstNameController.text = snapshot['firstName'] ?? '';
        _lastNameController.text = snapshot['lastName'] ?? '';
        _emailController.text = snapshot['email'] ?? '';
        _phoneController.text = snapshot['phone'] ?? '';
        _genderController.text = snapshot['gender'] ?? '';
      });
    }
  }

  Future<void> _updateUserData() async {
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('Users').doc(user?.uid).update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'gender': _genderController.text,
        });
        setState(() {
          _isEditing = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update data')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Full Name: ${_firstNameController.text} ${_lastNameController.text}'),
            const SizedBox(height: 10),
            Text('Email: ${_emailController.text}'),
            const SizedBox(height: 10),
            Text('Phone Number: ${_phoneController.text}'),
            const SizedBox(height: 10),
            Text('Gender: ${_genderController.text}'),
            const SizedBox(height: 20),
            _isEditing
                ? Column(
                    children: [
                      TextField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(labelText: 'First Name'),
                      ),
                      TextField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(labelText: 'Last Name'),
                      ),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Phone Number'),
                        keyboardType: TextInputType.phone,
                      ),
                      TextField(
                        controller: _genderController,
                        decoration: const InputDecoration(labelText: 'Gender'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _updateUserData,
                        child: const Text('Save Changes'),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                    child: const Text('Edit Profile'),
                  ),
          ],
        ),
      ),
    );
  }
}
