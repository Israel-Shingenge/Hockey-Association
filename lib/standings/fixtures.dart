/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:hockey_union/home/home_drawer.dart'; // Assuming you have a HomeDrawer

class FixturesPage extends StatefulWidget {
  const FixturesPage({super.key});

  @override
  State<FixturesPage> createState() => _FixturesPageState();
}

class _FixturesPageState extends State<FixturesPage> {
  // Collection reference pointing to your 'fixtures' collection in Firestore.
  // Ensure this matches the exact case in your Firestore console.
  final CollectionReference _fixtures = FirebaseFirestore.instance.collection(
    'fixtures',
  );

  // State to manage the currently selected date for filtering fixtures.
  // Initialized to today to show today's fixtures by default.
  DateTime _selectedDate = DateTime.now();
  // A flag to indicate if we are in "Upcoming" or "Past" mode,
  // which implies showing events > _selectedDate or < _selectedDate.
  // 'day' means only events for that specific day.
  // 'upcoming' means events from tomorrow onwards.
  // 'past' means events from yesterday backwards.
  String _filterMode = 'day'; // Can be 'day', 'upcoming', 'past'

  @override
  void initState() {
    super.initState();
    // Initialize to show upcoming fixtures by default when the page loads.
    _selectedDate = DateTime.now().add(
      const Duration(days: 1),
    ); // Start from tomorrow
    _filterMode = 'upcoming';
  }

