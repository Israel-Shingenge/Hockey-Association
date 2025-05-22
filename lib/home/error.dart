import 'package:flutter/material.dart';
import 'package:hockey_union/home/home_drawer.dart'; 

class NotRegisteredPage extends StatelessWidget {
  const NotRegisteredPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900], 
        iconTheme: const IconThemeData(color: Colors.white), 
        title: Center( 
          child: Image.asset(
            'assets/images/NHU.png', 
            height: 40, 
          ),
        ),
      ),
      drawer: const HomeDrawer(),
      body: const Center( 
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'You are currently not registered for a team. Please ask your manager to register you for a team.',
            textAlign: TextAlign.center, 
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}