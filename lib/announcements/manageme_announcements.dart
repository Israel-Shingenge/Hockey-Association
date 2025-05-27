import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for FirebaseAuth
import 'package:hockey_union/announcements/create_announcements.dart';

class ManageAnnouncementsPage extends StatefulWidget {
  const ManageAnnouncementsPage({super.key});

  @override
  State<ManageAnnouncementsPage> createState() => _ManageAnnouncementsPageState();
}

class _ManageAnnouncementsPageState extends State<ManageAnnouncementsPage> {
  final CollectionReference _announcementsCollection =
      FirebaseFirestore.instance.collection('announcements');

  String? _userRole; // Changed to nullable
  bool _loadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  // Directly load the user's role from Firestore, similar to your TeamPage
  Future<void> _loadUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _userRole = null; // No user logged in
          _loadingRole = false;
        });
        return;
      }

      final doc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();

      if (!doc.exists) {
        setState(() {
          _userRole = 'player'; // Fallback role if user document doesn't exist
          _loadingRole = false;
        });
        return;
      }

      final role = doc.data()?['role'] as String?;
      setState(() {
        _userRole = role ?? 'player'; // Default to player if no role found
        _loadingRole = false;
      });
    } catch (e) {
      print('Error fetching user role in ManageAnnouncementsPage: $e');
      setState(() {
        _userRole = 'player'; // Fallback role on error
        _loadingRole = false;
      });
    }
  }

  // Check if the current user has admin or manager privileges
  bool get _canManage => _userRole == 'Admin' || _userRole == 'Manager';

  void _navigateToCreateAnnouncement() {
    if (!_canManage) {
      _showPermissionDeniedSnackbar();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnnouncementFormPage(),
      ),
    ).then((_) {
      // Refresh role in case it was changed elsewhere (less common but good practice)
      _loadUserRole();
    });
  }

  void _navigateToEditAnnouncement(DocumentSnapshot doc) {
    if (!_canManage) {
      _showPermissionDeniedSnackbar();
      return;
    }
    // Pass the entire data and the document ID for editing
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnnouncementFormPage(
          announcementData: doc.data() as Map<String, dynamic>,
          documentId: doc.id, // Pass document ID for updates
        ),
      ),
    ).then((_) {
      // Refresh role in case it was changed elsewhere (less common but good practice)
      _loadUserRole();
    });
  }

  Future<void> _deleteAnnouncement(String docId) async {
    if (!_canManage) {
      _showPermissionDeniedSnackbar();
      return;
    }

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
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                try {
                  await _announcementsCollection.doc(docId).delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Announcement deleted successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete announcement: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You do not have permission to perform this action.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingRole) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_canManage) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
          title: const Text(
            'Manage Announcements',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 50, color: Colors.grey),
                SizedBox(height: 10),
                Text(
                  'Access Denied',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  'Only administrators or managers can manage announcements.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Manage Announcements',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _announcementsCollection.orderBy('date', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No announcements to manage yet. Create one!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot doc = snapshot.data!.docs[index];
              final Map<String, dynamic> announcement = doc.data() as Map<String, dynamic>;

              // Ensure date is handled as Timestamp and converted to DateTime
              final DateTime date = (announcement['date'] as Timestamp).toDate();

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
                              announcement['title'] ?? 'No Title',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              announcement['description'] ?? 'No Description',
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM d, y').format(date),
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueGrey),
                        onPressed: () => _navigateToEditAnnouncement(doc),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteAnnouncement(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: _canManage
          ? FloatingActionButton.extended(
              onPressed: _navigateToCreateAnnouncement,
              label: const Text('Create New'),
              icon: const Icon(Icons.add),
              backgroundColor: Colors.blueAccent,
            )
          : null, // Hide FAB if not admin/manager
    );
  }
}