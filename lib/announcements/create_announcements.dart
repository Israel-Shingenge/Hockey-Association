import 'package:flutter/material.dart';

class AnnouncementFormPage extends StatefulWidget {
  // Optional: Add parameters to pass existing announcement data for editing
  final Map<String, String>? announcementData;

  const AnnouncementFormPage({super.key, this.announcementData});

  @override
  State<AnnouncementFormPage> createState() => _AnnouncementFormPageState();
}

class _AnnouncementFormPageState extends State<AnnouncementFormPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.announcementData != null) {
      _titleController.text = widget.announcementData!['title'] ?? '';
      _descriptionController.text = widget.announcementData!['description'] ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.announcementData != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Announcement' : 'Create Announcement',
          style: const TextStyle(color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87), // Close icon
          onPressed: () {
            Navigator.pop(context); // Close the form page
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black87), // Save/Done icon
            onPressed: () {
              // TODO: Implement save functionality here
              // For now, just pop the page
              print('Save button pressed');
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.orange[200], // Background color similar to the image
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.campaign, // Megaphone icon
                    size: 80,
                    color: Colors.red, // Megaphone color
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
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter your title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                style: const TextStyle(color: Colors.black87),
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
              TextField(
                controller: _descriptionController,
                maxLines: 8, // Make it multiline
                minLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter Your Text',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 32.0),
              // Delete button, only shown if editing an existing announcement
              if (isEditing)
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete_forever, color: Colors.white),
                  label: const Text(
                    'Delete Announcement',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: () {
                    // TODO: Implement delete functionality
                    print('Delete button pressed');
                    Navigator.pop(context); // For now, just pop
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Delete button color
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
    );
  }
}