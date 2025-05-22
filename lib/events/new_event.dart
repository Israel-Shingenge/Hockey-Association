import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNewEventPage extends StatefulWidget {
  const AddNewEventPage({super.key});

  @override
  State<AddNewEventPage> createState() => _AddNewEventPageState();
}

class _AddNewEventPageState extends State<AddNewEventPage> {
  final _eventNameController = TextEditingController();
  String? _selectedTimeZone;
  DateTime? _selectedDateTime;
  String _repeats = 'Does Not Repeat';

  final _locationController = TextEditingController();
  final _durationController = TextEditingController();

  String? _selectedVolunteerAssignment;
  final _notesController = TextEditingController();
  bool _notifyTeam = false;

  // Dispose controllers to prevent memory leaks
  @override
  void dispose() {
    _eventNameController.dispose();
    _locationController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
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

  Future<void> _selectRepeats(BuildContext context) async {
    final String? selectedRepeat = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Repeats'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ListTile(
                    title: const Text('Does Not Repeat'),
                    onTap: () => Navigator.pop(context, 'Does Not Repeat')),
                ListTile(title: const Text('Daily'), onTap: () => Navigator.pop(context, 'Daily')),
                ListTile(title: const Text('Weekly'), onTap: () => Navigator.pop(context, 'Weekly')),
                ListTile(title: const Text('Monthly'), onTap: () => Navigator.pop(context, 'Monthly')),
                ListTile(title: const Text('Yearly'), onTap: () => Navigator.pop(context, 'Yearly')),
              ],
            ),
          ),
        );
      },
    );
    if (selectedRepeat != null && selectedRepeat != _repeats) {
      setState(() {
        _repeats = selectedRepeat;
      });
    }
  }

  //    Instead, direct text input is used in the build method.

  Future<void> _selectVolunteerAssignment(BuildContext context) async {
    final String? assignment = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Voluntary Assignment'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ListTile(title: const Text('Coach'), onTap: () => Navigator.pop(context, 'Coach')),
                ListTile(title: const Text('Referee'), onTap: () => Navigator.pop(context, 'Referee')),
                ListTile(title: const Text('Scorekeeper'), onTap: () => Navigator.pop(context, 'Scorekeeper')),
                ListTile(title: const Text('Photographer'), onTap: () => Navigator.pop(context, 'Photographer')), // Corrected typo
                ListTile(title: const Text('Videographer'), onTap: () => Navigator.pop(context, 'Videographer')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ],
        );
      },
    );
    if (assignment != null) {
      setState(() {
        _selectedVolunteerAssignment = assignment;
      });
    }
  }

  Future<void> _saveEventToFirestore() async {
    if (_eventNameController.text.isEmpty || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields.')),
      );
      return;
    }

    final gameData = {
      'nameOfEvent': _eventNameController.text,
      'timeZone': _selectedTimeZone ?? 'UTC+1', // Default if not selected
      'date': Timestamp.fromDate(_selectedDateTime!),
      'repeats': _repeats,
      'location': _locationController.text, 
      'volunteerAssignments': _selectedVolunteerAssignment ?? '',
      'duration': _durationController.text, 
      'notifyTeam': _notifyTeam,
      'notes': _notesController.text,
      'createdAt': Timestamp.now(),
      'league': 'Dunes', // Hardcoded as per your existing code
    };

    try {
      await FirebaseFirestore.instance.collection('Events').add(gameData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create event: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        title: const Text('Add Event'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: _saveEventToFirestore,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('Notify Team'),
                Switch(
                  value: _notifyTeam,
                  onChanged: (bool value) {
                    setState(() {
                      _notifyTeam = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _eventNameController,
              decoration: const InputDecoration(
                labelText: 'Name of Event',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Time Zone',
                border: OutlineInputBorder(),
                hintText: 'Please Select',
              ),
              readOnly: true,
              onTap: () {
                // Optional time zone logic (you can implement a time zone picker here)
              },
            ),
            const SizedBox(height: 16.0),
            InkWell(
              onTap: () => _selectDateTime(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date/Time',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(_selectedDateTime == null
                        ? 'Please Select'
                        : DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime!)),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            InkWell(
              onTap: () => _selectRepeats(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Repeats',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(_repeats),
                    const Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
                hintText: 'e.g., Nust basket ball court ', // Added hint
              ),
            ),
            const SizedBox(height: 16.0),

            InkWell(
              onTap: () => _selectVolunteerAssignment(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Volunteer Assignments',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(_selectedVolunteerAssignment ?? 'Please select'),
                    const Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration',
                border: OutlineInputBorder(),
                hintText: 'e.g., 2 hours, 90 minutes', // Added hint
              ),
              keyboardType: TextInputType.text, // Allows text input for "2 hours" etc.
            ),
            const SizedBox(height: 16.0),

            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}