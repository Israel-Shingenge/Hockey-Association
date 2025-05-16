import 'package:flutter/material.dart';
import 'package:hockey_union/teams/team_popup.dart';
import 'package:hockey_union/teams/team_selection.dart';
import 'package:hockey_union/profile/player_profile.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final List<String> _players = ['John Doe', 'Alice Smith'];

  void _addTeamMember() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const CreateTeamPopup(),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Team created!')));
    }
  }

  void _selectTeam() async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TeamSelectionPage()),
    );
    if (selected != null) {
      // You can reload data or update state
      debugPrint('Team selected: $selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Page'),
        actions: [
          IconButton(onPressed: _selectTeam, icon: const Icon(Icons.list_alt)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTeamMember,
        child: const Icon(Icons.group_add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: _players.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, index) {
          final name = _players[index];
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(name),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlayerProfilePage(playerName: name),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
