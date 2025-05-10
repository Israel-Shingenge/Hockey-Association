import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  String? message;

  // Function to send reset email
  Future<void> _sendResetEmail() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      setState(() => message = 'Password reset email sent!');
    } on FirebaseAuthException catch (e) {
      setState(() => message = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Enter your email'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendResetEmail,
              child: const Text('Send Reset Email'),
            ),
            const SizedBox(height: 12),
            if (message != null)
              Text(
                message!,
                style: TextStyle(
                  color: message!.startsWith('Password reset') 
                      ? Colors.green 
                      : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
