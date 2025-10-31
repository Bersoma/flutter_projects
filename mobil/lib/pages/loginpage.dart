import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            children: [
              Text('Login/Signup'),
              Text('User name'),
              TextField(),
            ],
          ),
        ),
      ),
    ),
  }
}