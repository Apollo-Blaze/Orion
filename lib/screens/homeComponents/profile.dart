import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? name;
  String? email;
  String? phoneNumber;
  String? profileImageUrl;
  String? bio;
  TextEditingController _nameController = TextEditingController();

  final _picker = ImagePicker();
  bool isEditing = false; // Track whether we are in editing mode

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'No Name Provided';
      email = prefs.getString('email') ?? 'Email not available';
      phoneNumber = prefs.getString('phoneNumber') ?? 'Phone not available';
      profileImageUrl = prefs.getString('profileImageUrl');
      bio = prefs.getString('bio');
      _nameController.text = name ?? ''; // Initialize the name controller
    });
  }

  // Pick an image from the gallery and upload it to Firebase Storage
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String? oldImageUrl = profileImageUrl;

      // Upload the new image to Firebase Storage
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('profilePictures/$fileName');
      await ref.putFile(File(pickedFile.path));
      String downloadUrl = await ref.getDownloadURL();

      // Delete the old profile image if it exists
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        try {
          Reference oldRef = storage.refFromURL(oldImageUrl);
          await oldRef.delete();
          print('Old image deleted successfully');
        } catch (e) {
          print('Failed to delete old profile image: $e');
        }
      }

      // Update SharedPreferences with the new image URL
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImageUrl', downloadUrl);

      // Reload the profile screen after the new profile image is set
      _loadUserData(); // This will reload the user data from SharedPreferences and reflect the new profile image

      // Optionally, update Firebase with the new profile image URL
      _updateFirebaseProfileImage(downloadUrl); // Update in Firebase
    }
  }

  // Update the profile image in Firebase
  Future<void> _updateFirebaseProfileImage(String url) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'profileImageUrl': url,
      });
    }
  }

  // Update the name in SharedPreferences and Firebase
  Future<void> _updateName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);

    // Update in Firebase
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': _nameController.text,
      });
    }

    setState(() {
      name = _nameController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 10, 19, 42), // Dark background
      body: name == null || email == null
          ? Center(child: CircularProgressIndicator(color: Colors.white)) // Show loader while loading
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Label and Picture
                    Column(
                      children: [
                        Text(
                          'Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 60),
                        GestureDetector(
                          onTap: _pickImage, // Allow the user to pick a new profile image
                          child: CircleAvatar(
                            radius: 100,
                            child: profileImageUrl == null
                                ? Text(
                                    name != null ? name![0] : 'U',
                                    style: TextStyle(fontSize: 40, color: Colors.white),
                                  )
                                : null,
                            backgroundImage: profileImageUrl != null
                                ? NetworkImage(profileImageUrl!)
                                : null,
                            backgroundColor: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Edit/Save Button
                    isEditing
                        ? Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.save, color: Colors.white),
                                onPressed: () {
                                  _updateName(); // Save the changes
                                  setState(() {
                                    isEditing = false; // Switch back to non-editable mode
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.cancel, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    isEditing = false; // Cancel editing
                                    _nameController.text = name ?? ''; // Revert to original name
                                  });
                                },
                              ),
                            ],
                          )
                        : SizedBox(height: 0),
                    SizedBox(height: 18),

                    // Name Editing with Edit Button aligned to the right
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            enabled: isEditing, // Allow editing when in editing mode
                            decoration: InputDecoration(
                              labelText: 'Name',
                              labelStyle: TextStyle(color: Colors.grey),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        // The Edit button is now aligned to the right side
                        if (!isEditing)
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                isEditing = true; // Enable editing mode
                              });
                            },
                          ),
                      ],
                    ),
                    SizedBox(height: 10),

                    // Email Label and Value
                    _buildInfoRow(Icons.email, 'Email', email ?? 'Email not available'),
                    SizedBox(height: 24),

                    // Phone Label and Value
                    _buildInfoRow(Icons.phone, 'Phone Number', phoneNumber ?? 'Phone not available'),
                    SizedBox(height: 30),

                    // Additional Info
                    if (bio != null && bio!.isNotEmpty) ...[
                      Text(
                        bio!,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 30),
                    ],

                    // Log Out Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          
                          // Remove only the user-related data
                          await prefs.remove('name');
                          await prefs.remove('email');
                          await prefs.remove('phoneNumber');
                          await prefs.remove('profileImageUrl');
                          await prefs.remove('bio');
                          
                          // Navigate to the welcome screen
                          Navigator.of(context).pushReplacementNamed('/welcome');
                        },
                        child: Text(
                          'Log Out',
                          style: TextStyle(fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

 Widget _buildInfoRow(IconData icon, String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Icon(
        icon,
        color: Colors.grey,
        size: 24,
      ),
      SizedBox(width: 12),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0), // Adjust this value to your needs
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

}