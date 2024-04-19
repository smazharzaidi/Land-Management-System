// lib/UI/ProfileScreen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Functionality/ProfileLogic.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final ProfileLogic _profileLogic = ProfileLogic();
  bool _isEmailReadOnly = true;
  bool _isMobileReadOnly = true;
  bool _isLoading = true;
  String _initialEmail = '';
  String _initialMobile = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      var profileData = await _profileLogic.getUserProfile();
      _emailController.text = profileData.email ?? '';
      _mobileController.text = profileData.mobileNumber ?? '';
      _initialEmail = _emailController.text;
      _initialMobile = _mobileController.text;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Text('Profile Settings',
              style: GoogleFonts.lato(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          backgroundColor: Colors.grey[200],
          elevation: 0,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    _buildProfileField(
                      controller: _emailController,
                      label: 'Email',
                      isReadOnly: _isEmailReadOnly,
                      onEdit: () {
                        setState(() {
                          _isEmailReadOnly = false;
                        });
                      },
                    ),
                    _buildProfileField(
                      controller: _mobileController,
                      label: 'Mobile Number',
                      isReadOnly: _isMobileReadOnly,
                      onEdit: () {
                        setState(() {
                          _isMobileReadOnly = false;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor:
                            Colors.green, // foreground (text) color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        textStyle: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _saveProfile,
                      child: _isLoading
                          ? CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text('Save Changes'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileField({
    required TextEditingController controller,
    required String label,
    required bool isReadOnly,
    required VoidCallback onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.lato(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: isReadOnly
              ? IconButton(
                  icon: Icon(Icons.edit, color: Colors.black),
                  onPressed: onEdit,
                )
              : null,
        ),
      ),
    );
  }

  void _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      // Save profile logic
      await _profileLogic.saveUserProfile(
        email: _emailController.text,
        mobileNumber: _mobileController.text,
      );
      _initialEmail = _emailController.text;
      _initialMobile = _mobileController.text;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.of(context).pop(); // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_isEmailReadOnly ||
        !_isMobileReadOnly ||
        _emailController.text != _initialEmail ||
        _mobileController.text != _initialMobile) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Unsaved Changes'),
          content:
              Text('You have unsaved changes. Are you sure you want to leave?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
            ),
          ],
        ),
      );

      return discard ?? false;
    }
    return true;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }
}
