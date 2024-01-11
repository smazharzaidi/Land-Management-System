// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:frontend/SignUpScreen.dart';
import 'DashboardScreen.dart'; // Import the DashboardScreen

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isEmail = true; // Toggle state between Email and CNIC
  TextEditingController signInController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 150.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title:
                  const Text('Sign In', style: TextStyle(color: Colors.white)),
              background: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/Field_in_K%C3%A4rk%C3%B6l%C3%A4.jpg/275px-Field_in_K%C3%A4rk%C3%B6l%C3%A4.jpg', // Replace with your image URL
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: signInController,
                    decoration: InputDecoration(
                      labelText: isEmail ? 'Email' : 'CNIC',
                      hintText:
                          isEmail ? 'Enter your email' : 'Enter your CNIC',
                    ),
                    keyboardType: isEmail
                        ? TextInputType.emailAddress
                        : TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      setState(() {
                        isEmail = !isEmail;
                      });
                    },
                    child: Text(
                      isEmail ? 'Switch to CNIC' : 'Switch to Email',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                    ),
                    obscureText: true,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      // Implement sign-in logic
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DashboardScreen()),
                      );
                    },
                    child: const Text('Sign In',
                        style: TextStyle(color: Colors.white)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SignUpScreen()),
                    ),
                    child: const Text('Don\'t have an account? Sign Up'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
