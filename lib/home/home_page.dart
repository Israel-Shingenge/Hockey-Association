import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hockey_union/authentication/auth.dart';
import 'package:hockey_union/events/create_event.dart'; 
import 'package:hockey_union/teams/create_team.dart';
import 'package:hockey_union/teams/team_page.dart'; 
import 'package:hockey_union/teams/view_teams.dart'; 
import 'package:hockey_union/home/home_drawer.dart'; 
import 'package:hockey_union/widgets/events_preview.dart';
import 'package:hockey_union/widgets/fixtures_preview.dart';
import 'package:hockey_union/widgets/news_preview.dart';
import 'package:hockey_union/widgets/standings_preview.dart';

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
        pageBuilder: (context, animation, secondaryAnimation) => const TeamSelectionPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void _showAddPopupMenu() {
    // Determine the position of the popup menu relative to the 'add' icon
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final double appBarHeight = AppBar().preferredSize.height + MediaQuery.of(context).padding.top;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + renderBox.size.width - 60, // Align with right of add icon
        offset.dy + appBarHeight - 10,       // Just below the app bar
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
        // Assuming EventsPage (from create_event.dart) is where new events are created/managed
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EventsPage()),
        );
      } else if (value == 'player') {
        // Navigates to a page related to teams/players (TeamPage is just an example here)
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
        backgroundColor: Colors.blue[900], // Consistent primary color
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Center(
          child: Image.asset(
            'assets/images/NHU.png',
            height: 30,
            color: Colors.white, // Assuming logo can be tinted white for visibility
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddPopupMenu,
          ),
          const SizedBox(width: 8), // Padding on the right
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0), // Height for the league selector
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: GestureDetector(
              onTap: _navigateToLeagueSelection,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white24, // Slightly transparent white for selection
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.sports_hockey, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Teams', // This should eventually be dynamic based on selected league
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      drawer: const HomeDrawer(), // Your custom drawer
      body: SingleChildScrollView( // Make the body scrollable
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Make cards take full width
          children: <Widget>[
            // Standings Preview Card
            const StandingsPreviewCard(),
            const SizedBox(height: 16), // Spacing between cards

            // Fixtures Preview Card
            const FixturesPreviewCard(),
            const SizedBox(height: 16),

            // News Preview Card
            const NewsPreviewCard(),
            const SizedBox(height: 16),

            // Events Preview Card
            const EventsPreviewCard(),
            const SizedBox(height: 24), // More space before sign out

            // Sign out button (optional, could be in drawer as well)
            Align(
              alignment: Alignment.center,
              child: OutlinedButton.icon(
                onPressed: signOut,
                icon: const Icon(Icons.logout, color: Colors.blueAccent),
                label: const Text('Sign Out', style: TextStyle(color: Colors.blueAccent)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blueAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}