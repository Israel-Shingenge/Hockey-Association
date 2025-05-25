
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hockey_union/authentication/auth.dart';
import 'package:hockey_union/events/create_event.dart'; 
import 'package:hockey_union/standings/standings.dart';
import 'package:hockey_union/teams/create_team.dart';
import 'package:hockey_union/teams/team_page.dart'; 
import 'package:hockey_union/teams/view_teams.dart'; 
import 'package:hockey_union/home/home_drawer.dart';
import 'package:hockey_union/announcements/view_announcements.dart';
import 'package:hockey_union/widgets/events_preview.dart';
import 'package:hockey_union/widgets/fixtures_preview.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hockey_union/widgets/live_match.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  void _navigateToLeagueSelection() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const TeamSelectionPage(), 
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void _showAddPopupMenu() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final double appBarHeight =
        AppBar().preferredSize.height + MediaQuery.of(context).padding.top;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + renderBox.size.width - 60, 
        offset.dy + appBarHeight - 10, 
        0,
        0,
      ),
      items: [
        PopupMenuItem(
          value: 'team',
          child: Row(
            children: const [
              Icon(Icons.group_add, color: Colors.blueGrey),
              SizedBox(width: 8),
              Text('Team'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'event',
          child: Row(
            children: const [
              Icon(Icons.event, color: Colors.blueGrey),
              SizedBox(width: 8),
              Text('Event'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'player',
          child: Row(
            children: const [
              Icon(Icons.person_add, color: Colors.blueGrey),
              SizedBox(width: 8),
              Text('Player'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'team') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateTeamPage()),
        );
      } else if (value == 'event') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EventsPage()), 
        );
      } else if (value == 'player') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TeamPage()), 
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF144781), 
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        
        title: Center(
          child: TextButton(
            onPressed: _navigateToLeagueSelection, 
            style: TextButton.styleFrom(
              
              backgroundColor: Colors.white24, 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Icon(Icons.sports_hockey, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Teams',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
          ),
        ),
        actions: [
          
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const AnnouncementPage()), 
              );
            },
          ),
          
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddPopupMenu,
          ),
          const SizedBox(width: 8), 
        ],
        
        bottom: null, 
      ),
      drawer: const HomeDrawer(), 
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 16),
            
            Align( 
              alignment: Alignment.center,
              child: SizedBox(
                height: 50, 
                child: ListView(
                  shrinkWrap: true, 
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    _buildSportTypeButton('Mens Division'),
                    const SizedBox(width: 8),
                    _buildSportTypeButton('Womens Division'),
                    
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 8),

            
            SizedBox(
              height: 200, 
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Fixtures')
                    .orderBy('timestamp', descending: false) 
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No matches available. Create some fixtures!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  final List<DocumentSnapshot> allFixtures = snapshot.data!.docs;
                  final List<Widget> relevantMatchCards = [];
                  final DateTime now = DateTime.now();

                  
                  for (var doc in allFixtures) {
                    final data = doc.data() as Map<String, dynamic>;
                    final Timestamp? scheduledEndTimestamp = data['scheduledEndTimeStamp'] as Timestamp?;

                    if (scheduledEndTimestamp != null && now.isBefore(scheduledEndTimestamp.toDate().add(const Duration(minutes: 5)))) {
                      
                      relevantMatchCards.add(
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: LiveMatchCardFirestore(fixtureDocument: doc),
                        ),
                      );
                    }
                  }

                  if (relevantMatchCards.isEmpty) {
                      return const Center(
                      child: Text(
                        'No live or upcoming matches at the moment. Check back later!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: relevantMatchCards,
                  );
                },
              ),
            ),
            const SizedBox(height: 24), 

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fixtures',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const StandingsPage()), 
                      );
                    },
                    child: const Text(
                      'See All Standings',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              
              child: FixturesPreviewCard(),
            ),
            const SizedBox(height: 24),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'View Events',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const EventsPage()), 
                      );
                    },
                    child: const Text(
                      'See All Events',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              
              child: EventsPreviewCard(),
            ),
            const SizedBox(height: 24), 

            Align(
              alignment: Alignment.center,
              child: OutlinedButton.icon(
                onPressed: signOut,
                icon: const Icon(Icons.logout, color: Colors.blueAccent),
                label: const Text('Sign Out',
                    style: TextStyle(color: Colors.blueAccent)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blueAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 24), 
          ],
        ),
      ),
    );
  }

  Widget _buildSportTypeButton(String text) {
    return ElevatedButton(
      onPressed: () {
        
        debugPrint('$text button pressed');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black87, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.grey), 
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(text),
    );
  }
}