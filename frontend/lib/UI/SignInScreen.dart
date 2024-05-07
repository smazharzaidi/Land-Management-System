import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Functionality/SignInAuth.dart';
import '../Functionality/CNICInputFormatter.dart';
import 'package:frontend/UI/BottomNavBarScreenDashboard.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController forgotPasswordController =
      TextEditingController();
  bool isEmail = true;
  bool isLoading = false;
  TextEditingController signInController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final AuthServiceLogin _authService = AuthServiceLogin();

  void _handleLogin() async {
    if (signInController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _showErrorDialog('Please enter both email/CNIC and password.');
      return;
    }
    setState(() => isLoading = true);
    try {
      String result = await _authService.login(
          signInController.text.trim(), passwordController.text.trim());
      if (result == "success") {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                BottomNavBarScreenDashboard(authService: _authService)));
      } else if (result == "Email not verified. Please verify your email.") {
        _showUnverifiedEmailDialog(signInController.text.trim());
      } else {
        _showErrorDialog(result);
      }
    } catch (e) {
      _showErrorDialog('An error occurred: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
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
                '',
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
                    SizedBox(height: 0),
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
                        backgroundColor: Colors.grey[200],
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
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 90.0),
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15.0),
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
                                  //color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showForgotPasswordDialog(),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ],
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
                      icon: Icon(obscureText
                          ? Icons.visibility_off
                          : Icons.visibility),
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

  void _forgotPassword() async {
    final emailOrCnic = forgotPasswordController.text.trim();
    if (emailOrCnic.isEmpty) {
      _showErrorDialog('Please enter your email or CNIC.');
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
}
