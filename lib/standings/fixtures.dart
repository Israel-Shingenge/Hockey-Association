import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart';

enum FixtureFilter { past, today, upcoming }

enum LeagueType {
  mensDivision('Mens Division'),
  womensDivision('Womens Division');

  final String displayName;
  const LeagueType(this.displayName);
}

enum LeagueFilter {
  all('All'),
  mensDivision('Mens Division'),
  womensDivision('Womens Division');

  final String displayName;
  const LeagueFilter(this.displayName);
}

class FixturesPage extends StatefulWidget {
  const FixturesPage({super.key});

  @override
  State<FixturesPage> createState() => _FixturesPageState();
}

class _FixturesPageState extends State<FixturesPage> {
  final CollectionReference _fixturesCollection =
      FirebaseFirestore.instance.collection('Fixtures');
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

  final TextEditingController _team1NameController = TextEditingController();
  final TextEditingController _team2NameController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  FixtureFilter _selectedFixtureFilter = FixtureFilter.upcoming;
  LeagueFilter _selectedLeagueFilter = LeagueFilter.all;
  LeagueType? _selectedLeagueType;

  // --- Role Management from TeamPage ---
  String? _userRole; // Changed to nullable string for initial state
  bool _loadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole(); // Call the role loading function
    // Listen for auth state changes to update the user role
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _fetchUserRole(user.uid);
      } else {
        setState(() {
          _userRole = 'player'; // No user, or logged out
        });
      }
    });
  }

  // --- Role Management from TeamPage ---
  Future<void> _loadUserRole() async {
    print('*** _loadUserRole for FixturesPage started');
    try {
      final user = _auth.currentUser; 
      if (user == null) {
        print('No logged-in user found.');
        setState(() {
          _userRole = null;
          _loadingRole = false;
        });
        return;
      }

      print('Fetching user role for uid: ${user.uid}');
      await _fetchUserRole(user.uid); // Call the helper to fetch the role
    } catch (e, st) {
      print('Error fetching user role: $e');
      print('Stack trace: $st');
      setState(() {
        _userRole = 'player'; // fallback role on error
        _loadingRole = false;
      });
    }
    print('*** _loadUserRole for FixturesPage ended');
  }

  Future<void> _fetchUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('Users').doc(uid).get(); // Use _firestore instance
      if (!doc.exists) {
        print('User document does not exist for uid: $uid');
        setState(() {
          _userRole = 'player'; // fallback role
          _loadingRole = false;
        });
        return;
      }

      final role = doc.data()?['role'] as String?;
      print('Role fetched from Firestore: $role');

      setState(() {
        _userRole = role ?? 'player'; // Default to player if no role found
        _loadingRole = false;
      });
      print('User role set to: $_userRole');
    } catch (e) {
      print("Error fetching user role: $e");
      setState(() {
        _userRole = 'player'; // On error, default to player
        _loadingRole = false;
      });
    }
  }

  bool get _isAdmin => _userRole == 'Admin'; 

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
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked == null || picked == _selectedDate) return;
    setState(() {
      _selectedDate = picked;
      _dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked == null || picked == _selectedTime) return;
    setState(() {
      _selectedTime = picked;
      _timeController.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
    });
  }

  Future<void> _upsertFixture([DocumentSnapshot? documentSnapshot]) async {
    // --- Admin check ---
    if (!_isAdmin) {
      _showSnackBar('You do not have permission to create or update fixtures.');
      return;
    }

    if (documentSnapshot != null) {
      final data = documentSnapshot.data() as Map<String, dynamic>;
      _team1NameController.text = data['team1Name'] ?? '';
      _team2NameController.text = data['team2Name'] ?? '';
      _timeController.text = data['time'] ?? '';
      _dateController.text = data['date'] ?? '';
      _durationController.text = data['durationMinutes']?.toString() ?? '';

      _selectedDate = DateTime.tryParse(data['date'] ?? '');
      final timeParts = (data['time'] as String?)?.split(':');
      if (timeParts?.length == 2) {
        _selectedTime = TimeOfDay(hour: int.tryParse(timeParts![0]) ?? 0, minute: int.tryParse(timeParts[1]) ?? 0);
      }
      _selectedLeagueType = LeagueType.values.firstWhere(
        (e) => e.displayName == data['leagueType'],
        orElse: () => LeagueType.mensDivision,
      );
    } else {
      _team1NameController.clear();
      _team2NameController.clear();
      _timeController.clear();
      _dateController.clear();
      _durationController.clear();
      _selectedDate = _selectedTime = _selectedLeagueType = null;
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) => Padding(
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
              TextField(controller: _team1NameController, decoration: const InputDecoration(labelText: 'Team 1 Name')),
              const SizedBox(height: 10),
              TextField(controller: _team2NameController, decoration: const InputDecoration(labelText: 'Team 2 Name')),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _selectDate(ctx),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(labelText: 'Date', suffixIcon: Icon(Icons.calendar_today)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _selectTime(ctx),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _timeController,
                    decoration: const InputDecoration(labelText: 'Time', suffixIcon: Icon(Icons.access_time)),
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
              DropdownButtonFormField<LeagueType>(
                value: _selectedLeagueType,
                decoration: const InputDecoration(labelText: 'League Type', border: OutlineInputBorder()),
                items: LeagueType.values.map((league) => DropdownMenuItem(value: league, child: Text(league.displayName))).toList(),
                onChanged: (newValue) => setStateModal(() => _selectedLeagueType = newValue),
                validator: (value) => value == null ? 'Please select a league type' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final team1Name = _team1NameController.text.trim();
                  final team2Name = _team2NameController.text.trim();
                  final time = _timeController.text.trim();
                  final date = _dateController.text.trim();
                  final durationMinutes = int.tryParse(_durationController.text.trim());

                  if (team1Name.isEmpty || team2Name.isEmpty || time.isEmpty || date.isEmpty || durationMinutes == null || durationMinutes <= 0 || _selectedLeagueType == null) {
                    _showSnackBar('Please fill in all fields, ensure duration is a positive number, and select a league type.');
                    return;
                  }

                  final fixtureDate = DateTime.tryParse(date);
                  final timeParts = time.split(':');
                  if (fixtureDate == null || timeParts.length != 2) {
                    _showSnackBar('Invalid date or time format.');
                    return;
                  }

                  final hour = int.tryParse(timeParts[0]);
                  final minute = int.tryParse(timeParts[1]);
                  if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
                    _showSnackBar('Invalid time (HH:MM) format.');
                    return;
                  }

                  final scheduledStart = DateTime(fixtureDate.year, fixtureDate.month, fixtureDate.day, hour, minute);
                  final scheduledEnd = scheduledStart.add(Duration(minutes: durationMinutes));

                  final fixtureData = {
                    'team1Name': team1Name,
                    'team2Name': team2Name,
                    'time': time,
                    'date': date,
                    'timestamp': Timestamp.fromDate(scheduledStart),
                    'durationMinutes': durationMinutes,
                    'scheduledEndTimeStamp': Timestamp.fromDate(scheduledEnd),
                    'matchStatus': 'scheduled',
                    'score': '0 - 0',
                    'leagueType': _selectedLeagueType!.displayName,
                  };

                  if (documentSnapshot == null) {
                    await _fixturesCollection.add(fixtureData);
                  } else {
                    await _fixturesCollection.doc(documentSnapshot.id).update(fixtureData);
                  }

                  _team1NameController.clear();
                  _team2NameController.clear();
                  _timeController.clear();
                  _dateController.clear();
                  _durationController.clear();
                  _selectedLeagueType = _selectedDate = _selectedTime = null;

                  if (mounted) Navigator.pop(context);
                },
                child: Text(documentSnapshot == null ? 'Create' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _deleteFixture(String fixtureId) async {
    // --- Admin check ---
    if (!_isAdmin) {
      _showSnackBar('You do not have permission to delete fixtures.');
      return;
    }

    await _fixturesCollection.doc(fixtureId).delete();
    _showSnackBar('You have successfully deleted a fixture');
  }

  Future<void> _showScoreUpdateDialog(DocumentSnapshot fixtureDocument) async {
    // --- Admin check ---
    if (!_isAdmin) {
      _showSnackBar('You do not have permission to update scores.');
      return;
    }

    final data = fixtureDocument.data() as Map<String, dynamic>;
    final currentScore = data['score'] ?? '0 - 0';
    final team1Name = data['team1Name'] ?? 'Team 1';
    final team2Name = data['team2Name'] ?? 'Team 2';

    final team1ScoreController = TextEditingController();
    final team2ScoreController = TextEditingController();

    final scoreParts = currentScore.split(' - ');
    if (scoreParts.length == 2) {
      team1ScoreController.text = scoreParts[0].trim();
      team2ScoreController.text = scoreParts[1].trim();
    }

    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
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
                    decoration: InputDecoration(labelText: '$team1Name Score', border: const OutlineInputBorder()),
                  ),
                ),
                const Text(' - ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Expanded(
                  child: TextField(
                    controller: team2ScoreController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: '$team2Name Score', border: const OutlineInputBorder()),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
          ElevatedButton(
            child: const Text('Update'),
            onPressed: () async {
              final team1Score = int.tryParse(team1ScoreController.text);
              final team2Score = int.tryParse(team2ScoreController.text);

              if (team1Score != null && team2Score != null && team1Score >= 0 && team2Score >= 0) {
                await _fixturesCollection.doc(fixtureDocument.id).update({'score': '$team1Score - $team2Score'});
                _showSnackBar('Score updated successfully!');
                if (mounted) Navigator.of(context).pop();
              } else {
                _showSnackBar('Please enter valid, non-negative scores.');
              }
            },
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredFixturesStream() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    Query query = _fixturesCollection;

    switch (_selectedFixtureFilter) {
      case FixtureFilter.past:
        query = query.where('scheduledEndTimeStamp', isLessThan: Timestamp.fromDate(todayStart)).orderBy('scheduledEndTimeStamp', descending: true);
        break;
      case FixtureFilter.today:
        query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart)).where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(todayEnd)).orderBy('timestamp', descending: false);
        break;
      case FixtureFilter.upcoming:
        query = query.where('timestamp', isGreaterThan: Timestamp.fromDate(todayEnd)).orderBy('timestamp', descending: false);
        break;
    }

    if (_selectedLeagueFilter != LeagueFilter.all) {
      query = query.where('leagueType', isEqualTo: _selectedLeagueFilter.displayName);
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    // --- Loading state for role ---
    if (_loadingRole) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                    ButtonSegment(value: FixtureFilter.past, label: Text('Past'), icon: Icon(Icons.history)),
                    ButtonSegment(value: FixtureFilter.today, label: Text('Today'), icon: Icon(Icons.calendar_today)),
                    ButtonSegment(value: FixtureFilter.upcoming, label: Text('Upcoming'), icon: Icon(Icons.event_note)),
                  ],
                  selected: {_selectedFixtureFilter},
                  onSelectionChanged: (newSelection) => setState(() => _selectedFixtureFilter = newSelection.first),
                  style: SegmentedButton.styleFrom(
                    foregroundColor: const Color(0xFF144781),
                    selectedForegroundColor: Colors.white,
                    selectedBackgroundColor: const Color(0xFF144781),
                    side: const BorderSide(color: Color(0xFF144781)),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SegmentedButton<LeagueFilter>(
                    segments: LeagueFilter.values.map((league) => ButtonSegment(value: league, label: Text(league.displayName))).toList(),
                    selected: {_selectedLeagueFilter},
                    onSelectionChanged: (newSelection) => setState(() => _selectedLeagueFilter = newSelection.first),
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
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredFixturesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No ${_selectedFixtureFilter.name} fixtures found for ${_selectedLeagueFilter.displayName}.'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final documentSnapshot = snapshot.data!.docs[index];
                    final data = documentSnapshot.data() as Map<String, dynamic>;

                    final team1Name = data['team1Name'] ?? 'N/A';
                    final team2Name = data['team2Name'] ?? 'N/A';
                    final time = data['time'] ?? 'N/A';
                    final date = data['date'] ?? 'N/A';
                    final matchStatus = data['matchStatus'] ?? 'scheduled';
                    final score = data['score'] ?? '0 - 0';
                    final leagueType = data['leagueType'] ?? 'N/A';

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text('$team1Name vs $team2Name'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: $date'),
                            Text('Time: $time'),
                            Text('League: $leagueType'),
                            Text('Status: ${matchStatus.toUpperCase()}'),
                            Text('Score: $score'),
                          ],
                        ),
                        trailing: _isAdmin // Only show action buttons if admin
                            ? SizedBox(
                                width: 150,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        icon: const Icon(Icons.score, color: Colors.green),
                                        onPressed: () => _showScoreUpdateDialog(documentSnapshot),
                                        tooltip: 'Update Score'),
                                    IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _upsertFixture(documentSnapshot),
                                        tooltip: 'Edit Fixture'),
                                    IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteFixture(documentSnapshot.id),
                                        tooltip: 'Delete Fixture'),
                                  ],
                                ),
                              )
                            : null, // Hide if not admin
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _isAdmin // Only show FAB if admin
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF144781),
              onPressed: () => _upsertFixture(),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null, // Hide if not admin
    );
  }
}