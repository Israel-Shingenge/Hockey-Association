import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hockey_union/authentication/auth.dart';
import 'package:hockey_union/events/create_event.dart'; // Assuming EventsPage is here (your original)
import 'package:hockey_union/standings/standings.dart';
import 'package:hockey_union/teams/create_team.dart';
import 'package:hockey_union/teams/team_page.dart';
import 'package:hockey_union/teams/view_teams.dart';
import 'package:hockey_union/home/home_drawer.dart';
import 'package:hockey_union/announcements/view_announcements.dart';
import 'package:hockey_union/widgets/events_preview.dart';
import 'package:hockey_union/widgets/fixtures_preview.dart'; // For the notification icon

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
        offset.dx + renderBox.size.width - 60, // Align with right of add icon
        offset.dy + appBarHeight - 10, // Just below the app bar
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
            const Color(0xFF144781), // Dark blue from the image (hex code)
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
            color: Colors.white,
          ),
        ),
        actions: [
          // Notification icon
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const AnnouncementPage()), // Navigate to AnnouncementPage for notifications
              );
            },
          ),
          // Plus icon
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddPopupMenu,
          ),
          const SizedBox(width: 8), // Padding on the right
        ],
        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(60.0), // Height for the league selector
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: GestureDetector(
              onTap: _navigateToLeagueSelection,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 16),
            // Horizontal Scrollable Buttons
            SizedBox(
              height: 50, // Height for the buttons
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildSportTypeButton('Mens Division'),
                  const SizedBox(width: 8),
                  _buildSportTypeButton('Womens Division'),
                  const SizedBox(width: 8),
                  _buildSportTypeButton('Indoor Hockey'),
                  const SizedBox(width: 8),
                  _buildSportTypeButton('Outdoor Hockey'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 8),
            SizedBox(
              height: 200, // Height for horizontal live match cards
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: const [
                  _LiveMatchCard(
                    team1: 'Rockets',
                    team2: 'Stars',
                    score: '2 - 1',
                    time: 'Live',
                    color: Color(0xFFE57373), // A red-ish color
                    team1Logo: 'assets/images/team_a_logo.png', // Replace with actual paths
                    team2Logo: 'assets/images/team_b_logo.png', // Replace with actual paths
                  ),
                  SizedBox(width: 16),
                  _LiveMatchCard(
                    team1: 'Blasters',
                    team2: 'Warriors',
                    score: '0 - 0',
                    time: '1st Period',
                    color: Color(0xFFFFF176), // A yellow-ish color
                    team1Logo: 'assets/images/team_c_logo.png',
                    team2Logo: 'assets/images/team_d_logo.png',
                  ),
                  SizedBox(width: 16),
                  _LiveMatchCard(
                    team1: 'Comets',
                    team2: 'Knights',
                    score: '3 - 2',
                    time: 'Live',
                    color: Color(0xFF64B5F6), // A blue-ish color
                    team1Logo: 'assets/images/team_e_logo.png',
                    team2Logo: 'assets/images/team_f_logo.png',
                  ),
                  SizedBox(width: 16),
                ],
              ),
            ),
            const SizedBox(height: 24), // Spacing between sections

            // Fixtures Section (Stack vertically)
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
                                const StandingsPage()), // Navigate to FixturesPage
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
              // Using your actual FixturesPreviewCard from external file
              child: FixturesPreviewCard(),
            ),
            const SizedBox(height: 24),

            // View Events Section (Stack vertically)
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
                                const EventsPage()), // Navigate to the existing EventsPage
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
              // Using your actual EventsPreviewCard from external file
              child: EventsPreviewCard(),
            ),
            const SizedBox(height: 24), // Spacing before sign out

            // Sign out button (optional, could be in drawer as well)
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
            const SizedBox(height: 24), // Extra space at the bottom
          ],
        ),
      ),
    );
  }

  Widget _buildSportTypeButton(String text) {
    return ElevatedButton(
      onPressed: () {
        // Handle button press, e.g., filter content based on sport type
        debugPrint('$text button pressed');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // White background for buttons
        foregroundColor: Colors.black87, // Dark text
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.grey), // Grey border
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(text),
    );
  }
}

// Live Matches Card (remains here as it's specific to HomePage's horizontal list)
class _LiveMatchCard extends StatelessWidget {
  final String team1;
  final String team2;
  final String score;
  final String time;
  final Color color;
  final String team1Logo;
  final String team2Logo;

  const _LiveMatchCard({
    required this.team1,
    required this.team2,
    required this.score,
    required this.time,
    required this.color,
    required this.team1Logo,
    required this.team2Logo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8, // Approx 80% screen width
      margin: const EdgeInsets.only(right: 16.0), // Spacing between cards
      decoration: BoxDecoration(
        color: color, // Base color for the card
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Image with Opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.1, // 10% opacity
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/NHU.png', // Your NHU logo
                  fit: BoxFit.cover, // Cover the entire container
                ),
              ),
            ),
          ),
          // Content of the card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      time,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Image.asset(team1Logo, height: 40, width: 40),
                        const SizedBox(height: 8),
                        Text(
                          team1,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ],
                    ),
                    Text(
                      score,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                    Column(
                      children: [
                        Image.asset(team2Logo, height: 40, width: 40),
                        const SizedBox(height: 8),
                        Text(
                          team2,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Small spacing at the bottom
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ***************************************************************
// THE OLD DUMMY FixturesPreviewCard AND EventsPreviewCard CLASSES ARE REMOVED FROM HERE
// as they are now imported from their own files.
// ***************************************************************