import 'package:flutter/material.dart';
import 'package:hockey_union/home/home_drawer.dart'; // Assuming you have a HomeDrawer
import 'package:intl/intl.dart'; // For date and time formatting

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({super.key});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool _showRegistrationPopup = false;

  void _toggleRegistrationPopup() {
    setState(() {
      _showRegistrationPopup = !_showRegistrationPopup;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Dunes', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle league selection here
              print('Selected league: $value');
            },
            itemBuilder: (BuildContext context) {
              return {'Dunes', 'Another League', 'Yet Another'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
            child: const Row(
              children: [
                SizedBox(width: 8.0),
                Icon(Icons.arrow_drop_down, color: Colors.white),
                SizedBox(width: 16.0),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    // Handle "May" navigation
                    print('Clicked May');
                  },
                  child: const Text('May', style: TextStyle(color: Colors.black87)),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Handle "All events" filter
                    print('Clicked All events');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('All events', style: TextStyle(color: Colors.black87)),
                ),
                const SizedBox(width: 8.0),
                TextButton(
                  onPressed: () {
                    // Handle "My events" filter
                    print('Clicked My events');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('My events', style: TextStyle(color: Colors.black87)),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: const HomeDrawer(), // Assuming you want the drawer here
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('d').format(DateTime(2025, 5, 5)), // Example Date: May 5th, 2025
                            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            DateFormat('E').format(DateTime(2025, 5, 5)), // Example Date: Mon
                            style: const TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '09:30 (GMT +2)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text('NHL Championship'),
                          const Text('Pioneers park'),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: _toggleRegistrationPopup,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_showRegistrationPopup)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              left: MediaQuery.of(context).size.width * 0.1,
              right: MediaQuery.of(context).size.width * 0.1,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Register for event', style: TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _toggleRegistrationPopup,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle registration logic
                            print('Register button pressed');
                            _toggleRegistrationPopup(); // Close the popup after registration
                            // You might want to show a confirmation message here
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                          ),
                          child: const Text('REGISTER', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}