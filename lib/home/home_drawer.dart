import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hockey_union/aboutUs/contact_us.dart';
import 'package:hockey_union/fixtures/fixtures.dart';
import 'package:hockey_union/news/news.dart';
import 'package:hockey_union/teams/team_page.dart';
import 'package:hockey_union/events/create_event.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  Color _hexToColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor"; // Add opacity if missing
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    final Color activeColor = _hexToColor("2E4A78");
    final Color textColor = isSelected ? Colors.white : Colors.black;
    final Color iconColor = isSelected ? Colors.white : Colors.black;

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: isSelected ? activeColor.withOpacity(0.7) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? displayName = user?.displayName;
    final String? photoUrl = user?.photoURL;
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';

    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/NHU.png',
                      height: 30,
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                _buildDrawerItem(
                  context: context,
                  icon: Icons.home,
                  title: 'Home',
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/home') {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                  isSelected: currentRoute == '/home',
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.event,
                  title: 'Events',
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/events') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EventsPage()),
                      );
                    }
                  },
                  isSelected: currentRoute == '/events',
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.group,
                  title: 'Teams',
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/teams') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TeamPage()),
                      );
                    }
                  },
                  isSelected: currentRoute == '/teams',
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.list_alt,
                  title: 'Fixtures',
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/fixtures') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FixturesPage()),
                      );
                    }
                  },
                  isSelected: currentRoute == '/fixtures',
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.newspaper,
                  title: 'News',
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/news') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NewsPage()),
                      );
                    }
                  },
                  isSelected: currentRoute == '/news',
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.group,
                  title: 'Contact Us',
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/contactUs') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ContactUsPage()),
                      );
                    }
                  },
                  isSelected: currentRoute == '/contactUs',
                ),
              ],
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              if (currentRoute != '/profile') {
                Navigator.pushNamed(context, '/profile');
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null ? const Icon(Icons.person) : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      displayName ?? 'Guest User',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
