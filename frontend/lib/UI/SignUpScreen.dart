import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Functionality/CNICInputFormatter.dart';
import 'SignInScreen.dart'; // Make sure this import is correct based on your project structure
import '../Functionality/SignUpAuth.dart'; // Replace with the correct import path for your AuthService

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
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Text(
                'Sign Up',
                style: GoogleFonts.lato(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(height: 80), // Space to move the form down a bit
                    buildTextField(usernameController, 'Username'),
                    buildTextField(emailController, 'Email'),
                    buildTextField(nameController, 'Full Name'),
                    buildTextField(mobileNumberController, 'Mobile Number',
                        keyboardType: TextInputType.phone),
                    buildTextField(cnicController, 'CNIC',
                        keyboardType: TextInputType.number,
                        inputFormatters: [CNICInputFormatter()]),
                    buildTextField(passwordController, 'Password',
                        initiallyObscure: true),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () => handleRegistration(context),
                      child: isLoading
                          ? CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              'Sign Up',
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignInScreen()),
                  ),
                  child: Text(
                    "Already have an account? Sign In",
                    style: GoogleFonts.lato(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            if (isLoading)
              Positioned(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String label, {
    bool initiallyObscure = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    bool obscureText = initiallyObscure;

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: GoogleFonts.lato(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: label == 'Password'
                  ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => obscureText = !obscureText);
                      },
                    )
                  : null,
            ),
            obscureText: obscureText,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters ?? [],
          ),
        );
      },
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
