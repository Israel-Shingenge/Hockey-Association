import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hockey_union/home/home_drawer.dart';

class AddPlayerPage extends StatefulWidget {
  const AddPlayerPage({super.key});

  @override
  State<AddPlayerPage> createState() => _AddPlayerPageState();
}

class _AddPlayerPageState extends State<AddPlayerPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthdayController = TextEditingController();
  String? _selectedGender;
  final _positionController = TextEditingController();
  final _jerseyNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _addPlayer() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final birthday = _birthdayController.text.trim();
    final gender = _selectedGender;
    final position = _positionController.text.trim();
    final jerseyNumber = int.tryParse(_jerseyNumberController.text.trim()) ?? 0;
    final email = _emailController.text.trim();
    final phone = int.tryParse(_phoneController.text.trim()) ?? 0;

    if (firstName.isNotEmpty && lastName.isNotEmpty && email.isNotEmpty) {
      // Save the player data to Firestore
      await FirebaseFirestore.instance.collection('Player').add({
        'firstName': firstName,
        'lastName': lastName,
        'birthday': birthday,
        'gender': gender,
        'position': position,
        'jerseyNumber': jerseyNumber,
        'email': email,
        'phone': phone,
        'createdAt': Timestamp.now(),
      });

      Navigator.of(context).pop(); // Go back to the previous page
    } else {
      // Show a message if any field is missing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all the required fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Center(
          child: SizedBox(
            height: 30,
            child: Image.asset(
              'assets/images/NHU.png', // Replace with your actual logo path
              fit: BoxFit.contain,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.blue[900], // Match the bar's background color
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Add Player',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      // You can add an optional icon here if needed
                    ],
                  ),
                ),
                // "Close" and "Save" buttons moved here to the bottom bar
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        actions: const [
          SizedBox(width: 56), // To offset the leading icon if title is centered
        ],
      ),
      drawer: const HomeDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Make children take full width
          children: <Widget>[
            const SizedBox(height: 24.0), // Added some top spacing below the AppBar
            const Text('Player details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
            const SizedBox(height: 8.0),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _birthdayController,
              decoration: InputDecoration(
                labelText: 'Birthday',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 12.0),
            const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: <Widget>[
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('M'),
                    value: 'M',
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('F'),
                    value: 'F',
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _positionController,
              decoration: const InputDecoration(labelText: 'Position', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _jerseyNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jersey number', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16.0),
            const Text('Contact information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
            const SizedBox(height: 8.0),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 32.0), // Increased spacing before the button
            // Centralized and wider Save button
            SizedBox(
              width: double.infinity, // Make the button take full width
              child: ElevatedButton(
                onPressed: _addPlayer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}