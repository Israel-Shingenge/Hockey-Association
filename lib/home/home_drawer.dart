/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hockey_union/profile/profile.dart';
import 'package:hockey_union/events/event_list.dart';
import 'package:hockey_union/teams/team_page.dart';
import 'package:hockey_union/events/news.dart';
//import 'package:hockey_union/home/home_page.dart';

class HomeDrawer extends StatelessWidget {
  final String userRole;

  const HomeDrawer({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/logo.png', height: 30),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _drawerItem(context, Icons.home, 'Home', () {
                  Navigator.pushReplacementNamed(context, '/home');
                }),
                if (userRole != 'Player')
                  _drawerItem(context, Icons.group, 'Teams', () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const TeamPage()),
                    );
                  }),
                _drawerItem(context, Icons.event, 'Events', () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const EventsListPage()),
                  );
                }),
                _drawerItem(context, Icons.article, 'News', () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const NewsPage()),
                  );
                }),
                _drawerItem(context, Icons.person, 'Profile', () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                }),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              user?.email ?? 'Guest',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: onTap,
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:hockey_union/profile/profile.dart';
import 'package:hockey_union/events/event_list.dart';
import 'package:hockey_union/teams/team_page.dart';
import 'package:hockey_union/events/news.dart';

class HomeDrawer extends StatelessWidget {
  final String userRole;

  const HomeDrawer({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    // Mock user email for front-end only
    final String userEmail = 'user@example.com';

    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/logo.png', height: 30),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _drawerItem(context, Icons.home, 'Home', () {
                  Navigator.pushReplacementNamed(context, '/home');
                }),
                if (userRole != 'Player')
                  _drawerItem(context, Icons.group, 'Teams', () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const TeamPage()),
                    );
                  }),
                _drawerItem(context, Icons.event, 'Events', () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const EventsListPage()),
                  );
                }),
                _drawerItem(context, Icons.article, 'News', () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const NewsPage()),
                  );
                }),
                _drawerItem(context, Icons.person, 'Profile', () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                }),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              userEmail,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: onTap,
    );
  }
}
