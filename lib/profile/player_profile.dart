import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerProfilePage extends StatefulWidget {
  final String playerId;
  final Map<String, dynamic> playerData;

  const PlayerProfilePage({
    super.key,
    required this.playerId,
    required this.playerData,
    required String playerName,
  });

  @override
  State<PlayerProfilePage> createState() => _PlayerProfilePageState();
}

class _PlayerProfilePageState extends State<PlayerProfilePage> {
  DocumentReference? _playerDocRef;
  bool _isPlayerIdValid = true;
  String? _profileImagePath; 

  @override
  void initState() {
    super.initState();

    debugPrint('PlayerProfilePage: Received playerId: "${widget.playerId}"');

    if (widget.playerId.isEmpty) {
      _isPlayerIdValid = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Error: Player profile cannot be loaded due to missing ID.')),
          );
        }
      });
      debugPrint('PlayerProfilePage: Detected empty playerId. Will not initialize Firestore query.');
    } else {
      _playerDocRef = FirebaseFirestore.instance.collection('Player').doc(widget.playerId);
      _loadImage(); 
    }
  }

  // Method to load the saved image path from SharedPreferences
  Future<void> _loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profile_image_${widget.playerId}');
    });
  }

  // Method to pick an image, save it locally, and store its path
  Future<void> _pickAndSaveImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${widget.playerId}_profile.png'; 
      final localImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_${widget.playerId}', localImage.path);

      setState(() {
        _profileImagePath = localImage.path;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected.')),
        );
      }
    }
  }

  // Method to remove the profile picture
  Future<void> _removeProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? imagePath = prefs.getString('profile_image_${widget.playerId}');

    if (imagePath != null) {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete(); 
      }
      await prefs.remove('profile_image_${widget.playerId}'); 

      setState(() {
        _profileImagePath = null; 
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture removed!')),
        );
      }
    }
  }

  Widget _buildProfileTile({
    required String title,
    String? value,
    VoidCallback? onAddEdit,
    IconData? icon,
  }) {
    return ListTile(
      title: Text(title),
      subtitle:
          value != null && value.isNotEmpty ? Text(value, style: const TextStyle(fontWeight: FontWeight.bold)) : null,
      trailing: onAddEdit != null
          ? TextButton.icon(
              onPressed: onAddEdit,
              icon: Icon(value != null && value.isNotEmpty ? Icons.edit : Icons.add),
              label: Text(value != null && value.isNotEmpty ? 'Edit' : 'Add'),
            )
          : (icon != null ? Icon(icon) : null),
    );
  }

  Future<void> _editDateOfBirth(BuildContext context, DateTime? currentDob) async {
    if (!_isPlayerIdValid || _playerDocRef == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot edit: Invalid player profile.')));
      return;
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      await _playerDocRef!.update({
        'dateOfBirth': Timestamp.fromDate(pickedDate),
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Date of Birth updated!')));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update Date of Birth: $error')));
      });
    }
  }

  Future<void> _editGender(BuildContext context, String? currentGender) async {
    if (!_isPlayerIdValid || _playerDocRef == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot edit: Invalid player profile.')));
      return;
    }

    String? selectedGender = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Gender'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<String>(
                title: const Text('Male'),
                value: 'Male',
                groupValue: currentGender,
                onChanged: (String? value) {
                  Navigator.pop(context, value);
                },
              ),
              RadioListTile<String>(
                title: const Text('Female'),
                value: 'Female',
                groupValue: currentGender,
                onChanged: (String? value) {
                  Navigator.pop(context, value);
                },
              ),
              RadioListTile<String>(
                title: const Text('Other'),
                value: 'Other',
                groupValue: currentGender,
                onChanged: (String? value) {
                  Navigator.pop(context, value);
                },
              ),
            ],
          ),
        );
      },
    );

    if (selectedGender != null && selectedGender != currentGender) {
      await _playerDocRef!.update({
        'gender': selectedGender,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gender updated!')));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update Gender: $error')));
      });
    }
  }

  Future<void> _addToContacts(Map<String, dynamic> playerData) async {
    bool granted = await FlutterContacts.requestPermission();

    if (granted) {
      try {
        final String firstName = playerData['firstName'] ?? '';
        final String lastName = playerData['lastName'] ?? '';
        final String? email = playerData['email'];
        final String? phone = playerData['phone'];

        if (firstName.isEmpty && lastName.isEmpty && (email == null && phone == null)) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No contact information available to add.')));
          return;
        }

        final Contact newContact = Contact();
        newContact.name = Name(first: firstName, last: lastName);

        if (email != null && email.isNotEmpty) {
          newContact.emails = [Email(email)];
        }
        if (phone != null && phone.isNotEmpty) {
          newContact.phones = [Phone(phone)];
        }

        await newContact.insert();

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$firstName $lastName added to contacts!')));
      } catch (e) {
        debugPrint('Error adding contact: $e');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add contact: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contacts permission denied.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPlayerIdValid) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 60),
                SizedBox(height: 20),
                Text(
                  'Could not load player profile.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'The player ID is missing or invalid. Please go back and try again.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _playerDocRef!.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading player data: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Player not found or deleted.'));
          }

          final playerData = snapshot.data!.data() as Map<String, dynamic>;

          final String firstName = playerData['firstName'] ?? 'N/A';
          final String lastName = playerData['lastName'] ?? 'N/A';
          final String fullName = '$firstName $lastName'.trim();
          final String jerseyNumber = (playerData['jerseyNumber'] ?? '').toString();
          final String position = playerData['position'] ?? 'N/A';
          final Timestamp? dobTimestamp = playerData['dateOfBirth'] as Timestamp?;
          final DateTime? dob = dobTimestamp?.toDate();
          final String formattedDob = dob != null ? DateFormat('MMM d,yyyy').format(dob) : '';
          final String gender = playerData['gender'] ?? '';
          final String email = playerData['email'] ?? 'N/A';
          final String phoneNumber = playerData['phoneNumber'] ?? 'N/A';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Profile Picture and Player Info Container
                Container(
                  color: Colors.blue[900], 
                  padding: const EdgeInsets.all(16.0),
                  height: 160.0,
                  child: Row( 
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) { 
                              return AlertDialog(
                                title: const Text('Profile Picture'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      leading: const Icon(Icons.photo_library),
                                      title: const Text('Choose Photo'),
                                      onTap: () {
                                        _pickAndSaveImage();
                                        Navigator.of(dialogContext).pop(); 
                                      },
                                    ),
                                    if (_profileImagePath != null)
                                      ListTile(
                                        leading: const Icon(Icons.delete),
                                        title: const Text('Remove Photo'),
                                        onTap: () {
                                          _removeProfileImage();
                                          Navigator.of(dialogContext).pop(); 
                                        },
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: CircleAvatar(
                          radius: 40.0,
                          // Conditionally set background color only when no image
                          backgroundColor: _profileImagePath == null
                              ? Colors.white.withOpacity(0.2)
                              : Colors.transparent, 
                          child: _profileImagePath == null
                              ? const Icon(Icons.person, size: 40.0, color: Colors.white)
                              : ClipOval(
                                  child: Image.file(
                                    File(_profileImagePath!),
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            fullName,
                            style: const TextStyle(fontSize: 24.0, color: Colors.white),
                          ),
                          if (jerseyNumber.isNotEmpty && jerseyNumber != 'N/A')
                            Text(
                              '#$jerseyNumber',
                              style: TextStyle(fontSize: 18.0, color: Colors.white.withOpacity(0.8)),
                            ),
                          if (position.isNotEmpty && position != 'N/A')
                            Text(
                              position,
                              style: TextStyle(fontSize: 16.0, color: Colors.white.withOpacity(0.7)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                _buildProfileTile(
                  title: 'Date of Birth',
                  value: formattedDob,
                  onAddEdit: () => _editDateOfBirth(context, dob),
                ),
                const Divider(),
                _buildProfileTile(
                  title: 'Gender',
                  value: gender,
                  onAddEdit: () => _editGender(context, gender),
                ),
                const Divider(),

                const SizedBox(height: 16.0),

                const Text(
                  'Contact Information',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
                const SizedBox(height: 8.0),
                _buildProfileTile(
                  title: 'Email',
                  value: email,
                  icon: Icons.email_outlined,
                ),
                const Divider(),
                _buildProfileTile(
                  title: 'Phone Number',
                  value: phoneNumber,
                  icon: Icons.phone,
                ),
                const SizedBox(height: 16.0),

               
               Center(
                  child: SizedBox( 
                    width: double.infinity, 
                      child: ElevatedButton.icon(
                      onPressed: () => _addToContacts(playerData),
                      icon: const Icon(Icons.contact_phone),
                      label: const Text('Add to Phone Contacts'),
                      style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
           ),
         ),
                const SizedBox(height: 20.0),

                const Text(
                  '',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
                const SizedBox(height: 8.0),
                // _buildProfileTile(
                //   title: 'Current Team',
                //   value: playerData['teamName'] ?? 'N/A',
                //   icon: Icons.group,
                // ),
                // const Divider(),
                // _buildProfileTile(
                //   title: 'Position',
                //   value: position,
                //   icon: Icons.sports_hockey,
                // ),
                // const Divider(),
                // _buildProfileTile(
                //   title: 'Notes',
                //   value: playerData['notes'] ?? 'No notes',
                //   icon: Icons.notes,
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}