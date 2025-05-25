// lib/fixtures/fixtures.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum FixtureFilter { past, today, upcoming }

// NEW: Enum for different league types
enum LeagueType {
  mensDivision('Mens Division'),
  womensDivision('Womens Division'),
  indoorHockey('Indoor Hockey'),
  outdoorHockey('Outdoor Hockey');

  final String displayName;
  const LeagueType(this.displayName);
}

// NEW: Enum for league filter options (including 'All')
enum LeagueFilter {
  all('All'),
  mensDivision('Mens Division'),
  womensDivision('Womens Division'),
  indoorHockey('Indoor Hockey'),
  outdoorHockey('Outdoor Hockey');

  final String displayName;
  const LeagueFilter(this.displayName);
}


class FixturesPage extends StatefulWidget {
  const FixturesPage({super.key});

  @override
  State<FixturesPage> createState() => _FixturesPageState();
}

class _FixturesPageState extends State<FixturesPage> {
  final CollectionReference _fixtures =
      FirebaseFirestore.instance.collection('Fixtures'); // Ensure 'Fixtures' is correct

  // Text editing controllers for the input fields
  final TextEditingController _team1NameController = TextEditingController();
  final TextEditingController _team2NameController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // State variable for the selected filter (Past, Today, Upcoming)
  FixtureFilter _selectedFixtureFilter = FixtureFilter.upcoming; // Default to upcoming

  // NEW: State variable for the selected league type during creation/editing
  LeagueType? _selectedLeagueType;

  // NEW: State variable for the selected league filter
  LeagueFilter _selectedLeagueFilter = LeagueFilter.all; // Default to 'All'

