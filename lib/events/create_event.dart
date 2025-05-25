import 'package:flutter/material.dart';
import 'package:hockey_union/home/home_drawer.dart'; 
import 'package:hockey_union/events/new_event.dart'; 
import 'package:hockey_union/events/new_game.dart'; 

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Center(
          child: SizedBox(
            height: 30,
            child: Image.asset(
              'assets/images/NHU.png', 
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0), 
            child: Icon(Icons.notifications), 
          ),
        ],
      ),
      drawer: const HomeDrawer(), 
      body: SingleChildScrollView( 
        child: Column(
          children: <Widget>[
            // Large Image Card
            Card(
              margin: const EdgeInsets.all(16.0),
              clipBehavior: Clip.antiAlias, 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), 
              ),
              child: Image.asset(
                'assets/images/hockey-female.png', 
                fit: BoxFit.cover,
                width: double.infinity,
                height: 450, 
              ),
            ),
            
            // Text Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              child: Column(
                children: const <Widget>[
                  Text(
                    'Organize Your Next Game',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    'From casual scrimmages to competitive matches, set up every event with ease.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddNewEventPage()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blue), // Blue border
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      child: const Text(
                        'ADD EVENTS',
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0), // Space between buttons
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddGamePage()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blue), // Blue border
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      child: const Text(
                        'ADD GAME',
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}