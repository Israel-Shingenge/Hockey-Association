import 'package:flutter/material.dart';

class CommitteePage extends StatelessWidget {
  final bool isAdmin; // Passed from session/login logic

  const CommitteePage({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    // Placeholder committee data
    final List<Map<String, String>> committeeMembers = [
      {'position': 'President', 'name': 'John Amutenya'},
      {'position': 'Vice President', 'name': 'Selma Kambonde'},
      {'position': 'Secretary', 'name': 'Peter Shivute'},
    ];

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Committee Members',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // List of members
            Expanded(
              child: ListView.builder(
                itemCount: committeeMembers.length,
                itemBuilder: (context, index) {
                  final member = committeeMembers[index];
                  return Card(
                    elevation: 2,
                    child: ListTile(
                      title: Text(member['position']!),
                      subtitle: Text(member['name']!),
                      trailing:
                          isAdmin
                              ? IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  // Handle delete logic here
                                },
                              )
                              : null,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Admin-only "Add Member" button
            if (isAdmin)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Committee Member'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    // Navigate to "Create Committee Member" page or show modal
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
