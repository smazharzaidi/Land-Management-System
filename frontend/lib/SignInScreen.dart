import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/SignInAuth.dart';
import 'package:frontend/SignUpScreen.dart';
import 'DashboardScreen.dart'; // Import the DashboardScreen

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isEmail = true;
  bool isLoading = false; // Added loading state variable
  TextEditingController signInController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final AuthServiceLogin _authService = AuthServiceLogin();

  void _handleLogin() async {
    setState(() {
      isLoading = true; // Start loading
    });

    String username = signInController.text.trim();
    String password = passwordController.text.trim();

    if (username.isNotEmpty && password.isNotEmpty) {
      try {
        final String result = await _authService.login(username, password);
        final Map<String, dynamic> response = json.decode(result);

        if (response.containsKey('error')) {
          _showErrorDialog(response['error']);
        } else if (response.containsKey('message') &&
            response['message'] == "Login successful") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        } else {
          _showErrorDialog('Unexpected response from server.');
        }
      } catch (e) {
        _showErrorDialog(e.toString());
      } finally {
        setState(() {
          isLoading = false; // End loading
        });
      }
    } else {
      _showErrorDialog('Please enter both email/CNIC and password.');
      setState(() {
        isLoading = false; // End loading if input validation fails
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 150.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('Sign In',
                      style: TextStyle(color: Colors.white)),
                  background: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/Field_in_K%C3%A4rk%C3%B6l%C3%A4.jpg/275px-Field_in_K%C3%A4rk%C3%B6l%C3%A4.jpg',
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
                        onPressed:
                            _handleLogin, // Updated to use _handleLogin function
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
          if (isLoading) // Check if loading
            Positioned(
              child: Container(
                color:
                    Colors.black.withOpacity(0.5), // Semi-transparent overlay
                child: Center(
                  child: CircularProgressIndicator(), // Loading indicator
                ),
              ),
            ),
        ],
      ),
    );
  }
}
