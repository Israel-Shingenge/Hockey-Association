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
  // Controllers for text fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _controllerEmail = TextEditingController();
  final _controllerPassword = TextEditingController();
  String? errorMessage = '';
  bool isLogin = true;

  // Function to register a user
  Future<void> createUserWithEmailAndPassword() async {
    try {
      final userCred = await Auth().createUserWithEmailAndPassword(
        fullName: _firstNameController.text,
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      // Set display name after registration
      String fullName = '${_firstNameController.text} ${_lastNameController.text}';
      await userCred.user?.updateDisplayName(fullName);

    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
    }
  }

  // Function to sign in a user
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

  // Widgets for the entry fields
  Widget _entryField(String label, TextEditingController c) {
    return TextField(
      controller: c,
      decoration: InputDecoration(labelText: label),
    );
  }

  // Widget for displaying error messages
  Widget _errorMessage() {
    return Text(
      errorMessage == null || errorMessage == '' ? '' : errorMessage!,
      style: const TextStyle(color: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isLogin) ...[
              _entryField('First Name', _firstNameController),
              _entryField('Last Name', _lastNameController),
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
    );
  }
}
