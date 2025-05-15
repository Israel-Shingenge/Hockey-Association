import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LanguageSecurityPage extends StatefulWidget {
  const LanguageSecurityPage({super.key});

  @override
  State<LanguageSecurityPage> createState() => _LanguageSecurityPageState();
}

class _LanguageSecurityPageState extends State<LanguageSecurityPage> {
  String _language = 'English';
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  final _formKey = GlobalKey<FormState>();

  Future<void> _changePassword() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final cred = EmailAuthProvider.credential(
        email: user!.email!,
        password: _currentPassword.text.trim(),
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_newPassword.text.trim());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password updated.")));
      _currentPassword.clear();
      _newPassword.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Language & Security")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _language,
              decoration: const InputDecoration(labelText: "Language"),
              items: const [
                DropdownMenuItem(value: 'English', child: Text('English')),
                DropdownMenuItem(value: 'Afrikaans', child: Text('Afrikaans')),
                DropdownMenuItem(value: 'German', child: Text('German')),
              ],
              onChanged: (value) => setState(() => _language = value!),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _currentPassword,
                    obscureText: _obscureCurrent,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrent
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed:
                            () => setState(
                              () => _obscureCurrent = !_obscureCurrent,
                            ),
                      ),
                    ),
                    validator:
                        (val) =>
                            val == null || val.isEmpty
                                ? 'Enter current password'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newPassword,
                    obscureText: _obscureNew,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNew ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed:
                            () => setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                    validator:
                        (val) =>
                            val == null || val.length < 6
                                ? 'Minimum 6 characters'
                                : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _changePassword();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF060F7A),
                    ),
                    child: const Text(
                      'Change Password',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
