import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

class AddGamePage extends StatefulWidget {
  const AddGamePage({super.key});

  @override
  State<AddGamePage> createState() => _AddGamePageState();
}

class _AddGamePageState extends State<AddGamePage> {
  final _eventNameController = TextEditingController();
  String? _selectedTimeZone;
  DateTime? _selectedDateTime;
  String _repeats = 'Does Not Repeat';
  String? _selectedLocation;
  String? _selectedVolunteerAssignment;
  String? _selectedDuration;
  String? _selectedHomeAway;
  String? _selectedUniform;
  bool _notForStandings = false;
  final _notesController = TextEditingController();
  bool _notifyTeam = false;

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
                  onTap: () => Navigator.pop(context, 'Does Not Repeat'),
                ),
                ListTile(
                  title: const Text('Daily'),
                  onTap: () => Navigator.pop(context, 'Daily'),
                ),
                ListTile(
                  title: const Text('Weekly'),
                  onTap: () => Navigator.pop(context, 'Weekly'),
                ),
                ListTile(
                  title: const Text('Monthly'),
                  onTap: () => Navigator.pop(context, 'Monthly'),
                ),
                ListTile(
                  title: const Text('Yearly'),
                  onTap: () => Navigator.pop(context, 'Yearly'),
                ),
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

  Future<void> _selectLocation(BuildContext context) async {
    final String? location = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Location'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ListTile(title: const Text('Field A'), onTap: () => Navigator.pop(context, 'Field A')),
                ListTile(title: const Text('Field B'), onTap: () => Navigator.pop(context, 'Field B')),
                ListTile(title: const Text('Gym'), onTap: () => Navigator.pop(context, 'Gym')),
                // Add more locations
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
    if (location != null) {
      setState(() {
        _selectedLocation = location;
      });
    }
  }

  Future<void> _selectVolunteerAssignment(BuildContext context) async {
    final String? assignment = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Volunteer Assignment'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ListTile(title: const Text('Coach'), onTap: () => Navigator.pop(context, 'Coach')),
                ListTile(title: const Text('Referee'), onTap: () => Navigator.pop(context, 'Referee')),
                ListTile(title: const Text('Scorekeeper'), onTap: () => Navigator.pop(context, 'Scorekeeper')),
                // Add more assignments
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
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

  Future<void> _selectDuration(BuildContext context) async {
    final String? duration = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Duration'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ListTile(title: const Text('1 Hour'), onTap: () => Navigator.pop(context, '1 Hour')),
                ListTile(title: const Text('1.5 Hours'), onTap: () => Navigator.pop(context, '1.5 Hours')),
                ListTile(title: const Text('2 Hours'), onTap: () => Navigator.pop(context, '2 Hours')),
                // Add more durations
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
    if (duration != null) {
      setState(() {
        _selectedDuration = duration;
      });
    }
  }

  Future<void> _selectHomeAway(BuildContext context) async {
    final String? homeAway = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Home/Away'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ListTile(title: const Text('Home'), onTap: () => Navigator.pop(context, 'Home')),
                ListTile(title: const Text('Away'), onTap: () => Navigator.pop(context, 'Away')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
    if (homeAway != null) {
      setState(() {
        _selectedHomeAway = homeAway;
      });
    }
  }

  Future<void> _selectUniform(BuildContext context) async {
    final String? uniform = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Uniform'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ListTile(title: const Text('Home Uniform'), onTap: () => Navigator.pop(context, 'Home Uniform')),
                ListTile(title: const Text('Away Uniform'), onTap: () => Navigator.pop(context, 'Away Uniform')),
                ListTile(title: const Text('Alternate Uniform'), onTap: () => Navigator.pop(context, 'Alternate Uniform')),
                // Add more uniform options
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
    if (uniform != null) {
      setState(() {
        _selectedUniform = uniform;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Game'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              // Implement cancel logic
              Navigator.of(context).pop();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              // Implement save game logic
              print('Event Name: ${_eventNameController.text}');
              print('Time Zone: $_selectedTimeZone');
              print('Date/Time: $_selectedDateTime');
              print('Repeats: $_repeats');
              print('Location: $_selectedLocation');
              print('Volunteer Assignment: $_selectedVolunteerAssignment');
              print('Duration: $_selectedDuration');
              print('Home/Away: $_selectedHomeAway');
              print('Uniform: $_selectedUniform');
              print('Not for Standings: $_notForStandings');
              print('Notes: ${_notesController.text}');
              print('Notify Team: $_notifyTeam');
              // You would typically send this data to your backend or update local state
              Navigator.of(context).pop(); // Go back after saving
            },
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
            TextField( // Time Zone - Could be a dropdown in a real app
              decoration: const InputDecoration(
                labelText: 'Time Zone',
                border: OutlineInputBorder(),
                hintText: 'Please Select',
              ),
              readOnly: true,
              onTap: () {
                // Implement Time Zone selection
                print('Select Time Zone');
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
                    Text(
                      _selectedDateTime == null
                          ? 'Please Select'
                          : DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime!),
                    ),
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
            InkWell(
              onTap: () => _selectLocation(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(_selectedLocation ?? 'Please select'),
                    const Icon(Icons.arrow_forward_ios),
                  ],
                ),
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
            InkWell(
              onTap: () => _selectDuration(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Duration',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(_selectedDuration ?? 'Please select'),
                    const Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            InkWell(
              onTap: () => _selectHomeAway(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Home/Away',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(_selectedHomeAway ?? 'Please select'),
                    const Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            InkWell(
              onTap: () => _selectUniform(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Uniform',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(_selectedUniform ?? 'Please select'),
                    const Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('Not for Standings'),
                Switch(
                  value: _notForStandings,
                  onChanged: (bool value) {
                    setState(() {
                      _notForStandings = value;
                    });
                  },
                ),
              ],
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