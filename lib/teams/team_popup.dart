import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateTeamPopup extends StatefulWidget {
  const CreateTeamPopup({super.key});

  @override
  State<CreateTeamPopup> createState() => _CreateTeamPopupState();
}

class _CreateTeamPopupState extends State<CreateTeamPopup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _teamNameController = TextEditingController();
  String? _selectedTeamAge;
  String? _selectedCountry;
  String? _selectedTimeZone;

  final List<String> _ageRanges = ['U/10', 'U/12', 'U/14', 'U/16', 'U/19', 'U/20', 'Adult'];
  final List<String> _countries = ['Namibia', 'South Africa', 'Botswana', 'Zimbabwe', 'Angola'];
  final List<String> _timeZones = ['UTC+00:00', 'UTC+01:00', 'UTC+02:00'];

  Future<void> _saveTeamToFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not signed in')),
      );
      return;
    }

      await FirebaseFirestore.instance.collection('Teams').add({
      'teamName': _teamNameController.text,
      'teamAge': _selectedTeamAge,
      'country': _selectedCountry,
      'timeZone': _selectedTimeZone,
      'uid': uid, // Store the authenticated user's UID here
      'createdAt': FieldValue.serverTimestamp(),
    });


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Team created successfully')),
    );

    Navigator.of(context).pop(); // Close the popup
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Create team'),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),   
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7, // 70% of screen height
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _teamNameController,
                decoration: const InputDecoration(
                  labelText: 'Team Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter team name' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Team age',
                  border: OutlineInputBorder(),
                ),
                value: _selectedTeamAge,
                items: _ageRanges.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) => setState(() => _selectedTeamAge = newValue),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please select team age' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCountry,
                items: _countries.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) => setState(() => _selectedCountry = newValue),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please select country' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Time zone',
                  border: OutlineInputBorder(),
                ),
                value: _selectedTimeZone,
                items: _timeZones.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) => setState(() => _selectedTimeZone = newValue),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please select time zone' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _saveTeamToFirestore();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('SAVE', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
