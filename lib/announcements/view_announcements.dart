import 'package:flutter/material.dart';
import 'package:hockey_union/announcements/manageme_announcements.dart';
import 'package:hockey_union/home/home_drawer.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentSortOrder = 'Newest';

  // Use a mutable list so that changes from ManageAnnouncementsPage can be reflected
  final List<Map<String, String>> _newsItems = [
    {
      'image': 'maintenance.png',
      'title': 'Practice Update: INDOOR Tonight!',
      'description': "Tonight's practice (May 27th) at Khomasdal Stadium is MOVED INDOORS to Windhoek High School Gym. 7 PM - 8:30 PM. Bring indoor shoes.",
      'date': '2024-05-27',
    },
    {
      'image': 'maintenance.png',
      'title': 'Last Call: Tournament Volunteer Sign-Up!',
      'description': "Final reminder! Volunteer sign-up for the 'Khomas Hockey Challenger' (June 1st) closes tomorrow evening. Your help is vital!",
      'date': '2024-05-31',
    },
    {
      'image': 'maintenance.png',
      'title': 'U16 Game Time Change (June 8th)',
      'description': "U16 Game on June 8th vs. Ramblers is now at 11:30 AM (was 10:00 AM) at Wanderers Hockey Club.",
      'date': '2024-06-07',
    },
    {
      'image': 'maintenance.png',
      'title': 'App Maintenance This Weekend',
      'description': "App maintenance scheduled for Sat, June 15th (10 PM) to Sun, June 16th (6 AM CAT). Some features may be unavailable.",
      'date': '2024-06-14',
    },
  ];

  List<Map<String, String>> get _sortedNewsItems {
    List<Map<String, String>> sortedList = List.from(_newsItems);
    if (_currentSortOrder == 'Newest') {
      sortedList.sort((a, b) => DateTime.parse(b['date']!).compareTo(DateTime.parse(a['date']!)));
    } else {
      sortedList.sort((a, b) => DateTime.parse(a['date']!).compareTo(DateTime.parse(b['date']!)));
    }
    return sortedList;
  }

  // Callback to update _newsItems when changes occur in ManageAnnouncementsPage
  void _onAnnouncementsChanged(List<Map<String, String>> updatedList) {
    setState(() {
      _newsItems.clear();
      _newsItems.addAll(updatedList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
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
        actions: const [],
      ),
      drawer: const HomeDrawer(),
      body: Container(
        color: Colors.grey[100],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Announcements',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      children: [
                        PopupMenuButton<String>(
                          onSelected: (String result) {
                            setState(() {
                              _currentSortOrder = result;
                            });
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'Newest',
                              child: Text('Newest'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'Oldest',
                              child: Text('Oldest'),
                            ),
                          ],
                          icon: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: const Icon(Icons.filter_list, color: Colors.black54),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        // Edit Announcements Icon Button - NOW NAVIGATES TO MANAGE PAGE
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.white,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.black54),
                            onPressed: () async {
                              // Navigate to the ManageAnnouncementsPage
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ManageAnnouncementsPage(
                                    announcements: _newsItems, // Pass the current list
                                  ),
                                ),
                              );
                              // When returning from ManageAnnouncementsPage, update the list
                              if (result != null && result is List<Map<String, String>>) {
                                _onAnnouncementsChanged(result);
                              }
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),

              ..._sortedNewsItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildNewsCard(
                  imagePath: 'assets/images/${item['image']}',
                  title: item['title']!,
                  description: item['description']!,
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCard({
    required String imagePath,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 165,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[700],
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