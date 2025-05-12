import 'package:flutter/material.dart';
import 'team_profile.dart';
import 'create_team.dart';

class MyTeamsPage extends StatelessWidget {
  final String userRole; // 'manager', 'player', 'admin'
  final String userId;

  const MyTeamsPage({super.key, required this.userRole, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Mock teams data
    final List<Map<String, String>> teams = [
      {'name': 'Desert Lions', 'createdBy': 'manager123'},
      {'name': 'Namib Falcons', 'createdBy': 'manager456'},
    ];

    // Filter based on user role
    List<Map<String, String>> visibleTeams = [];
    if (userRole == 'manager') {
      visibleTeams =
          teams.where((team) => team['createdBy'] == userId).toList();
    } else {
      visibleTeams = teams; // player/admin: see all relevant
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Image.asset('lib/images/logo.jpg', height: 50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'My Teams',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: visibleTeams.length,
                itemBuilder: (context, index) {
                  final team = visibleTeams[index];
                  return Card(
                    child: ListTile(
                      title: Text(team['name']!),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => TeamProfilePage(
                                  teamName: team['name']!,
                                  createdBy: team['createdBy']!,
                                  userRole: userRole,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            if (userRole == 'manager')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Create Team'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateTeamPage(),
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
