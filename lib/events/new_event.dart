import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddNewEventPage extends StatefulWidget {
  const AddNewEventPage({super.key});

  @override
  State<AddNewEventPage> createState() => _AddNewEventPageState();
}

class _AddNewEventPageState extends State<AddNewEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDateTime;

  String? _selectedTimeZone;
  String? _selectedLocation;
  String? _selectedAssignment;
  String? _selectedDuration;
  String _repeat = 'Does Not Repeat';
  bool _notifyTeam = false;

  Future<void> _selectDateTime() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate() || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('Events').add({
        'nameOfEvent': _eventNameController.text,
        'date': _selectedDateTime?.toIso8601String(),
        'timeZone': _selectedTimeZone ?? '',
        'location': _selectedLocation ?? '',
        'repeat': _repeat,
        'volunteerAssignments': _selectedAssignment ?? '',
        'duration': _selectedDuration ?? '',
        'notes': _notesController.text,
        'notifyTeam': _notifyTeam,
        'createdAt': Timestamp.now(),
      });

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save event: $e')));
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
      appBar: AppBar(title: const Text('Add Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _eventNameController,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
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
                    labelText: 'Date/Time',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDateTime == null
                        ? 'Please select'
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
                'Volunteer Assignment',
                ['Coach', 'Referee', 'Photographer'],
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
                'Repeats',
                ['Does Not Repeat', 'Daily', 'Weekly', 'Monthly', 'Yearly'],
                _repeat,
                (val) => setState(() => _repeat = val ?? ''),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF060F7A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'SAVE EVENT',
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
