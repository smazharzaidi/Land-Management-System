import 'dart:convert';
import 'package:flutter/material.dart';
import 'SignInScreen.dart'; // Make sure this import is correct based on your project structure
import 'SignUpAuth.dart'; // Replace with the correct import path for your AuthService

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  bool isLoading = false; // Loading state variable

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
                  title: const Text('Sign Up',
                      style: TextStyle(color: Colors.white)),
                  background: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/Field_in_K%C3%A4rk%C3%B6l%C3%A4.jpg/275px-Field_in_K%C3%A4rk%C3%B6l%C3%A4.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          hintText: 'Enter your username',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: mobileNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number',
                          hintText: 'Enter your mobile number',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: cnicController,
                        decoration: const InputDecoration(
                          labelText: 'CNIC',
                          hintText: 'Enter your CNIC',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () => handleRegistration(context),
                        child: const Text('Sign Up',
                            style: TextStyle(color: Colors.white)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignInScreen()),
                        ),
                        child: const Text('Already have an account? Sign In'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isLoading) // Loading overlay
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> handleRegistration(BuildContext context) async {
    setState(() => isLoading = true);

    try {
      String response = await AuthService().registration(
        usernameController.text,
        emailController.text,
        passwordController.text,
        nameController.text,
        mobileNumberController.text,
        cnicController.text,
      );
      final jsonResponse = json.decode(response);

      if (jsonResponse['data'] != null) {
        await _showDialog(context, 'Success', 'Registration successful.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      } else if (jsonResponse.containsKey('errors')) {
        // Dynamically handle both a single error message and an array of error messages
        String errorMessage;
        if (jsonResponse['errors'] is String) {
          errorMessage = jsonResponse['errors'];
        } else if (jsonResponse['errors'] is List) {
          errorMessage = jsonResponse['errors'].join('\n');
        } else {
          errorMessage = 'Unknown error occurred.';
        }
        await _showDialog(context, 'Error', errorMessage);
      } else {
        await _showDialog(context, 'Error', 'Registration failed.');
      }
    } catch (e) {
      print(e.toString()); // For debugging purposes
      await _showDialog(context, 'Error', 'An unexpected error occurred.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _showDialog(
      BuildContext context, String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
