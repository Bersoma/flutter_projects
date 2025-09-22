import 'package:flutter/material.dart';

class NavbarWidgets extends StatefulWidget {
  const NavbarWidgets({super.key});

  @override
  State<NavbarWidgets> createState() => _NavbarWidgetsState();
}

class _NavbarWidgetsState extends State<NavbarWidgets> {
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),

        NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
