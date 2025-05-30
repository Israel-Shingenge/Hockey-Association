import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hockey_union/home/home_drawer.dart';

class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clubNameController = TextEditingController();
  final TextEditingController _clubLeagueController = TextEditingController();
  final TextEditingController _clubContactPersonController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _clubDescriptionController = TextEditingController();

  Future<void> _saveTeamToFirestore() async {
    if (_formKey.currentState!.validate()) {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not signed in')),
        );
        return;
      }

      try {
        final teamRef = await FirebaseFirestore.instance.collection('Teams').add({
          'clubName': _clubNameController.text.trim(),
          'clubLeague': _clubLeagueController.text.trim(),
          'contactPerson': _clubContactPersonController.text.trim(),
          'email': _emailController.text.trim(),
          'phoneNumber': _phoneNumberController.text.trim(),
          'clubDescription': _clubDescriptionController.text.trim(),
          'managerFirebaseUid': uid, 
          'createdAt': FieldValue.serverTimestamp(),
          'logoUrl': null, 
        });

        await teamRef.collection('creatorInfo').doc('details').set({
          'createdByUid': uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Team created successfully')),
        );

        Navigator.of(context).pop(); 
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create team: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _clubNameController.dispose();
    _clubLeagueController.dispose();
    _clubContactPersonController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _clubDescriptionController.dispose();
    super.dispose();
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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.notifications),
          ),
        ],
      ),
      drawer: const HomeDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 30.0),
                const Center(
                  child: Text(
                    'Create Team',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                
                Container(
                  height: 1.0,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(horizontal: 0.0),
                ),
                const SizedBox(height: 30.0),
                
                _buildOutlineTextField(
                  controller: _clubNameController,
                  labelText: 'Club Name',
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter club name' : null,
                ),
                const SizedBox(height: 16.0),
                _buildOutlineTextField(
                  controller: _clubLeagueController,
                  labelText: 'Club League',
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter club league' : null,
                ),
                const SizedBox(height: 16.0),
                _buildOutlineTextField(
                  controller: _clubContactPersonController,
                  labelText: 'Club Contact Person',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter club contact person'
                      : null,
                ),
                const SizedBox(height: 16.0),
                _buildOutlineTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                _buildOutlineTextField(
                  controller: _phoneNumberController,
                  labelText: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter phone number'
                      : null,
                ),
                const SizedBox(height: 16.0),
                _buildOutlineTextField(
                  controller: _clubDescriptionController,
                  labelText: 'Club description',
                  maxLines: 3,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter club description' : null,
                ),
                const SizedBox(height: 40.0),
                SizedBox(
                  height: 50.0,
                  child: ElevatedButton( 
                    onPressed: _saveTeamToFirestore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 8, 67, 116), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                    ),
                    child: const Text(
                      'SAVE',
                      style: TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  
  Widget _buildOutlineTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }
}