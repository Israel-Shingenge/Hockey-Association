import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hockey_union/authentication/forgot_password.dart';
import 'auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _controllerEmail = TextEditingController();
  final _phoneController = TextEditingController();
  final _genderController = TextEditingController();

  final _controllerPassword = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String? errorMessage = '';
  bool isLogin = true;

  // Role dropdown state
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


    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
    }
  }

  Future<void> signInWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
    }
  }

  Widget _entryField(String label, TextEditingController c, {bool obscure = false, TextInputType? keyboard}) {
    return TextFormField(
      controller: c,
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(labelText: label),
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
      items: _roles
          .map((role) => DropdownMenuItem(value: role, child: Text(role)))
          .toList(),
      onChanged: (val) => setState(() => _selectedRole = val),
      decoration: const InputDecoration(labelText: 'Select Role'),
      validator: (value) => value == null ? 'Please select a role' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (!isLogin) ...[
                  _entryField('First Name', _firstNameController),
                  _entryField('Last Name', _lastNameController),
                  _entryField('Phone Number', _phoneController, keyboard: TextInputType.phone),
                  _entryField('Gender', _genderController),
                  _roleDropdown(),
                ],
                _entryField('Email', _controllerEmail, keyboard: TextInputType.emailAddress),
                _entryField('Password', _controllerPassword, obscure: true),
                const SizedBox(height: 8),
                _errorMessage(),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: isLogin
                      ? signInWithEmailAndPassword
                      : createUserWithEmailAndPassword,
                  child: Text(isLogin ? 'Login' : 'Register'),
                ),
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(isLogin
                      ? 'Don\'t have an account? Register'
                      : 'Already have an account? Login'),
                ),
                if (isLogin)
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                    ),
                    child: const Text('Forgot Password?'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
