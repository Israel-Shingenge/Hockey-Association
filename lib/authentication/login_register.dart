import 'dart:async';
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
  final _controllerPassword = TextEditingController();
  String? errorMessage = '';
  bool isLogin = true;

  // New: Role dropdown value
  String? _selectedRole;
  final List<String> _roles = ['manager', 'admin', 'player'];

  Future<void> createUserWithEmailAndPassword() async {
    try {
      final userCred = await Auth().createUserWithEmailAndPassword(
        fullName: _firstNameController.text,
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      String fullName = '${_firstNameController.text} ${_lastNameController.text}';
      await userCred.user?.updateDisplayName(fullName);

      // You can also store `_selectedRole` in Firestore here if needed
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
    }
  }

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
    }
  }

  Widget _entryField(String label, TextEditingController c) {
    return TextField(
      controller: c,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == null || errorMessage == '' ? '' : errorMessage!,
      style: const TextStyle(color: Colors.red),
    );
  }

  // New: Role dropdown widget
  Widget _roleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      items: _roles
          .map((role) => DropdownMenuItem(value: role, child: Text(role)))
          .toList(),
      onChanged: (val) => setState(() => _selectedRole = val),
      decoration: const InputDecoration(labelText: 'Select Role'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView( // prevents overflow
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isLogin) ...[
                _entryField('First Name', _firstNameController),
                _entryField('Last Name', _lastNameController),
                _roleDropdown(), // show dropdown only on Register
              ],
              _entryField('Email', _controllerEmail),
              _entryField('Password', _controllerPassword),
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
    );
  }
}
