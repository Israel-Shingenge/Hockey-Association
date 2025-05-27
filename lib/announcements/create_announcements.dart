import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for FirebaseAuth

class AnnouncementFormPage extends StatefulWidget {
  final Map<String, dynamic>? announcementData;
  final String? documentId; // To identify the document for updates

  const AnnouncementFormPage({
    super.key,
    this.announcementData,
    this.documentId,
  });

  @override
  State<AnnouncementFormPage> createState() => _AnnouncementFormPageState();
}

class _AnnouncementFormPageState extends State<AnnouncementFormPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Add a form key for validation

  String? _userRole; // Changed to nullable
  bool _loadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole(); // Fetch role on init
    if (widget.announcementData != null) {
      _titleController.text = widget.announcementData!['title'] ?? '';
      _descriptionController.text = widget.announcementData!['description'] ?? '';
    }
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
      print('Error fetching user role in AnnouncementFormPage: $e');
      setState(() {
        _userRole = 'player'; // Fallback role on error
        _loadingRole = false;
      });
    }
  }

  // Check if the current user has admin or manager privileges
  bool get _canManage => _userRole == 'Admin' || _userRole == 'Manager';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveAnnouncement() async {
    if (!_canManage) {
      _showPermissionDeniedSnackbar();
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with saving
      final String title = _titleController.text.trim();
      final String description = _descriptionController.text.trim();
      final Timestamp date = Timestamp.now(); // Automatically set current date

      try {
        if (widget.announcementData != null && widget.documentId != null) {
          // Update existing announcement
          await FirebaseFirestore.instance
              .collection('announcements')
              .doc(widget.documentId)
              .update({
            'title': title,
            'description': description,
            'date': date,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Announcement updated successfully!')),
          );
        } else {
          // Create new announcement
          await FirebaseFirestore.instance.collection('announcements').add({
            'title': title,
            'description': description,
            'date': date,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Announcement created successfully!')),
          );
        }
        Navigator.pop(context); // Go back after saving
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save announcement: $e')),
        );
        print("Error saving announcement: $e"); // For debugging
      }
    }
  }

  // This method is primarily for the delete button on the edit form.
  Future<void> _confirmAndDelete() async {
    if (!_canManage) {
      _showPermissionDeniedSnackbar();
      return;
    }

    if (widget.documentId == null) return; // Cannot delete if no document ID

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this announcement? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('announcements').doc(widget.documentId!).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement deleted successfully!')),
        );
        Navigator.pop(context); // Pops the form page
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete announcement: $e')),
        );
        print("Error deleting announcement from form: $e"); // For debugging
      }
    }
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
    bool isEditing = widget.announcementData != null;

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
          title: Text(
            isEditing ? 'Edit Announcement' : 'Create Announcement',
            style: const TextStyle(color: Colors.black87),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
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
                  'Only administrators or managers can create or edit announcements.',
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
        title: Text(
          isEditing ? 'Edit Announcement' : 'Create Announcement',
          style: const TextStyle(color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black87),
            onPressed: _saveAnnouncement,
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.orange[200],
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/NHU.png', // NHU logo for the form page
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.campaign, // Fallback icon if NHU.png isn't found
                          size: 80,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32.0),
                Text(
                  'Announcement Title',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter your title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                  style: const TextStyle(color: Colors.black87),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                Text(
                  'Announcement description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 8,
                  minLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Enter Your Text',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                  style: const TextStyle(color: Colors.black87),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32.0),
                if (isEditing)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete_forever, color: Colors.white),
                    label: const Text(
                      'Delete Announcement',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    onPressed: _confirmAndDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}