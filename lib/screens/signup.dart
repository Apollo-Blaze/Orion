import 'dart:io';

import 'package:orion/screens/email.dart';
import 'package:orion/screens/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  int _currentPage = 0;
  File? _profileImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
      _showError('Failed to pick image. Please try again.');
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_profileImage == null) {
      _showError('Please select a profile picture.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoadingScreen()),
    );

    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final phoneNumber = _phoneNumberController.text;

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Upload profile picture to Firebase Storage
        final profileImageUrl = await _uploadProfileImage(user.uid);

        // Send email verification
        await user.sendEmailVerification();

        // Save user details to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          'profileImageUrl': profileImageUrl,
        });

        // Save user data to SharedPreferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('name', name);
        await prefs.setString('email', email);
        await prefs.setString('profileImageUrl', profileImageUrl);
        await prefs.setString('phoneNumber', phoneNumber);

        // Navigate to a screen informing the user to verify their email
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => EmailVerificationScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close the loading screen
      _handleError(e);
    } catch (e) {
      Navigator.pop(context); // Close the loading screen
      _showError('An unexpected error occurred. Please try again.');
    }
  }

  Future<String> _uploadProfileImage(String userId) async {
    setState(() {
      _isUploading = true;
    });
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profilePictures')
          .child('$userId.jpg');

      await ref.putFile(_profileImage!);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile picture.');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _handleError(FirebaseAuthException e) {
    if (e.code == 'email-already-in-use') {
      _showError('The account already exists for that email.');
    } else if (e.code == 'weak-password') {
      _showError('The password is too weak.');
    } else {
      _showError(e.message ?? 'An error occurred.');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Okay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 80),
            _isUploading
                ? CircularProgressIndicator()
                : GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 75,
                      backgroundImage:
                          _profileImage != null ? FileImage(_profileImage!) : null,
                      child: _profileImage == null
                          ? Icon(
                              Icons.add_a_photo,
                              color: Colors.white,
                              size: 40,
                            )
                          : null,
                    ),
                  ),
            SizedBox(height: 20),
            Text(
              "Create Account",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "Start managing your projects with ease.",
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 202, 202, 202),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 35),
            Expanded(
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildInputField(
                      label: "Name",
                      controller: _nameController,
                      validator: (value) =>
                          value!.isEmpty ? "Name cannot be empty" : null,
                    ),
                    _buildInputField(
                      label: "Email",
                      controller: _emailController,
                      validator: (value) {
                        if (!RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                            .hasMatch(value!)) {
                          return "Invalid email address";
                        }
                        return null;
                      },
                    ),
                    _buildInputField(
                      label: "Phone Number",
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 10) {
                          return "Please enter a valid phone number";
                        }
                        return null;
                      },
                    ),
                    _buildInputField(
                      label: "Password",
                      controller: _passwordController,
                      obscureText: true,
                      validator: (value) {
                        if (value!.length < 8) {
                          return "Password must be at least 8 characters";
                        }
                        return null;
                      },
                    ),
                    _buildInputField(
                      label: "Confirm Password",
                      controller: _confirmPasswordController,
                      obscureText: true,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _currentPage > 0
                      ? ElevatedButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                          ),
                          child: Text(
                            "Previous",
                            style: TextStyle(
                                color: Color.fromARGB(255, 61, 118, 175)),
                          ),
                        )
                      : SizedBox.shrink(),
                  _currentPage < 4
                      ? ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _pageController.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                          ),
                          child: Text(
                            "Next",
                            style: TextStyle(
                                color: Color.fromARGB(255, 61, 118, 175)),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _signUp();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 40, 102, 165),
                          ),
                          child: Text(
                            "Submit",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: 
        TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderSide: BorderSide(
            color: Colors.white, // Set the border color to white
            width: 1.0, // Adjust the border width
          ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}