import 'package:flutter/material.dart';
import 'SignUpScreen.dart'; // Import DashboardScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Land Management Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SignUpScreen                                                 (), // Use the DashboardScreen widget
    );
  }
}
