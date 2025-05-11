import 'package:flutter/material.dart';

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

  // Example lists for dropdowns - replace with your actual data
  final List<String> _ageRanges = ['U/10', 'U/12', 'U/14', 'U/16', 'U/19', 'U/20', 'Adult'];
  final List<String> _countries = ['Namibia', 'South Africa', 'Botswana', 'Zimbabwe', 'Angola']; // Example countries
  final List<String> _timeZones = ['UTC+00:00', 'UTC+01:00', 'UTC+02:00']; // Example time zones

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
      content: SingleChildScrollView(
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter team name';
                  }
                  return null;
                },
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
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTeamAge = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select team age';
                  }
                  return null;
                },
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
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCountry = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select country';
                  }
                  return null;
                },
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
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTimeZone = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select time zone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Implement the logic to save the team data
                    String teamName = _teamNameController.text;
                    print('Team Name: $teamName, Age: $_selectedTeamAge, Country: $_selectedCountry, Time Zone: $_selectedTimeZone');
                    Navigator.of(context).pop(); // Close the popup after saving
                    // You might want to pass the new team data back to the previous screen
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
    );
  }
}