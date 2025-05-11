import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hockey_union/teams/team_page.dart';
import 'package:hockey_union/events/event.dart';

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
    required BuildContext context, // Add BuildContext as a required parameter
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
      // ignore: deprecated_member_use
      selectedTileColor: isSelected ? activeColor.withOpacity(0.7) : null, // Use a slightly more opaque background for better visibility of white text/icon
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? displayName = user?.displayName;
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/'; // Get current route

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
                      'assets/images/NHU.png', // Replace with your small logo asset path
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
                  context: context, // Pass the context here
                  icon: Icons.home,
                  title: 'Home',
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/home') {
                      Navigator.pushReplacementNamed(context, '/home'); // Use named route
                    }
                  },
                  isSelected: currentRoute == '/home',
                ),
               _buildDrawerItem(
                context: context, // Pass the context here
                icon: Icons.event,
                title: 'Events',
                onTap: () {
                  Navigator.of(context).pop(); // Close the drawer
                  if (currentRoute != '/events') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EventsPage()),
                    );
                  }
                },
                isSelected: currentRoute == '/events', // You'll need to define this route
              ),
                _buildDrawerItem(
                context: context, // Pass the context here
                icon: Icons.group,
                title: 'Teams',
                onTap: () {
                  Navigator.of(context).pop(); // Close the drawer
                  if (currentRoute != '/teams') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TeamPage()),
                    );
                  }
                },
                isSelected: currentRoute == '/teams', // You'll need to define this route
              ),
                _buildDrawerItem(
                  context: context, // Pass the context here
                  icon: Icons.search,
                  title: 'Search',
                  onTap: () {
                    Navigator.of(context).pop();
                    // Handle Search navigation
                  },
                  isSelected: currentRoute == '/search', // You'll need to define this route
                ),
                _buildDrawerItem(
                  context: context, // Pass the context here
                  icon: Icons.article,
                  title: 'News',
                  onTap: () {
                    Navigator.of(context).pop();
                    // Handle News navigation
                  },
                  isSelected: currentRoute == '/news', // You'll need to define this route
                ),
                _buildDrawerItem(
                  context: context, // Pass the context here
                  icon: Icons.phone,
                  title: 'Contact Us',
                  onTap: () {
                    Navigator.of(context).pop();
                    // Handle Contact Us navigation
                  },
                  isSelected: currentRoute == '/contact_us', // You'll need to define this route
                ),
              ],
            ),
          ),
          const Divider(),
          GestureDetector( // Wrap the profile section with GestureDetector
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer
              if (currentRoute != '/profile') {
                Navigator.pushNamed(context, '/profile'); // Navigate to profile
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    displayName ?? 'Guest User',
                    style: const TextStyle(fontWeight: FontWeight.bold),
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