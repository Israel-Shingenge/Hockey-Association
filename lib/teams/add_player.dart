import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AddPlayerPage extends StatefulWidget {
  final String? teamId;

  const AddPlayerPage({super.key, this.teamId});

  @override
  State<AddPlayerPage> createState() => _AddPlayerPageState();
}

class _AddPlayerPageState extends State<AddPlayerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _jerseyNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDate;

  String? _currentUserRole;
  String? _selectedTeamId;
  String? _selectedTeamName;

  @override
  void initState() {
    super.initState();
    if (widget.teamId != null && widget.teamId!.isNotEmpty) {
      _selectedTeamId = widget.teamId;
      _fetchTeamName(_selectedTeamId!);
    }
    _fetchCurrentUserRole();
  }

  Future<void> _fetchCurrentUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _currentUserRole = userDoc.data()?['role'];
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not signed in.')),
      );
    }
  }

  Future<void> _fetchTeamName(String teamId) async {
    try {
      final teamDoc = await FirebaseFirestore.instance.collection('Teams').doc(teamId).get();
      if (teamDoc.exists) {
        setState(() {
          _selectedTeamName = teamDoc.data()?['clubName'];
        });
      }
    } catch (e) {
      print('Error fetching team name: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthdayController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _addPlayer() async {
    if (_selectedTeamId == null || _selectedTeamId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No team selected. Cannot add player.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('Player').add({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'birthday': _birthdayController.text.trim(),
          'gender': _selectedGender,
          'position': _positionController.text.trim(),
          'jerseyNumber': int.tryParse(_jerseyNumberController.text.trim()),
          'email': _emailController.text.trim(),
          'phone': int.tryParse(_phoneController.text.trim()),
          'teamId': _selectedTeamId,
          'firebaseAuthUid': null,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Player added successfully!')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add player: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthdayController.dispose();
    _positionController.dispose();
    _jerseyNumberController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserRole == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUserRole == 'Admin' && _selectedTeamId == null) {
      return _buildAdminTeamSelection(context);
    } else {
      return _buildPlayerForm(context);
    }
  }

  Widget _buildAdminTeamSelection(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Team to Add Player',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 11, 71, 182), 
        elevation: 0, 
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose a team to add a new player.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Teams').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No teams found in the database.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  final teams = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: teams.length,
                    itemBuilder: (context, index) {
                      final teamDoc = teams[index];
                      final teamData = teamDoc.data() as Map<String, dynamic>;
                      final teamName = teamData['clubName'] ?? 'Unnamed Team';
                      final teamLeague = teamData['clubLeague'] ?? 'No League';
                      final teamId = teamDoc.id;

                      final isSelected = _selectedTeamId == teamId;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTeamId = teamId;
                            _selectedTeamName = teamName;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Team "$teamName" selected.'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          elevation: isSelected ? 4 : 2, 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: isSelected
                                ? const BorderSide(color: Color.fromARGB(255, 11, 71, 182), width: 2) // Border for selected
                                : BorderSide.none,
                          ),
                          color: isSelected ? Colors.blueAccent.withOpacity(0.1) : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.sports_hockey, 
                                  color: isSelected ? Colors.blueAccent : Colors.grey[600],
                                  size: 30,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        teamName,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.blueAccent : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        teamLeague,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isSelected ? Colors.blue.shade700 : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle, color: Color.fromARGB(255, 11, 71, 182),),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (_selectedTeamId != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 11, 71, 182),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Center(
                    child: Text(
                      'Continue to Add Player Details',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerForm(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedTeamName != null
              ? 'Add Player to $_selectedTeamName'
              : 'Add Player',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      backgroundColor: const Color.fromARGB(255, 11, 71, 182),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (_currentUserRole == 'Admin' && _selectedTeamName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Adding player to: $_selectedTeamName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color:  Color.fromARGB(255, 11, 71, 182), width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter first name' : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color:  Color.fromARGB(255, 11, 71, 182), width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter last name' : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _birthdayController,
                decoration: InputDecoration(
                  labelText: 'Birthday (DD/MM/YYYY)',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today, color:  Color.fromARGB(255, 11, 71, 182),),
                    onPressed: () => _selectDate(context),
                  ),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 11, 71, 182), width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                readOnly: true,
                validator: (value) =>
                    value!.isEmpty ? 'Please select birthday' : null,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color:  Color.fromARGB(255, 11, 71, 182), width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                items: <String>['M', 'F', 'Other']
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select gender' : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: 'Position',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color:  Color.fromARGB(255, 11, 71, 182), width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter position' : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _jerseyNumberController,
                decoration: const InputDecoration(
                  labelText: 'Jersey Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 11, 71, 182), width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter jersey number';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color:  Color.fromARGB(255, 11, 71, 182), width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color:  Color.fromARGB(255, 11, 71, 182), width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _addPlayer,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: const Color.fromARGB(255, 11, 71, 182),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)), 
                ),
                child: const Text(
                  'Add Player',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}