  // Function to add or edit a fixture in Firestore.
  // [documentSnapshot] is optional. If provided, it means we are editing an existing fixture.
  Future<void> _upsertFixture([DocumentSnapshot? documentSnapshot]) async {
    // Controllers for text fields in the dialog.
    final TextEditingController team1Controller = TextEditingController();
    final TextEditingController team2Controller = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    final TextEditingController dateController = TextEditingController();

    DateTime? initialDate;
    TimeOfDay? initialTime;

    // If a documentSnapshot is provided, pre-fill controllers with existing data.
    if (documentSnapshot != null) {
      final data = documentSnapshot.data() as Map<String, dynamic>;
      team1Controller.text = data['team1Name'] ?? '';
      team2Controller.text = data['team2Name'] ?? '';
      timeController.text = data['time'] ?? '';
      dateController.text = data['date'] ?? '';

      // Try to parse existing date and time for initial values of pickers.
      try {
        initialDate = DateTime.parse(data['date']);
        List<String> timeParts = (data['time'] as String).split(':');
        initialTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      } catch (e) {
        // Log error if parsing fails, but don't block the UI.
        print("Error parsing date/time for editing: $e");
      }
    } else {
      // For a new fixture, pre-fill the date field based on current _selectedDate
      // but only if _filterMode is 'day'. Otherwise, default to today.
      initialDate = (_filterMode == 'day') ? _selectedDate : DateTime.now();
      dateController.text = DateFormat('yyyy-MM-dd').format(initialDate);
    }

    // Show a modal bottom sheet for adding/editing fixture details.
    await showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows the sheet to take full height if needed
      builder: (BuildContext context) {
        return Padding(
          // Adjust padding based on keyboard visibility.
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            // Allows scrolling if content overflows
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Column takes minimum space vertically
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  documentSnapshot == null ? 'Add New Fixture' : 'Edit Fixture',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: team1Controller,
                  decoration: const InputDecoration(
                    labelText: 'Team 1 Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: team2Controller,
                  decoration: const InputDecoration(
                    labelText: 'Team 2 Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                // GestureDetector and AbsorbPointer are used to make the TextField tap-to-open-picker.
                GestureDetector(
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime:
                          initialTime ??
                          TimeOfDay.now(), // Use initial time or current time
                    );
                    if (pickedTime != null) {
                      // Format time to HH:MM string for storage.
                      // Ensure consistent 24-hour format if needed, otherwise format(context) is locale-dependent.
                      timeController.text = MaterialLocalizations.of(
                        context,
                      ).formatTimeOfDay(
                        pickedTime,
                        alwaysUse24HourFormat: true,
                      );
                    }
                  },
                  child: AbsorbPointer(
                    // Prevents direct text input
                    child: TextField(
                      controller: timeController,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      readOnly: true, // Ensures time is picked, not typed
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate:
                          initialDate ??
                          DateTime.now(), // Use initial date or current date
                      firstDate: DateTime(2000), // Date range for the picker
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      // Format date to yyyy-MM-dd string for storage.
                      dateController.text = DateFormat(
                        'yyyy-MM-dd',
                      ).format(pickedDate);
                    }
                  },
                  child: AbsorbPointer(
                    // Prevents direct text input
                    child: TextField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true, // Ensures date is picked, not typed
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blueGrey,
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final String team1Name = team1Controller.text;
                        final String team2Name = team2Controller.text;
                        final String time = timeController.text;
                        final String date = dateController.text;

                        // Basic validation: ensure all fields are filled.
                        if (team1Name.isNotEmpty &&
                            team2Name.isNotEmpty &&
                            time.isNotEmpty &&
                            date.isNotEmpty) {
                          // Create a DateTime object from date string for timestamp.
                          final DateTime fixtureDateTime = DateTime.parse(date);

                          if (documentSnapshot == null) {
                            // Add new fixture to Firestore.
                            await _fixtures.add({
                              'team1Name': team1Name,
                              'team2Name': team2Name,
                              'time': time,
                              'date': date,
                              'timestamp': Timestamp.fromDate(
                                fixtureDateTime,
                              ), // Store timestamp for efficient date-based queries.
                            });
                          } else {
                            // Update existing fixture in Firestore.
                            await _fixtures.doc(documentSnapshot.id).update({
                              'team1Name': team1Name,
                              'team2Name': team2Name,
                              'time': time,
                              'date': date,
                              'timestamp': Timestamp.fromDate(fixtureDateTime),
                            });
                          }
                          Navigator.pop(context); // Close the bottom sheet.
                        } else {
                          // Show a snackbar if fields are empty.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in all fields'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 13, 71, 161),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(documentSnapshot == null ? 'Add' : 'Update'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Function to delete a fixture from Firestore.
  Future<void> _deleteFixture(String fixtureId) async {
    await _fixtures.doc(fixtureId).delete();
    // Show a confirmation snackbar.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fixture deleted successfully!')),
    );
  }

  // Function to show a confirmation dialog before deleting.
  Future<void> _confirmDelete(String fixtureId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Deletion',
            style: TextStyle(color: Color.fromARGB(255, 13, 71, 161)),
          ),
          content: const Text(
            'Are you sure you want to delete this fixture? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed:
                  () => Navigator.of(context).pop(), // Close dialog on Cancel.
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteFixture(fixtureId); // Proceed with deletion.
                Navigator.of(context).pop(); // Close the dialog.
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Helper widget to build the date selection buttons.
  // [text] is the display text for the button (e.g., "Today", "Upcoming").
  // [mode] defines the filtering behavior ('day', 'upcoming', 'past').
  // [date] is the DateTime object used as a reference point for the filter.
  Widget _buildDateButton(String text, String mode, DateTime date) {
    // Determine if the current button is selected based on _filterMode and _selectedDate.
    final bool isSelected =
        (_filterMode == mode) &&
        (_filterMode != 'day' ||
            (_selectedDate.year == date.year &&
                _selectedDate.month == date.month &&
                _selectedDate.day == date.day));

    return OutlinedButton(
      onPressed: () {
        setState(() {
          _filterMode = mode;
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
          ); // Normalize to start of day
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor:
            isSelected
                ? Colors.blue[700]
                : Colors
                    .transparent, // Filled when selected, transparent when not
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.blue.shade700,
        ), // No border when selected, blue border otherwise
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          color:
              isSelected
                  ? Colors.white
                  : Colors
                      .blue[900], // White text when selected, blue otherwise
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get today, yesterday, and tomorrow for button logic.
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final DateTime tomorrow = today.add(const Duration(days: 1));

    // Determine the Firestore query based on the selected filter mode.
    Query firestoreQuery;
    if (_filterMode == 'upcoming') {
      // Show all fixtures from tomorrow onwards.
      firestoreQuery = _fixtures
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(tomorrow),
          )
          .orderBy('timestamp');
    } else if (_filterMode == 'past') {
      // Show all fixtures up to (and including) yesterday.
      firestoreQuery = _fixtures
          .where(
            'timestamp',
            isLessThanOrEqualTo: Timestamp.fromDate(
              today.subtract(const Duration(milliseconds: 1)),
            ),
          )
          .orderBy('timestamp', descending: true);
      // We use 'less than or equal to start of today' for "past" to exclude today.
      // Subtracting 1 millisecond from 'today' gets us to the very end of yesterday.
    } else {
      // 'day' mode: Show fixtures only for the _selectedDate.
      final DateTime startOfDay = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
      final DateTime endOfDay = startOfDay
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));
      firestoreQuery = _fixtures
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('timestamp');
    }

    return Scaffold(
      appBar: AppBar(
        // Leading drawer icon (remains)
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: const Text(
          'Fixtures',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        elevation: 0, // Flat app bar look.
        // Actions: Back button moved to actions
        actions: [
          // Back Button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Navigates back to the previous screen
            },
          ),
          const SizedBox(width: 8), // Padding on the right
        ],
        // Removed the 'bottom' property from AppBar as buttons are moved to body
      ),
      drawer: const HomeDrawer(), // Your custom drawer.
      body: Column(
        // Use Column to stack buttons and StreamBuilder content
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Moved the filter buttons here, outside the AppBar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16.0,
              16.0,
              16.0,
              8.0,
            ), // Sufficient padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Buttons for Past, Today, Upcoming.
                _buildDateButton(
                  'Past',
                  'past',
                  yesterday,
                ), // Reference date for past is yesterday
                _buildDateButton(
                  'Today',
                  'day',
                  today,
                ), // Reference date for today is today
                _buildDateButton(
                  'Upcoming',
                  'upcoming',
                  tomorrow,
                ), // Reference date for upcoming is tomorrow
              ],
            ),
          ),
          const SizedBox(height: 16), // Spacing between buttons and content
          // The StreamBuilder for displaying fixtures takes the rest of the space
          Expanded(
            // Use Expanded to make the ListView fill remaining space
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreQuery.snapshots(),
              builder: (context, snapshot) {
                // Handle potential Firestore errors.
                if (snapshot.hasError) {
                  print(
                    "Firestore Error: ${snapshot.error}",
                  ); // Log the error for debugging.
                  return Center(
                    child: Text(
                      'Error loading data: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  );
                }
                // Show a loading indicator while data is being fetched.
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blueAccent,
                      ),
                    ),
                  );
                }
                // If no data is available from Firestore at all.
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  String emptyMessage;
                  if (_filterMode == 'upcoming') {
                    emptyMessage = 'No upcoming fixtures scheduled.';
                  } else if (_filterMode == 'past') {
                    emptyMessage = 'No past fixtures found.';
                  } else {
                    emptyMessage = 'No fixtures for today.';
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.event_note,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          emptyMessage,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const Text(
                          'Tap the "+" button to add one!',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                final List<DocumentSnapshot> displayFixtures =
                    snapshot.data!.docs;

                // Display the filtered list of fixtures.
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: displayFixtures.length,
                  itemBuilder: (context, index) {
                    final document = displayFixtures[index];
                    final data = document.data() as Map<String, dynamic>;

                    final String team1Name = data['team1Name'] ?? 'Team A';
                    final String team2Name = data['team2Name'] ?? 'Team B';
                    final String time = data['time'] ?? 'N/A';
                    final String date =
                        data['date'] ?? 'N/A'; // Also display the date
                    // You can potentially fetch logo URLs here if stored in Firestore
                    // final String? team1LogoUrl = data['team1LogoUrl'];
                    // final String? team2LogoUrl = data['team2LogoUrl'];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      elevation: 4.0, // Increased elevation for more depth
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          15.0,
                        ), // More rounded corners
                      ),
                      child: InkWell(
                        // Make the card tappable for editing
                        onTap:
                            () => _upsertFixture(
                              document,
                            ), // Pass the document to edit.
                        borderRadius: BorderRadius.circular(15.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Left Team
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 60.0, // Slightly larger logo area
                                      height: 60.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            Colors
                                                .grey[200], // Lighter grey for placeholder
                                        border: Border.all(
                                          color: Colors.blue.shade200,
                                          width: 1.0,
                                        ), // Subtle border
                                      ),
                                      // You would load an image here if a URL is available:
                                      // child: team1LogoUrl != null
                                      //      ? ClipOval(child: Image.network(team1LogoUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Icon(Icons.error)))
                                      //      : Icon(Icons.shield_outlined, size: 30.0, color: Colors.blueGrey.shade400),
                                      child: Icon(
                                        Icons.shield_outlined,
                                        size: 30.0,
                                        color: Colors.blueGrey.shade400,
                                      ), // Placeholder icon
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      team1Name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Center Information (Time & Status)
                              Expanded(
                                flex: 2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      time,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: Color.fromARGB(
                                          255,
                                          6,
                                          77,
                                          136,
                                        ), // Highlight time
                                      ),
                                    ),
                                    // Display the date for all fixtures
                                    Text(
                                      DateFormat(
                                        'MMM d, y',
                                      ).format(DateTime.parse(date)),
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                        vertical: 5.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors
                                                .blue[50], // Lighter blue background
                                        borderRadius: BorderRadius.circular(
                                          20.0,
                                        ), // More rounded pill shape
                                        border: Border.all(
                                          color: Colors.blue.shade100,
                                        ),
                                      ),
                                      child: Text(
                                        'Scheduled',
                                        style: TextStyle(
                                          color: Colors.blue[900],
                                          fontSize: 11.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Right Team
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 60.0,
                                      height: 60.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[200],
                                        border: Border.all(
                                          color: Colors.blue.shade200,
                                          width: 1.0,
                                        ),
                                      ),
                                      // You would load an image here if a URL is available:
                                      // child: team2LogoUrl != null
                                      //      ? ClipOval(child: Image.network(team2LogoUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Icon(Icons.error)))
                                      //      : Icon(Icons.shield_outlined, size: 30.0, color: Colors.blueGrey.shade400),
                                      child: Icon(
                                        Icons.shield_outlined,
                                        size: 30.0,
                                        color: Colors.blueGrey.shade400,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      team2Name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Delete Button
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                  size: 24,
                                ),
                                onPressed:
                                    () => _confirmDelete(
                                      document.id,
                                    ), // Confirm before deleting.
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
        onPressed:
            () =>
                _upsertFixture(), // Call without arguments to add a new fixture.
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Icon(Icons.add_circle_outline, size: 30),
      ),
    );
  }
}*/

// fixtures.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:hockey_union/home/home_drawer.dart';

class FixturesPage extends StatefulWidget {
  const FixturesPage({super.key});

  @override
  State<FixturesPage> createState() => _FixturesPageState();
}

class _FixturesPageState extends State<FixturesPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search fixtures...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  style: const TextStyle(color: Colors.black87),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/NHU.png', height: 40, width: 40),
                  ],
                ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.black87,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _searchQuery = '';
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue[900],
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Men\'s Divi...'),
            Tab(text: 'Women\'s D...'),
            Tab(text: 'Indoor'),
            Tab(text: 'Outdoor'),
          ],
        ),
      ),
      drawer: const HomeDrawer(), // Using the imported home_drawer
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFixturesList('mens_division'),
          _buildFixturesList('womens_division'),
          _buildFixturesList('indoor'),
          _buildFixturesList('outdoor'),
        ],
      ),
    );
  }

  Widget _buildFixturesList(String category) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('fixtures')
              .where('category', isEqualTo: category)
              .orderBy('match_time')
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No fixtures available',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        var fixtures = snapshot.data!.docs;

        // Filter fixtures based on search query
        if (_searchQuery.isNotEmpty) {
          fixtures =
              fixtures.where((doc) {
                var data = doc.data() as Map<String, dynamic>;
                var homeTeam =
                    data['home_team_name']?.toString().toLowerCase() ?? '';
                var awayTeam =
                    data['away_team_name']?.toString().toLowerCase() ?? '';
                return homeTeam.contains(_searchQuery) ||
                    awayTeam.contains(_searchQuery);
              }).toList();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: fixtures.length,
          itemBuilder: (context, index) {
            var fixture = fixtures[index].data() as Map<String, dynamic>;
            return _buildFixtureCard(fixture);
          },
        );
      },
    );
  }

  Widget _buildFixtureCard(Map<String, dynamic> fixture) {
    // Extract match time
    var matchTime = fixture['match_time'] as Timestamp?;
    String timeString = '11:00'; // Default time

    if (matchTime != null) {
      var dateTime = matchTime.toDate();
      timeString = DateFormat('yyyy-MM-dd').format(dateTime);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Match time and reminder
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                timeString,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.notifications,
                size: 16,
                color: Color.fromARGB(255, 13, 71, 161),
              ),
              const Text(
                'Reminder',
                style: TextStyle(
                  fontSize: 12,
                  color: Color.fromARGB(255, 13, 71, 161),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Teams and logos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Home team
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                        image:
                            fixture['home_team_logo'] != null
                                ? DecorationImage(
                                  image: NetworkImage(
                                    fixture['home_team_logo'],
                                  ),
                                  fit: BoxFit.cover,
                                )
                                : null,
                      ),
                      child:
                          fixture['home_team_logo'] == null
                              ? const Icon(
                                Icons.sports_soccer,
                                size: 30,
                                color: Colors.grey,
                              )
                              : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fixture['home_team_name'] ?? 'Team',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // VS text
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              // Away team
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                        image:
                            fixture['away_team_logo'] != null
                                ? DecorationImage(
                                  image: NetworkImage(
                                    fixture['away_team_logo'],
                                  ),
                                  fit: BoxFit.cover,
                                )
                                : null,
                      ),
                      child:
                          fixture['away_team_logo'] == null
                              ? const Icon(
                                Icons.sports_soccer,
                                size: 30,
                                color: Colors.grey,
                              )
                              : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fixture['away_team_name'] ?? 'Team',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Firebase data model for reference
class Fixture {
  final String id;
  final String homeTeamName;
  final String awayTeamName;
  final String? homeTeamLogo;
  final String? awayTeamLogo;
  final DateTime matchTime;
  final String category;
  final bool reminderSet;

  Fixture({
    required this.id,
    required this.homeTeamName,
    required this.awayTeamName,
    this.homeTeamLogo,
    this.awayTeamLogo,
    required this.matchTime,
    required this.category,
    this.reminderSet = false,
  });

  factory Fixture.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Fixture(
      id: doc.id,
      homeTeamName: data['home_team_name'] ?? '',
      awayTeamName: data['away_team_name'] ?? '',
      homeTeamLogo: data['home_team_logo'],
      awayTeamLogo: data['away_team_logo'],
      matchTime: (data['match_time'] as Timestamp).toDate(),
      category: data['category'] ?? '',
      reminderSet: data['reminder_set'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'home_team_name': homeTeamName,
      'away_team_name': awayTeamName,
      'home_team_logo': homeTeamLogo,
      'away_team_logo': awayTeamLogo,
      'match_time': Timestamp.fromDate(matchTime),
      'category': category,
      'reminder_set': reminderSet,
    };
  }
}
