// lib/login_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hockey_union/authentication/forgot_password.dart';
import 'package:hockey_union/authentication/register.dart';
import 'auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _controllerEmail = TextEditingController();
  final _controllerPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? errorMessage = '';
  bool _isPasswordVisible = false;

  Future<void> signInWithEmailAndPassword() async {
  if (!_formKey.currentState!.validate()) return;

  try {
    await Auth().signInWithEmailAndPassword(
      email: _controllerEmail.text,
      password: _controllerPassword.text,
    );
    setState(() {}); // this will trigger rebuild and the stream will redirect
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
        labelText: label,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _entryField('Email', _controllerEmail, keyboard: TextInputType.emailAddress),
                _entryField('Password', _controllerPassword, obscure: true),
                const SizedBox(height: 8),
                _errorMessage(),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: signInWithEmailAndPassword,
                  child: const Text('Login'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterPage()), // Navigate to RegisterPage
                    );
                  },
                  child: const Text('Don\'t have an account? Register'),
                ),
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