import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hockey_union/home/home_drawer.dart';

class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clubNameController = TextEditingController();
  final TextEditingController _clubLeagueController = TextEditingController();
  final TextEditingController _clubContactPersonController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _clubDescriptionController = TextEditingController();

  Future<void> _saveTeamToFirestore() async {
    if (_formKey.currentState!.validate()) {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not signed in')),
        );
        return;
      }

      try {
        // Create the team document
        final teamRef = await FirebaseFirestore.instance.collection('Teams').add({
          'clubName': _clubNameController.text.trim(),
          'clubLeague': _clubLeagueController.text.trim(),
          'clubContactPerson': _clubContactPersonController.text.trim(),
          'email': _emailController.text.trim(),
          'phoneNumber': _phoneNumberController.text.trim(),
          'clubDescription': _clubDescriptionController.text.trim(),
          'uid': uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Add creator_info subcollection
        await teamRef.collection('creator_info').doc('details').set({
          'createdByUid': uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Team created successfully')),
        );

        Navigator.of(context).pop(); // Go back to the previous page
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create team: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Center(
          child: SizedBox(
            height: 30,
            child: Image.asset(
              'assets/images/NHU.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: const [SizedBox(width: 56)],
      ),
      drawer: const HomeDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _clubNameController,
                decoration: const InputDecoration(
                  labelText: 'Club Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter club name' : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _clubLeagueController,
                decoration: const InputDecoration(
                  labelText: 'Club League',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter club league' : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _clubContactPersonController,
                decoration: const InputDecoration(
                  labelText: 'Club Contact Person',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter club contact person'
                    : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter phone number'
                    : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _clubDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Club description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter club description' : null,
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _saveTeamToFirestore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text('SAVE', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
