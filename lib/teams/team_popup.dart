import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateTeamPopup extends StatefulWidget {
  const CreateTeamPopup({super.key});

  @override
  State<CreateTeamPopup> createState() => _CreateTeamPopupState();
}

class _CreateTeamPopupState extends State<CreateTeamPopup> {
  final _formKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();
  final _logoUrlController = TextEditingController();
  String? _ageGroup, _country, _timezone;

  final List<String> _ages = ['U10', 'U12', 'U14', 'U16', 'Senior'];
  final List<String> _countries = ['Namibia', 'South Africa', 'Botswana'];
  final List<String> _timezones = ['UTC+2', 'UTC+1', 'UTC'];

  Future<void> _saveTeam() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('Teams').add({
      'teamName': _teamNameController.text.trim(),
      'logoUrl': _logoUrlController.text.trim(),
      'teamAge': _ageGroup,
      'country': _country,
      'timeZone': _timezone,
      'uid': uid,
      'createdAt': Timestamp.now(),
    });

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Team'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _teamNameController,
                decoration: const InputDecoration(labelText: 'Team Name'),
                validator:
                    (val) =>
                        val == null || val.isEmpty ? 'Enter team name' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _logoUrlController,
                decoration: const InputDecoration(
                  labelText: 'Logo URL (for scoreboard)',
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Age Group'),
                items:
                    _ages
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => setState(() => _ageGroup = val),
                validator: (val) => val == null ? 'Select age group' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Country'),
                items:
                    _countries
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => setState(() => _country = val),
                validator: (val) => val == null ? 'Select country' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Time Zone'),
                items:
                    _timezones
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => setState(() => _timezone = val),
                validator: (val) => val == null ? 'Select time zone' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) _saveTeam();
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
