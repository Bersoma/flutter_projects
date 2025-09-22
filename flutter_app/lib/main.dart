import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/navbar_widgets.dart';

void main() {
  runApp(const MyApp());
}

//stateless
//MaterialApp
//Scaffold

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Flutter Mapp'), centerTitle: true),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
        ),
        bottomNavigationBar: NavbarWidgets(),
      ),
    );
  }
}
