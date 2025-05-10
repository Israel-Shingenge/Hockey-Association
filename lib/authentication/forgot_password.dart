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
  bool _isSending = false;

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => message = 'Please enter your email');
      return;
    }

    setState(() {
      _isSending = true;
      message = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() => message = 'Password reset email sent!');

      // Delay, then navigate back
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() => message = e.message);
    } finally {
      setState(() => _isSending = false);
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
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _isSending
                ? const CircularProgressIndicator()
                : ElevatedButton(
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
