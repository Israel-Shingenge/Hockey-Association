import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for FirebaseAuth
import 'package:hockey_union/announcements/manageme_announcements.dart';
import 'package:hockey_union/home/home_drawer.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentSortOrder = 'Newest'; // Can be 'Newest' or 'Oldest'

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
      print('Error fetching user role in AnnouncementPage: $e');
      setState(() {
        _userRole = 'player'; // Fallback role on error
        _loadingRole = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingRole) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Reference to your 'announcements' collection in Firestore.
    final CollectionReference announcementsCollection =
        FirebaseFirestore.instance.collection('announcements');

    Query announcementsQuery = announcementsCollection;

    // Apply sorting based on _currentSortOrder
    if (_currentSortOrder == 'Newest') {
      announcementsQuery = announcementsQuery.orderBy('date', descending: true);
    } else {
      announcementsQuery = announcementsQuery.orderBy('date', descending: false);
    }

    // Determine if the current user is an admin or manager
    bool isAdminOrManager = _userRole == 'Admin';

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Center(
          child: SizedBox(
            height: 30,
            child: Image.asset(
              'assets/images/NHU.png', 
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: const [], // Actions removed from AppBar, now in body if needed
      ),
      drawer: const HomeDrawer(),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Announcements',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: [
                      _buildFilterPopupMenu(),
                      const SizedBox(width: 8.0),
                      if (isAdminOrManager) // Only show manage button for admins/managers
                        _buildManageAnnouncementsButton(context),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: announcementsQuery.snapshots(),
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
                        'No announcements available.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final announcementDoc = snapshot.data!.docs[index];
                      final announcementData =
                          announcementDoc.data() as Map<String, dynamic>;
                      final String docId = announcementDoc.id; // Get document ID

                      // Ensure date is handled as Timestamp and converted to DateTime
                      final DateTime date =
                          (announcementData['date'] as Timestamp).toDate();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildNewsCard(
                          docId: docId, // Pass the document ID
                          title: announcementData['title'] ?? 'No Title',
                          description: announcementData['description'] ?? 'No Description',
                          date: date,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPopupMenu() {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        setState(() {
          _currentSortOrder = result;
        });
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'Newest',
          child: Text('Newest'),
        ),
        const PopupMenuItem<String>(
          value: 'Oldest',
          child: Text('Oldest'),
        ),
      ],
      icon: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(8.0),
        child: const Icon(Icons.filter_list, color: Colors.black54),
      ),
    );
  }

  Widget _buildManageAnnouncementsButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
      ),
      child: IconButton(
        icon: const Icon(Icons.edit, color: Colors.black54),
        onPressed: () {
          // Navigate to the ManageAnnouncementsPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageAnnouncementsPage(),
            ),
          );
        },
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildNewsCard({
    required String docId, // Now takes document ID
    required String title,
    required String description,
    required DateTime date,
  }) {
    // Format the date for display
    final String formattedDate = DateFormat('MMM d, y').format(date);

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Always use the NHU logo
            Container(
              width: 120,
              height: 165,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  'assets/images/NHU.png', // Dynamic image replaced with NHU logo
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(Icons.broken_image, color: Colors.grey[400]),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[700],
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}