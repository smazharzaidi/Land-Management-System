import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/Functionality/SignInAuth.dart';
import 'package:frontend/UI/SignInScreen.dart';

mixin InactivityMixin<T extends StatefulWidget> on State<T> {
  Timer? _inactivityTimer;
  final int _inactivityTimeoutInSeconds = 600; // 10 minutes for example

  @override
  void initState() {
    super.initState();
    resetInactivityTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer =
        Timer(Duration(seconds: _inactivityTimeoutInSeconds), logoutUser);
  }

  void logoutUser() async {
    if (!mounted) return; // Ensure the widget is still in the tree.
    final authService =
        AuthServiceLogin(); // Make sure this is correctly instantiated or passed.

    await authService.logout();

    if (mounted) {
      // Check again because logout is async.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SignInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Implement your screen's build method
    throw UnimplementedError();
  }
}
