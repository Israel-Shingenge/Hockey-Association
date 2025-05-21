import 'package:flutter/material.dart';
import 'package:hockey_union/home/home_drawer.dart'; // Assuming you have a HomeDrawer

class FixturesPage extends StatelessWidget {
  const FixturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: const Text('Schedule', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // Handle Yesterday button press
                    print('Yesterday clicked');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Yesterday', style: TextStyle(color: Colors.white)),
                ),
                OutlinedButton(
                  onPressed: () {
                    // Handle Today button press
                    print('Today clicked');
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text('Today', style: TextStyle(color: Colors.blue[900])),
                ),
                OutlinedButton(
                  onPressed: () {
                    // Handle Tomorrow button press
                    print('Tomorrow clicked');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Tomorrow', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: const HomeDrawer(), // Assuming you want the drawer here
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 5, // Placeholder for 5 schedule items
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Team
                  Column(
                    children: [
                      Container(
                        width: 50.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: const Icon(Icons.image_outlined, size: 24.0, color: Colors.grey),
                      ),
                      const SizedBox(height: 4.0),
                      const Text('Dunes', style: TextStyle(fontSize: 12.0)),
                    ],
                  ),
                  // Center Information
                  Column(
                    children: [
                      const Text('11:00', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.notifications_active_outlined, size: 12.0, color: Colors.blue),
                            const SizedBox(width: 4.0),
                            Text('Reminder', style: TextStyle(color: Colors.blue[900], fontSize: 10.0)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Right Team
                  Column(
                    children: [
                      Container(
                        width: 50.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: const Icon(Icons.image_outlined, size: 24.0, color: Colors.grey),
                      ),
                      const SizedBox(height: 4.0),
                      const Text('Dunes', style: TextStyle(fontSize: 12.0)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}