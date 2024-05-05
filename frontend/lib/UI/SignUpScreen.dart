import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Functionality/CNICInputFormatter.dart';
import '../Functionality/SignUpAuth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

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
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 90.0),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                    ),
                    onPressed: () => handleRegistration(context),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
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
                ),
              ],
            ),
          ),
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
          MaterialPageRoute(builder: (context) => const SignUpScreen()),
        );
      } else if (jsonResponse.containsKey('errors')) {
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
      print(e.toString());
      await _showDialog(context, 'Error', 'An unexpected error occurred.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _showDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
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
