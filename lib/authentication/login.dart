// lib/login_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hockey_union/authentication/forgot_password.dart';
import 'package:hockey_union/authentication/register.dart';
import 'package:hockey_union/widget_tree.dart';
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

      // Navigate to WidgetTree after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WidgetTree()),
      );
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
        hintText: 'Enter $label', // Changed from labelText to hintText
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
                      'Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      'Hello! Welcome back',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24.0),
                    _entryField('Email', _controllerEmail,
                        keyboard: TextInputType.emailAddress),
                    const SizedBox(height: 16.0),
                    _entryField('Password', _controllerPassword, obscure: true),
                    const SizedBox(height: 16.0),
                    _errorMessage(),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: signInWithEmailAndPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF303F9F),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: const Text(
                          'LOGIN',
                          style: TextStyle(fontSize: 16.0, color: Colors.white), // 👈 Optional: text color
                        ),
                      ),
                    const SizedBox(height: 16.0),
                    Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // Make buttons take full width
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterPage()), // Navigate to RegisterPage
                          );
                        },
                        child: const Text('Don\'t have an account? Sign Up', textAlign: TextAlign.center,),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ForgotPasswordPage()),
                        ),
                        child: const Text('Forgot your password? Reset', textAlign: TextAlign.center,),
                      ),
                    ],
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