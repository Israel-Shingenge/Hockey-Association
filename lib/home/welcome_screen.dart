// lib/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:hockey_union/widget_tree.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/NHU.png', // Same logo as splash screen
              width: 150, // Adjust as needed
              height: 150, // Adjust as needed
            ),
            const SizedBox(height: 40),
            SizedBox(
            width: 250, 
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WidgetTree()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF303F9F),
                padding: const EdgeInsets.symmetric(vertical: 15), // Remove horizontal padding
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'SIGN UP',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WidgetTree()),
                );
              },
              child: const Text(
                'ALREADY HAVE AN ACCOUNT?',
                style: TextStyle(
                  color: Color(0xFF303F9F), // Match the text color
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}