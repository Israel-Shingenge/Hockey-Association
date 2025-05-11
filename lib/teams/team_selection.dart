import 'package:flutter/material.dart';
import 'package:hockey_union/home/home_drawer.dart';
import 'package:hockey_union/profile/team_profile.dart'; // Adjust the import path

class TeamSelectionPage extends StatefulWidget {
  const TeamSelectionPage({super.key});

  @override
  State<TeamSelectionPage> createState() => _TeamSelectionPageState();
}

class _TeamSelectionPageState extends State<TeamSelectionPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isTeamMenuVisible = false;

  void _toggleTeamMenu() {
    setState(() {
      _isTeamMenuVisible = !_isTeamMenuVisible;
    });
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
        title: const Text('Teams'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: GestureDetector(
            onTap: _toggleTeamMenu,
            child: Container(
              color: const Color.fromARGB(255, 13, 60, 161),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Text(
                          'Dunes', // Current league (can be dynamic)
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                  ),
                  // You might add a filter or search icon here later
                ],
              ),
            ),
          ),
        ),
      ),
      drawer: const HomeDrawer(),
      body: Stack(
        children: [
          // Main content of the Teams page (you can add your team listing here)
          // Pop-up menu for team selection
          if (_isTeamMenuVisible)
            GestureDetector(
              onTap: _toggleTeamMenu, // Close when tapping outside
              behavior: HitTestBehavior.opaque, // Make the whole area tappable
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: ModalRoute.of(context)!.animation!,
                    curve: Curves.easeInOut,
                    reverseCurve: Curves.easeOut,
                  )),
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: ModalRoute.of(context)!.animation!,
                      curve: Curves.easeInOut,
                      reverseCurve: Curves.easeOut,
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 450.0), // To position above the blue bar
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8.0,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            color: const Color.fromARGB(255, 238, 238, 238),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: _toggleTeamMenu,
                                  child: const Text('Close', style: TextStyle(color: Colors.black87)),
                                ),
                                const Text('My teams', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextButton(
                                  onPressed: () async {
                                    // Assuming you have a way to get the currently selected team's data
                                    final selectedTeamName = 'Dunes'; // Replace with actual selected team name
                                    final selectedFoundedDate = DateTime(2025, 2, 20); // Replace with actual founded date

                                    final result = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return EditTeamPopup(
                                          initialTeamName: selectedTeamName,
                                          initialFoundedDate: selectedFoundedDate,
                                        );
                                      },
                                    );

                                    // Handle the result when the EditTeamPopup is closed
                                    if (result != null && result is Map) {
                                      final newName = result['name'];
                                      final newFoundedDate = result['founded'];
                                      print('New team name: $newName, New founded date: $newFoundedDate');
                                      // Update your team data with the new values
                                    }
                                  },
                                  child: const Text('Edit', style: TextStyle(color: Colors.black87)),
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Active teams', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              child: const Icon(Icons.image, color: Colors.grey),
                            ),
                            title: const Text('Dunes'),
                            onTap: () {
                              setState(() {
                                _isTeamMenuVisible = false;
                                // Update the selected team if needed
                              });
                              print('Dunes selected');
                            },
                          ),
                          // Add more team listings here
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}