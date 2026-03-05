// rsharma - cw2: recipe book app
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const MyApp());

// root app widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Book',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // start with the home screen
      home: const HomeScreen(),
    );
  }
}
