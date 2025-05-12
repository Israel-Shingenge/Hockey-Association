import 'package:flutter/material.dart';

class AddTeamMemberPage extends StatefulWidget {
  const AddTeamMemberPage({super.key});

  @override
  State<AddTeamMemberPage> createState() => _AddTeamMemberPageState();
}

class _AddTeamMemberPageState extends State<AddTeamMemberPage> {
  TextEditingController searchController = TextEditingController();

  // Mock player list (normally fetched from backend)
  List<Map<String, String>> allPlayers = [
    {'name': 'Anna Shilongo', 'email': 'anna@hockey.com'},
    {'name': 'Tomas Nangolo', 'email': 'tomas@hockey.com'},
    {'name': 'Elsa Kamati', 'email': 'elsa@hockey.com'},
  ];

  List<Map<String, String>> filteredPlayers = [];

  @override
  void initState() {
    super.initState();
    filteredPlayers = allPlayers;
  }

  void _filterPlayers(String query) {
    final filtered = allPlayers.where((player) {
      final name = player['name']!.toLowerCase();
      final email = player['email']!.toLowerCase();
      return name.contains(query.toLowerCase()) || email.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredPlayers = filtered;
    });
  }

  void _addPlayer(Map<String, String> player) {
    // Logic to add player to team
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${player['name']} added to team')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Image.asset(
          'lib/images/logo.jpg',
          height: 50,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Add Team Members',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search players by name or email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterPlayers,
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: filteredPlayers.length,
                itemBuilder: (context, index) {
                  final player = filteredPlayers[index];
                  return Card(
                    child: ListTile(
                      title: Text(player['name']!),
                      subtitle: Text(player['email']!),
                      trailing: IconButton(
                        icon: const Icon(Icons.person_add, color: Colors.blue),
                        onPressed: () => _addPlayer(player),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
