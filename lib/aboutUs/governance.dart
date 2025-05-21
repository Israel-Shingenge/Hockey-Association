import 'package:flutter/material.dart';
import 'package:hockey_union/home/home_drawer.dart';

class GovernancePage extends StatelessWidget {
  const GovernancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Center(
          child: SizedBox(
            height: 30, // Adjust height as needed
            child: Image.asset(
              'assets/images/NHU.png', // Replace with the actual URL of the logo
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: const [
          SizedBox(width: 56), // To center the title
        ],
      ),
      drawer: const HomeDrawer(), // Use the imported HomeDrawer here
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Our Strategy',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey, // Match the color
              ),
            ),
            const SizedBox(height: 40.0),
            _buildStrategyItem(
              icon: Icons.check_circle_outline,
              text: 'Promote Anti-doping policies',
              iconColor: Colors.orange, // Match the icon color
            ),
            const SizedBox(height: 30.0),
            _buildStrategyItem(
              icon: Icons.list_alt_outlined,
              text: 'Ensure local tournaments adhere to\ninternational standards',
              textAlign: TextAlign.center,
              iconColor: Colors.orange,
            ),
            const SizedBox(height: 30.0),
            _buildStrategyItem(
              icon: Icons.check_circle_outline,
              text: 'Promote free and fair competition\nenvironment',
              textAlign: TextAlign.center,
              iconColor: Colors.orange,
            ),
            const SizedBox(height: 30.0),
            _buildStrategyItem(
              icon: Icons.chat_bubble_outline,
              text: 'Develop hockey in every possible way',
              textAlign: TextAlign.center,
              iconColor: Colors.orange,
            ),
            const SizedBox(height: 30.0),
            _buildStrategyItem(
              icon: Icons.computer,
              text: 'Develop platforms to generate more viewers\nfor hockey',
              textAlign: TextAlign.center,
              iconColor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategyItem({
    required IconData icon,
    required String text,
    TextAlign? textAlign,
    Color? iconColor,
  }) {
    return Column(
      children: <Widget>[
        Icon(
          icon,
          size: 40.0,
          color: iconColor ?? Colors.grey,
        ),
        const SizedBox(height: 10.0),
        Text(
          text,
          textAlign: textAlign ?? TextAlign.left,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}