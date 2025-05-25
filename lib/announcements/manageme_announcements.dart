import 'package:flutter/material.dart';
import 'package:hockey_union/announcements/create_announcements.dart'; 

class ManageAnnouncementsPage extends StatefulWidget {
  // We'll pass the current list of announcements here for management
  final List<Map<String, String>> announcements;

  const ManageAnnouncementsPage({super.key, required this.announcements});

  @override
  State<ManageAnnouncementsPage> createState() => _ManageAnnouncementsPageState();
}

class _ManageAnnouncementsPageState extends State<ManageAnnouncementsPage> {
  // Use a mutable list for managing announcements locally within this page
  // In a real app, this would be managed by a state management solution (Provider, BLoC, Riverpod etc.)
  late List<Map<String, String>> _mutableAnnouncements;

  @override
  void initState() {
    super.initState();
    _mutableAnnouncements = List.from(widget.announcements); // Create a mutable copy
  }

  void _navigateToCreateAnnouncement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnnouncementFormPage(), // No data passed for creation
      ),
    ).then((result) {
      // Handle result if form returns new announcement data
      // For now, just print and refresh (in a real app, you'd add the new item)
      if (result != null && result is Map<String, String>) {
        setState(() {
          _mutableAnnouncements.add(result); // Add the new announcement
          // In a real app, you'd probably sort this or handle it according to your needs
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement created successfully!')),
        );
      }
    });
  }

  void _navigateToEditAnnouncement(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnnouncementFormPage(
          announcementData: _mutableAnnouncements[index],
        ),
      ),
    ).then((result) {
      // Handle result if form returns updated announcement data
      if (result != null && result is Map<String, String>) {
        setState(() {
          _mutableAnnouncements[index] = result; // Update the existing announcement
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement updated successfully!')),
        );
      }
    });
  }

  void _deleteAnnouncement(int index) {
    // Show a confirmation dialog before deleting
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this announcement?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  _mutableAnnouncements.removeAt(index);
                });
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Announcement deleted successfully!')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87), // Back button color
        title: const Text(
          'Manage Announcements',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _mutableAnnouncements.isEmpty
          ? const Center(
              child: Text(
                'No announcements to manage yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _mutableAnnouncements.length,
              itemBuilder: (context, index) {
                final announcement = _mutableAnnouncements[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  elevation: 1.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                announcement['title']!,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                announcement['description']!,
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueGrey),
                          onPressed: () => _navigateToEditAnnouncement(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAnnouncement(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateAnnouncement,
        label: const Text('Create New'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent, // Choose a suitable color
      ),
    );
  }
}