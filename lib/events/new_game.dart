import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddGamePage extends StatefulWidget {
  const AddGamePage({super.key});

  @override
  State<AddGamePage> createState() => _AddGamePageState();
}

class _AddGamePageState extends State<AddGamePage> {
  final _formKey = GlobalKey<FormState>();

  final _eventNameController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDateTime;

  String? _selectedTimeZone;
  String? _selectedLocation;
  String? _selectedAssignment;
  String? _selectedDuration;
  String? _selectedHomeAway;
  String? _selectedUniform;

  bool _notifyTeam = false;
  bool _notForStandings = false;

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2035),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveGame() async {
    if (!_formKey.currentState!.validate() || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('Game').add({
        'nameOfEvent': _eventNameController.text,
        'date': _selectedDateTime?.toIso8601String(),
        'timeZone': _selectedTimeZone ?? 'UTC+2',
        'location': _selectedLocation ?? '',
        'volunteerAssignments': _selectedAssignment ?? '',
        'duration': _selectedDuration ?? '',
        'homeAway': _selectedHomeAway ?? '',
        'uniform': _selectedUniform ?? '',
        'notifyTeam': _notifyTeam,
        'notForStandings': _notForStandings,
        'notes': _notesController.text,
        'createdAt': Timestamp.now(),
      });

      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Game saved successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save game: $e')));
    }
  }

  Widget _dropdownField(
    String label,
    List<String> items,
    String? selectedValue,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Game')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _eventNameController,
                decoration: const InputDecoration(
                  labelText: 'Game Title',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Required field'
                            : null,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _selectDateTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Game Date & Time',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDateTime == null
                        ? 'Select'
                        : DateFormat(
                          'yyyy-MM-dd HH:mm',
                        ).format(_selectedDateTime!),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _dropdownField(
                'Time Zone',
                ['UTC+1', 'UTC+2', 'UTC+3'],
                _selectedTimeZone,
                (val) => setState(() => _selectedTimeZone = val),
              ),
              const SizedBox(height: 12),
              _dropdownField(
                'Location',
                ['Field A', 'Field B', 'Gym'],
                _selectedLocation,
                (val) => setState(() => _selectedLocation = val),
              ),
              const SizedBox(height: 12),
              _dropdownField(
                'Assignment',
                ['Coach', 'Referee', 'Scorekeeper'],
                _selectedAssignment,
                (val) => setState(() => _selectedAssignment = val),
              ),
              const SizedBox(height: 12),
              _dropdownField(
                'Duration',
                ['1 Hour', '1.5 Hours', '2 Hours'],
                _selectedDuration,
                (val) => setState(() => _selectedDuration = val),
              ),
              const SizedBox(height: 12),
              _dropdownField(
                'Home/Away',
                ['Home', 'Away'],
                _selectedHomeAway,
                (val) => setState(() => _selectedHomeAway = val),
              ),
              const SizedBox(height: 12),
              _dropdownField(
                'Uniform',
                ['Home Uniform', 'Away Uniform'],
                _selectedUniform,
                (val) => setState(() => _selectedUniform = val),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Notify Team'),
                value: _notifyTeam,
                onChanged: (val) => setState(() => _notifyTeam = val),
              ),
              SwitchListTile(
                title: const Text('Not for Standings'),
                value: _notForStandings,
                onChanged: (val) => setState(() => _notForStandings = val),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF060F7A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'SAVE GAME',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
