/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hockey_union/authentication/auth.dart';
import 'package:hockey_union/authentication/login.dart';

import 'role_widget_tree.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return const RoleWidgetTree();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:hockey_union/authentication/login.dart';
import 'package:hockey_union/role_widget_tree.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  final bool _isLoggedIn = true; // Toggle manually for UI testing

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      return const RoleWidgetTree();
    } else {
      return const LoginPage();
    }
  }
}
