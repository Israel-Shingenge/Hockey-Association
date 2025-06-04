import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NominatimService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org/search';

  static Future<List<NominatimPlace>> fetchSuggestions(String query) async {
    final url = Uri.parse(
      '$_baseUrl?q=$query&format=json&addressdetails=1&countrycodes=na&limit=5',
    );

    final response = await http.get(url, headers: {
      'User-Agent': 'HockeyUnion - israelrshingene@gmail.com',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => NominatimPlace.fromJson(e)).toList();
    } else {
      print('Failed to fetch suggestions: ${response.statusCode} - ${response.body}');
      return [];
    }
  }
}

class NominatimPlace {
  final String displayName;
  final double lat;
  final double lon;

  NominatimPlace({
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  factory NominatimPlace.fromJson(Map<String, dynamic> json) {
    return NominatimPlace(
      displayName: json['display_name'],
      lat: double.parse(json['lat']),
      lon: double.parse(json['lon']),
    );
  }
}

class AddNewEventPage extends StatefulWidget {
  const AddNewEventPage({super.key});

  @override
  State<AddNewEventPage> createState() => _AddNewEventPageState();
}

class _AddNewEventPageState extends State<AddNewEventPage> {
  final _eventNameController = TextEditingController();
  DateTime? _selectedDateTime;
  String _repeats = 'Does Not Repeat';
  final _locationController = TextEditingController();
  final _durationController = TextEditingController();
  String? _selectedVolunteerAssignment;
  final _notesController = TextEditingController();

  // New variables for autocomplete
  List<NominatimPlace> _suggestions = [];
  bool _isLoadingSuggestions = false;
  NominatimPlace? _selectedPlace; // Stores the selected suggestion

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
                ListTile(title: const Text('Does Not Repeat'), onTap: () => Navigator.pop(context, 'Does Not Repeat')),
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
                ListTile(title: const Text('Photographer'), onTap: () => Navigator.pop(context, 'Photographer')),
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
    // Basic validation for event name and date/time
    if (_eventNameController.text.isEmpty || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields (Event Name and Date/Time).')),
      );
      return;
    }

    if (_locationController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a location for the event.')),
      );
      return;
    }

    final gameData = {
      'nameOfEvent': _eventNameController.text,
      'date': Timestamp.fromDate(_selectedDateTime!),
      'repeats': _repeats,
      'location': _locationController.text, 
      'latitude': _selectedPlace?.lat, 
      'longitude': _selectedPlace?.lon, 
      'volunteerAssignments': _selectedVolunteerAssignment ?? '',
      'duration': _durationController.text,
      'notes': _notesController.text,
      'createdAt': Timestamp.now(),
    };

    try {
      await FirebaseFirestore.instance.collection('events').add(gameData);

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
        backgroundColor: const Color.fromARGB(255, 23, 52, 129),
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
            TextFormField(
              controller: _eventNameController,
              decoration: const InputDecoration(
                labelText: 'Name of Event',
                border: OutlineInputBorder(),
              ),
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
            // Location with autocomplete suggestions
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                    hintText: 'Start typing location...',
                  ),
                  onChanged: (value) async {
                    if (_selectedPlace != null) {
                      setState(() {
                        _selectedPlace = null;
                      });
                    }

                    if (value.length < 3) {
                      setState(() {
                        _suggestions = [];
                        _isLoadingSuggestions = false; 
                      });
                      return;
                    }
                    setState(() {
                      _isLoadingSuggestions = true;
                    });
                    try {
                      final results = await NominatimService.fetchSuggestions(value);
                      setState(() {
                        _suggestions = results;
                        _isLoadingSuggestions = false;
                      });
                    } catch (e) {
                      setState(() {
                        _suggestions = [];
                        _isLoadingSuggestions = false;
                      });
                      // Optionally show a snackbar for the user if fetching fails
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(content: Text('Failed to fetch location suggestions.')),
                      // );
                    }
                  },
                ),
                if (_isLoadingSuggestions)
                  const LinearProgressIndicator(),
                if (!_isLoadingSuggestions && _suggestions.isNotEmpty)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 200), 
                    child: ListView.builder(
                      shrinkWrap: true, 
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final place = _suggestions[index];
                        return ListTile(
                          title: Text(place.displayName),
                          onTap: () {
                            setState(() {
                              _locationController.text = place.displayName;
                              _selectedPlace = place; // Set the selected place
                              _suggestions = []; 
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16.0),
            InkWell(
              onTap: () => _selectVolunteerAssignment(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Volunteer Assignment',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(_selectedVolunteerAssignment ?? 'Select Volunteer Assignment'),
                    const Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (e.g., 2 hours)', 
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text, 
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}