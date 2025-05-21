import 'package:flutter/material.dart';
import 'package:hockey_union/home/home_drawer.dart'; // Assuming you have a HomeDrawer

class StandingsPage extends StatelessWidget {
  const StandingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Match Details', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
      ),
      drawer: const HomeDrawer(), // Assuming you want the drawer here
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Match Information Section
            Container(
              color: Colors.blue[800],
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 60.0,
                        height: 60.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: const Icon(Icons.image_outlined, size: 30.0, color: Colors.grey),
                      ),
                      const SizedBox(height: 8.0),
                      const Text('Eagles', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('2', style: TextStyle(fontSize: 24.0, color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: Colors.blue[500],
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: const Text('35:00', style: TextStyle(color: Colors.white, fontSize: 12.0)),
                          ),
                          const SizedBox(width: 8.0),
                          const Text('4', style: TextStyle(fontSize: 24.0, color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      const Text('First Half', style: TextStyle(color: Colors.white, fontSize: 12.0)),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        width: 60.0,
                        height: 60.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: const Icon(Icons.image_outlined, size: 30.0, color: Colors.grey),
                      ),
                      const SizedBox(height: 8.0),
                      const Text('Dunes', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            // Standings Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Standings', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const SizedBox(width: 40.0), // Placeholder for team logo/rank
                      Expanded(child: const Text('Pts', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: const Text('Win', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: const Text('Lose', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: const Text('Draw', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // To prevent nested scrolling issues
                    itemCount: 7, // Placeholder for 7 teams
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 30.0,
                              height: 30.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[300],
                              ),
                              child: const Icon(Icons.image_outlined, size: 16.0, color: Colors.grey),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(child: Text('Team ${index + 1}')), // Placeholder team name
                            Expanded(child: const Text('40', textAlign: TextAlign.center)),
                            Expanded(child: const Text('40', textAlign: TextAlign.center)),
                            Expanded(child: const Text('40', textAlign: TextAlign.center)),
                            Expanded(child: const Text('40', textAlign: TextAlign.center)),
                          ],
                        ),
                      );
                    },
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