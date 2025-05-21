import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class PlayerProfilePage extends StatefulWidget {
  final String playerId;
  final Map<String, dynamic> playerData;

  const PlayerProfilePage({
    super.key,
    required this.playerId,
    required this.playerData, required String playerName,
  });

  @override
  State<PlayerProfilePage> createState() => _PlayerProfilePageState();
}

class _PlayerProfilePageState extends State<PlayerProfilePage> {
  // Make _playerDocRef nullable or handle its late initialization carefully
  DocumentReference? _playerDocRef; // Changed to nullable
  bool _isPlayerIdValid = true; // New state variable to track validity

  @override
  void initState() {
    super.initState();
    // ⭐ Add this debug print to see what playerId is being received
    debugPrint('PlayerProfilePage: Received playerId: "${widget.playerId}"');

    if (widget.playerId.isEmpty) {
      _isPlayerIdValid = false;
      // Schedule a message to be shown after the build cycle
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) { // Ensure widget is still in tree
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Player profile cannot be loaded due to missing ID.')),
          );
        }
      });
      debugPrint('PlayerProfilePage: Detected empty playerId. Will not initialize Firestore query.');
    } else {
      _playerDocRef = FirebaseFirestore.instance.collection('Player').doc(widget.playerId);
    }
  }

  // --- Helper function to display data or "Add" button ---
  Widget _buildProfileTile({
    required String title,
    String? value,
    VoidCallback? onAddEdit,
    IconData? icon,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: value != null && value.isNotEmpty
          ? Text(value, style: const TextStyle(fontWeight: FontWeight.bold))
          : null,
      trailing: onAddEdit != null
          ? TextButton.icon(
              onPressed: onAddEdit,
              icon: Icon(value != null && value.isNotEmpty ? Icons.edit : Icons.add),
              label: Text(value != null && value.isNotEmpty ? 'Edit' : 'Add'),
            )
          : (icon != null ? Icon(icon) : null),
    );
  }

  // --- Dialog for Date of Birth ---
  Future<void> _editDateOfBirth(BuildContext context, DateTime? currentDob) async {
    // Only proceed if _playerDocRef is initialized and valid
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
      await _playerDocRef!.update({ // Use ! because we checked for null
        'dateOfBirth': Timestamp.fromDate(pickedDate), // Store as Timestamp
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Date of Birth updated!')));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update Date of Birth: $error')));
      });
    }
  }

  // --- Dialog for Gender ---
  Future<void> _editGender(BuildContext context, String? currentGender) async {
    // Only proceed if _playerDocRef is initialized and valid
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
      await _playerDocRef!.update({ // Use ! because we checked for null
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

  // --- Add to Contacts Functionality (using flutter_contacts) ---
  Future<void> _addToContacts(Map<String, dynamic> playerData) async {
    // Request contacts permission using flutter_contacts
    bool granted = await FlutterContacts.requestPermission();

    if (granted) {
      try {
        final String firstName = playerData['firstName'] ?? '';
        final String lastName = playerData['lastName'] ?? '';
        final String? email = playerData['email'];
        final String? phoneNumber = playerData['phoneNumber'];

        if (firstName.isEmpty && lastName.isEmpty && (email == null && phoneNumber == null)) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No contact information available to add.')));
          return;
        }

        final Contact newContact = Contact();
        newContact.name = Name(first: firstName, last: lastName);

        if (email != null && email.isNotEmpty) {
          newContact.emails = [Email(email)];
        }
        if (phoneNumber != null && phoneNumber.isNotEmpty) {
          newContact.phones = [Phone(phoneNumber)];
        }

        await newContact.insert();

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$firstName $lastName added to contacts!')));
      } catch (e) {
        debugPrint('Error adding contact: $e'); // Use debugPrint
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
    // ⭐ If playerId was invalid, display an error screen instead of crashing
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

    // ⭐ Normal build logic proceeds only if playerId is valid
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        // Use the nullable _playerDocRef, which is initialized only if valid
        stream: _playerDocRef!.snapshots(), // Use ! here as we've checked _isPlayerIdValid
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // Include snapshot.error for better debugging
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
          final String formattedDob = dob != null ? DateFormat('MMM d, yyyy').format(dob) : '';
          final String gender = playerData['gender'] ?? '';
          final String email = playerData['email'] ?? 'N/A';
          final String phoneNumber = playerData['phoneNumber'] ?? 'N/A';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: Colors.blue[900],
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.person, size: 40.0, color: Colors.white),
                      const SizedBox(width: 16.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 20.0),

                const Text(
                  'Other Details',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
                const SizedBox(height: 8.0),
                _buildProfileTile(
                  title: 'Current Team',
                  value: playerData['teamName'] ?? 'N/A',
                  icon: Icons.group,
                ),
                const Divider(),
                _buildProfileTile(
                  title: 'Position',
                  value: position,
                  icon: Icons.sports_hockey,
                ),
                const Divider(),
                _buildProfileTile(
                  title: 'Notes',
                  value: playerData['notes'] ?? 'No notes',
                  icon: Icons.notes,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}