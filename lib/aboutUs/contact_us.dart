import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:hockey_union/aboutUs/committee.dart';
import 'package:hockey_union/aboutUs/governance.dart';
import 'package:hockey_union/home/home_drawer.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Function to submit the query to Firestore
  Future<void> _submitQuery() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form fields (optional, but good practice)

      try {
        await FirebaseFirestore.instance.collection('Queries').add({
          'email': _emailController.text.trim(),
          'message': _messageController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(), 
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your query has been submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear the form fields
        _emailController.clear();
        _messageController.clear();
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit query: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
              'assets/images/NHU.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        backgroundColor: Colors.white, 
        elevation: 0, // Flat app bar
        actions: const [
          SizedBox(width: 56), // To balance the leading icon's width
        ],
      ),
      drawer: const HomeDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildAboutUsCard(context),
            const SizedBox(height: 20),
            _buildQueryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutUsCard(BuildContext context) {
    return Card(
      elevation: 4.0, // Added elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), 
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'About Us',
              style: TextStyle(
                fontSize: 22.0, 
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 11, 71, 182), // Highlighted color
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'The NHU is committed to developing\nhockey in Namibia for all athletes on\nevery level.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0, color: Colors.black87), // Darker text
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CommitteePage()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue[700], 
              ),
              child: const Text('Committee', style: TextStyle(fontSize: 16)), 
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GovernancePage()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue[700],
              ),
              child: const Text('Governance', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueryCard() {
    return Card(
      elevation: 4.0, // Added elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), 
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Assign the form key here
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Submit your Query',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.0, 
                  fontWeight: FontWeight.bold,
                  color:  Color.fromARGB(255, 11, 71, 182),
                ),
              ),
              const SizedBox(height: 20), // Increased spacing
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'your.email@example.com',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20), // Increased spacing
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'Type your message here...',
                  alignLabelWithHint: true, // Align label to top for multiline
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                maxLines: 5, // Allow more lines for messages
                minLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your message';
                  }
                  if (value.length < 10) {
                    return 'Message must be at least 10 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30), // Increased spacing
              ElevatedButton(
                onPressed: _submitQuery, // Call the submit function
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 11, 71, 182), 
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), 
                  ),
                ),
                child: const Text(
                  'SUBMIT QUERY', 
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}