  @override
  void dispose() {
    _team1NameController.dispose();
    _team2NameController.dispose();
    _timeController.dispose();
    _dateController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _upsertFixture([DocumentSnapshot? documentSnapshot]) async {
     if (documentSnapshot != null) {
      final data = documentSnapshot.data() as Map<String, dynamic>;
      _team1NameController.text = data['team1Name'];
      _team2NameController.text = data['team2Name'];
      _timeController.text = data['time'];
      _dateController.text = data['date'];
      _durationController.text = data['durationMinutes']?.toString() ?? '';
      _selectedDate = DateTime.tryParse(data['date']);
      List<String> timeParts = data['time'].split(':');
      if (timeParts.length == 2) {
        _selectedTime =
            TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
      }
      // NEW: Set selected league type for editing
      final String? existingLeagueType = data['leagueType'];
      _selectedLeagueType = null; // Initialize to null
      if (existingLeagueType != null) {
        try {
          _selectedLeagueType = LeagueType.values.firstWhere(
            (e) => e.displayName == existingLeagueType,
            // If not found, _selectedLeagueType remains null, which is fine as it's nullable.
            // No need for orElse here if we want it to be null if not found.
          );
        } catch (e) {
          // Handle case where existingLeagueType might not match any enum value
          // print('Warning: Invalid leagueType from Firestore: $existingLeagueType');
          _selectedLeagueType = null;
        }
      }

    } else {
      // Clear controllers for new fixture
      _team1NameController.text = '';
      _team2NameController.text = '';
      _timeController.text = '';
      _dateController.text = '';
      _durationController.text = '';
      _selectedDate = null;
      _selectedTime = null;
      _selectedLeagueType = null; // NEW: Clear selected league type for new fixture
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder( // Use StatefulBuilder to update dropdown in modal
          builder: (BuildContext context, StateSetter setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _team1NameController,
                    decoration: const InputDecoration(labelText: 'Team 1 Name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _team2NameController,
                    decoration: const InputDecoration(labelText: 'Team 2 Name'),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _selectDate(ctx),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _selectTime(ctx),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _timeController,
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          suffixIcon: Icon(Icons.access_time),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Match Duration (minutes)'),
                  ),
                  const SizedBox(height: 10),
                  // NEW: Dropdown for League Type
                  DropdownButtonFormField<LeagueType>(
                    value: _selectedLeagueType,
                    decoration: const InputDecoration(
                      labelText: 'League Type',
                      border: OutlineInputBorder(),
                    ),
                    items: LeagueType.values.map((LeagueType league) {
                      return DropdownMenuItem<LeagueType>(
                        value: league,
                        child: Text(league.displayName),
                      );
                    }).toList(),
                    onChanged: (LeagueType? newValue) {
                      setStateModal(() { // Use setStateModal for the modal's state
                        _selectedLeagueType = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a league type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    child: Text(documentSnapshot == null ? 'Create' : 'Update'),
                    onPressed: () async {
                      final String team1Name = _team1NameController.text;
                      final String team2Name = _team2NameController.text;
                      final String time = _timeController.text;
                      final String date = _dateController.text;
                      final String durationText = _durationController.text;
                      final int? durationMinutes = int.tryParse(durationText);

                      if (team1Name.isNotEmpty &&
                          team2Name.isNotEmpty &&
                          time.isNotEmpty &&
                          date.isNotEmpty &&
                          durationMinutes != null &&
                          durationMinutes > 0 &&
                          _selectedLeagueType != null) { // NEW: Validate league type
                        final DateTime fixtureDate = DateTime.parse(date);
                        List<String> timeParts = time.split(':');
                        final DateTime scheduledStart = DateTime(
                          fixtureDate.year,
                          fixtureDate.month,
                          fixtureDate.day,
                          int.parse(timeParts[0]),
                          int.parse(timeParts[1]),
                        );

                        final DateTime scheduledEnd =
                            scheduledStart.add(Duration(minutes: durationMinutes));

                        Map<String, dynamic> fixtureData = {
                          'team1Name': team1Name,
                          'team2Name': team2Name,
                          'time': time,
                          'date': date,
                          'timestamp': Timestamp.fromDate(scheduledStart),
                          'durationMinutes': durationMinutes,
                          'scheduledEndTimeStamp': Timestamp.fromDate(scheduledEnd),
                          'matchStatus': 'scheduled',
                          'score': '0 - 0', // Always initialize with default score
                          'leagueType': _selectedLeagueType!.displayName, // NEW: Save league type
                        };

                        if (documentSnapshot == null) {
                          await _fixtures.add(fixtureData);
                        } else {
                          await _fixtures.doc(documentSnapshot.id).update(fixtureData);
                        }

                        _team1NameController.text = '';
                        _team2NameController.text = '';
                        _timeController.text = '';
                        _dateController.text = '';
                        _durationController.text = '';
                        _selectedLeagueType = null; // NEW: Clear selected league type
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please fill in all fields, ensure duration is a positive number, and select a league type.')),
                        );
                      }
                    },
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteFixture(String fixtureId) async {
    await _fixtures.doc(fixtureId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You have successfully deleted a fixture')),
    );
  }

  // --- NEW: Score Update Dialog Function (Unchanged) ---
  Future<void> _showScoreUpdateDialog(DocumentSnapshot fixtureDocument) async {
    final data = fixtureDocument.data() as Map<String, dynamic>;
    final String currentScore = data['score'] ?? '0 - 0';
    final String team1Name = data['team1Name'] ?? 'Team 1';
    final String team2Name = data['team2Name'] ?? 'Team 2';

    TextEditingController team1ScoreController = TextEditingController();
    TextEditingController team2ScoreController = TextEditingController();

    // Pre-fill with current scores if available
    final List<String> scoreParts = currentScore.split(' - ');
    if (scoreParts.length == 2) {
      team1ScoreController.text = scoreParts[0].trim();
      team2ScoreController.text = scoreParts[1].trim();
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Score'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Match: $team1Name vs $team2Name'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: team1ScoreController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '$team1Name Score',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const Text(' - ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: TextField(
                      controller: team2ScoreController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '$team2Name Score',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Update'),
              onPressed: () async {
                final int? team1Score = int.tryParse(team1ScoreController.text);
                final int? team2Score = int.tryParse(team2ScoreController.text);

                if (team1Score != null && team2Score != null && team1Score >= 0 && team2Score >= 0) {
                  await _fixtures.doc(fixtureDocument.id).update({
                    'score': '$team1Score - $team2Score',
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Score updated successfully!')),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid, non-negative scores.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
  // --- END: Score Update Dialog Function ---


  // Method to get the filtered stream based on _selectedFixtureFilter and _selectedLeagueFilter
  Stream<QuerySnapshot> _getFilteredFixturesStream() {
    DateTime now = DateTime.now();
    DateTime todayStart = DateTime(now.year, now.month, now.day);
    DateTime todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    Query query = _fixtures;

    // Apply fixture filter (Past, Today, Upcoming)
    switch (_selectedFixtureFilter) {
      case FixtureFilter.past:
        query = query
            .where('scheduledEndTimeStamp', isLessThan: Timestamp.fromDate(todayStart))
            .orderBy('scheduledEndTimeStamp', descending: true); // Most recent past first
        break;
      case FixtureFilter.today:
        query = query
            .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
            .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(todayEnd))
            .orderBy('timestamp', descending: false);
        break;
      case FixtureFilter.upcoming:
        query = query
            .where('timestamp', isGreaterThan: Timestamp.fromDate(todayEnd))
            .orderBy('timestamp', descending: false);
        break;
    }

    // NEW: Apply league filter
    if (_selectedLeagueFilter != LeagueFilter.all) {
      query = query.where('leagueType', isEqualTo: _selectedLeagueFilter.displayName);
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixtures'),
        backgroundColor: const Color(0xFF144781),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SegmentedButton<FixtureFilter>(
                  segments: const <ButtonSegment<FixtureFilter>>[
                    ButtonSegment<FixtureFilter>(
                      value: FixtureFilter.past,
                      label: Text('Past'),
                      icon: Icon(Icons.history),
                    ),
                    ButtonSegment<FixtureFilter>(
                      value: FixtureFilter.today,
                      label: Text('Today'),
                      icon: Icon(Icons.calendar_today),
                    ),
                    ButtonSegment<FixtureFilter>(
                      value: FixtureFilter.upcoming,
                      label: Text('Upcoming'),
                      icon: Icon(Icons.event_note),
                    ),
                  ],
                  selected: <FixtureFilter>{_selectedFixtureFilter},
                  onSelectionChanged: (Set<FixtureFilter> newSelection) {
                    setState(() {
                      _selectedFixtureFilter = newSelection.first;
                    });
                  },
                  style: SegmentedButton.styleFrom(
                    foregroundColor: const Color(0xFF144781), // Color for selected text/icon
                    selectedForegroundColor: Colors.white,
                    selectedBackgroundColor: const Color(0xFF144781), // Background for selected
                    side: const BorderSide(color: Color(0xFF144781)), // Border color
                  ),
                ),
                const SizedBox(height: 10), // Spacing between the two filter buttons
                // NEW: Segmented button for League Filter
                SingleChildScrollView( // Use SingleChildScrollView for horizontal scrolling if many options
                  scrollDirection: Axis.horizontal,
                  child: SegmentedButton<LeagueFilter>(
                    segments: LeagueFilter.values.map((LeagueFilter league) {
                      return ButtonSegment<LeagueFilter>(
                        value: league,
                        label: Text(league.displayName),
                      );
                    }).toList(),
                    selected: <LeagueFilter>{_selectedLeagueFilter},
                    onSelectionChanged: (Set<LeagueFilter> newSelection) {
                      setState(() {
                        _selectedLeagueFilter = newSelection.first;
                      });
                    },
                    style: SegmentedButton.styleFrom(
                      foregroundColor: const Color(0xFF144781),
                      selectedForegroundColor: Colors.white,
                      selectedBackgroundColor: const Color(0xFF144781),
                      side: const BorderSide(color: Color(0xFF144781)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _getFilteredFixturesStream(), // Use the new filtered stream
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.hasError) {
                  return Center(child: Text('Error: ${streamSnapshot.error}'));
                }

                if (streamSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No ${_selectedFixtureFilter.name} fixtures found for ${_selectedLeagueFilter.displayName}.'),
                  );
                }

                return ListView.builder(
                  itemCount: streamSnapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot =
                        streamSnapshot.data!.docs[index];
                    final data = documentSnapshot.data() as Map<String, dynamic>;
                    final String team1Name = data['team1Name'] ?? 'N/A';
                    final String team2Name = data['team2Name'] ?? 'N/A';
                    final String time = data['time'] ?? 'N/A';
                    final String date = data['date'] ?? 'N/A';
                    final String matchStatus = data['matchStatus'] ?? 'scheduled';
                    final String score = data['score'] ?? '0 - 0';
                    final String leagueType = data['leagueType'] ?? 'N/A'; // NEW: Get league type

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text('$team1Name vs $team2Name'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: $date'),
                            Text('Time: $time'),
                            Text('League: $leagueType'), // NEW: Display league type
                            Text('Status: ${matchStatus.toUpperCase()}'),
                            Text('Score: $score'),
                          ],
                        ),
                        trailing: SizedBox(
                          width: 150, // Increased width to accommodate 3 buttons
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // Use minimum space
                            children: [
                              IconButton(
                                onPressed: () => _showScoreUpdateDialog(documentSnapshot), // NEW SCORE BUTTON
                                icon: const Icon(Icons.score, color: Colors.green),
                                tooltip: 'Update Score',
                              ),
                              IconButton(
                                onPressed: () => _upsertFixture(documentSnapshot),
                                icon: const Icon(Icons.edit),
                                tooltip: 'Edit Fixture',
                              ),
                              IconButton(
                                onPressed: () =>
                                    _deleteFixture(documentSnapshot.id),
                                icon: const Icon(Icons.delete),
                                tooltip: 'Delete Fixture',
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF144781),
        onPressed: () => _upsertFixture(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}