// lib/register_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hockey_union/authentication/login.dart';
import 'auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _controllerEmail = TextEditingController();
  final _phoneController = TextEditingController();
  final _genderController = TextEditingController();
  final _controllerPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? errorMessage = '';
  bool _isPasswordVisible = false;
  String? _selectedRole;
  final List<String> _roles = ['Manager', 'Admin', 'Player'];

  Future<void> createUserWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final userCred = await Auth().createUserWithEmailAndPassword(
        fullName: _firstNameController.text,
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      String fullName = '${_firstNameController.text} ${_lastNameController.text}';
      await userCred.user?.updateDisplayName(fullName);

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCred.user?.uid)
          .set({
        'uid': userCred.user?.uid,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _controllerEmail.text,
        'phone': _phoneController.text,
        'gender': _genderController.text,
        'role': _selectedRole ?? 'Player',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {}); // triggers stream in WidgetTree
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
    }
  }

  Widget _entryField(String label, TextEditingController c,
      {bool obscure = false, TextInputType? keyboard}) {
    final isPassword = label.toLowerCase() == 'password';

    return TextFormField(
      controller: c,
      obscureText: isPassword ? !_isPasswordVisible : obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: label, // Changed from labelText to hintText
        border: const OutlineInputBorder(), // Added border
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
      validator: (value) => value == null || value.isEmpty ? 'Enter $label' : null,
    );
  }

  Widget _errorMessage() {
    return errorMessage == null || errorMessage == ''
        ? const SizedBox.shrink()
        : Text(errorMessage!, style: const TextStyle(color: Colors.red));
  }

  Widget _roleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      items: _roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
      onChanged: (val) => setState(() => _selectedRole = val),
      decoration: const InputDecoration(
        hintText: 'Select Role', // Changed labelText to hintText
        border: OutlineInputBorder(),
      ),
      validator: (value) => value == null ? 'Please select a role' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Text(
                      'Sign Up',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      'Hello! Welcome',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24.0),
                    _entryField('First Name', _firstNameController),
                    const SizedBox(height: 16.0),
                    _entryField('Last Name', _lastNameController),
                    const SizedBox(height: 16.0),
                    _entryField('Email', _controllerEmail,
                        keyboard: TextInputType.emailAddress),
                    const SizedBox(height: 16.0),
                    _entryField('Phone Number', _phoneController,
                        keyboard: TextInputType.phone),
                    const SizedBox(height: 16.0),
                    _entryField('Gender', _genderController),
                    const SizedBox(height: 16.0),
                    _roleDropdown(),
                    const SizedBox(height: 16.0),
                       _entryField('Password', _controllerPassword, obscure: true),
                    const SizedBox(height: 16.0),
                    _errorMessage(),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: createUserWithEmailAndPassword,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: const Text('SIGN UP', style: TextStyle(fontSize: 16.0)),
                    ),
                    const SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()), // Navigate back to LoginPage
                        );
                      },
                      child: const Text('Already have an account? Log In'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}