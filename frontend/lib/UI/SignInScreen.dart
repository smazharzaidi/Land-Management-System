import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/Functionality/SignInAuth.dart';
import '../Functionality/CNICInputFormatter.dart';
import 'package:frontend/UI/SignUpScreen.dart';
import 'package:flutter/services.dart';
import 'DashboardScreen.dart'; // Import the DashboardScreen

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController forgotPasswordController =
      TextEditingController();
  bool isEmail = true;
  bool isLoading = false; // Added loading state variable
  TextEditingController signInController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final AuthServiceLogin _authService = AuthServiceLogin();

  void _handleLogin() async {
    setState(() => isLoading = true);

    String username = signInController.text.trim();
    String password = passwordController.text.trim();

    if (username.isNotEmpty && password.isNotEmpty) {
      try {
        String result = await _authService.login(username, password);
        if (result == "success") {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) =>
                  DashboardScreen(authService: _authService)));
        } else if (result == "Email not verified. Please verify your email.") {
          // Show the dialog for resending the verification email
          _showUnverifiedEmailDialog(username);
        } else {
          _showErrorDialog(result);
        }
      } catch (e) {
        _showErrorDialog('An error occurred: ${e.toString()}');
      } finally {
        setState(() => isLoading = false);
      }
    } else {
      _showErrorDialog('Please enter both email/CNIC and password.');
      setState(() => isLoading = false);
    }
  }

  void _showUnverifiedEmailDialog(String email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Email Not Verified'),
        content: Text(
            'Please verify your email to log in. Would you like to resend the verification email?'),
        actions: <Widget>[
          TextButton(
            child: Text('Resend'),
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close the dialog
              String message =
                  await _authService.resendConfirmationEmail(email);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(message)));
            },
          ),
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
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

  void _forgotPassword() async {
    final emailOrCnic = forgotPasswordController.text.trim();
    if (emailOrCnic.isEmpty) {
      _showMessage('Please enter your email or CNIC.');
      return;
    }

    try {
      setState(() => isLoading = true);
      final message = await _authService.forgotPassword(emailOrCnic);
      _showMessage(message);
    } catch (e) {
      _showMessage('An error occurred. Please try again.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Forgot Password'),
        content: TextField(
          controller: forgotPasswordController,
          decoration: InputDecoration(hintText: 'Enter your email or CNIC'),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Reset Password'),
            onPressed: () {
              _forgotPassword();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

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
                'Sign In',
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
                    SizedBox(
                        height:
                            0), // Adjust this value to position the form properly
                    buildTextField(
                      controller: signInController,
                      label: isEmail ? 'Email' : 'CNIC',
                      keyboardType: isEmail
                          ? TextInputType.emailAddress
                          : TextInputType.number,
                      inputFormatter: isEmail ? null : CNICInputFormatter(),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      onPressed: () {
                        setState(() {
                          isEmail = !isEmail;
                        });
                      },
                      child: Text(
                        isEmail ? 'Switch to CNIC' : 'Switch to Email',
                        style: GoogleFonts.lato(
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    buildTextField(
                      controller: passwordController,
                      label: 'Password',
                      initiallyObscure: true,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      onPressed: _handleLogin,
                      child: isLoading
                          ? CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              'Sign In',
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    TextButton(
                      onPressed: _showForgotPasswordDialog,
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ],
                )
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
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  ),
                  child: Text(
                    "Don't have an account? Sign Up",
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

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    TextInputFormatter? inputFormatter,
    bool initiallyObscure = false,
  }) {
    bool obscureText = initiallyObscure;
    // Use a StatefulBuilder to rebuild just the TextField when the icon is tapped
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
            inputFormatters: inputFormatter != null ? [inputFormatter] : [],
          ),
        );
      },
    );
  }
}
