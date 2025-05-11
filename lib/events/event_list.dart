import 'package:flutter/material.dart';
import 'package:hockey_union/home/home_drawer.dart';

class EventsListPage extends StatefulWidget {
  const EventsListPage({super.key});

  @override
  State<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends State<EventsListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<EventItem> _events = []; // Placeholder for your event data

  @override
  void initState() {
    super.initState();
    // In a real application, you would fetch events from a database or API
    // For now, we'll add some dummy data
    _events.addAll([
      const EventItem(
        day: 5,
        monthShort: 'Mon',
        timeZone: '09:30 (GMT +2)',
        eventName: 'NHL Championship',
        location: 'Pioneers park',
      ),
      // Add more events here
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                // Implement navigation to previous month/view
                print('Previous month');
              },
            ),
            const SizedBox(width: 8.0),
            const Text('Dunes'),
            const Icon(Icons.arrow_drop_down),
            const SizedBox(width: 8.0),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                // Implement navigation to next month/view
                print('Next month');
              },
            ),
          ],
        ),
      ),
      drawer: const HomeDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                'May',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                return _buildEventCard(_events[index]);
              },
            ),
            if (_events.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text('No events scheduled.'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(EventItem event) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 60.0,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Text(
                      '${event.day}',
                      style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    event.monthShort,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    event.timeZone,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    event.eventName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    event.location,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.info_outline, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}

class EventItem {
  final int day;
  final String monthShort;
  final String timeZone;
  final String eventName;
  final String location;

  const EventItem({
    required this.day,
    required this.monthShort,
    required this.timeZone,
    required this.eventName,
    required this.location,
  });
}