import 'dart:io';
import 'package:aparte/pages/onboarding.dart';
import 'package:aparte/pages/settings.dart';
import 'package:aparte/services/shared_preferences.dart';
import 'package:aparte/services/widget_support.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Settings;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();

  String? userName;
  String? userEmail;
  String? id;
  String? profileImageUrl;

  bool isLoading = true;
  bool uploadingImage = false;

  // 🔥 Fetch user details from Firestore
  Future<void> getUserDetails() async {
    try {
      id = await SharedpreferenceHelper().getUserId();

      if (id == null) {
        print("No userId found in SharedPreferences");
        setState(() => isLoading = false);
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['Name'] ?? 'No name';
          userEmail = userDoc['Email'] ?? 'No email';
          profileImageUrl = userDoc['ProfileImage'];
          isLoading = false;
        });
      } else {
        print("User document not found in Firestore");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching user details: $e");
      setState(() => isLoading = false);
    }
  }

  // 📤 Pick image and upload to Firebase Storage
  Future<void> getImage() async {
    try {
      var image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        selectedImage = File(image.path);
        uploadingImage = true;
      });

      await uploadImageToFirebase();
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> logoutUser() async {
    try {
      // 🔹 Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // 🔹 Clear SharedPreferences
      await SharedpreferenceHelper().clearUserData();

      // 🔹 Navigate to Login screen
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Onboarding()),
        );
      }
    } catch (e) {
      print("Error logging out: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Logout failed: $e")));
    }
  }

  // 🔼 Upload image to Firebase Storage
  Future<void> uploadImageToFirebase() async {
    if (selectedImage == null || id == null) return;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child("profile_images")
          .child("$id.jpg");

      UploadTask uploadTask = ref.putFile(selectedImage!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(id).update({
        'ProfileImage': downloadUrl,
      });

      setState(() {
        profileImageUrl = downloadUrl;
        uploadingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile image updated successfully!")),
      );
    } catch (e) {
      print("Error uploading image: $e");
      setState(() => uploadingImage = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Profile', style: AppWidget.headlinetextstyle(26.0)),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20.0),

                  // 🖼 Profile Image
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: SizedBox(
                            height: 200,
                            width: 200,
                            child: selectedImage != null
                                ? Image.file(selectedImage!, fit: BoxFit.cover)
                                : (profileImageUrl != null
                                      ? Image.network(
                                          profileImageUrl!,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              100,
                                            ),
                                            border: Border.all(
                                              width: 2.0,
                                              color: Colors.black45,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.blue,
                                            size: 35.0,
                                          ),
                                        )),
                          ),
                        ),
                        if (uploadingImage)
                          Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton.icon(
                    onPressed: uploadingImage ? null : getImage,
                    icon: const Icon(Icons.upload),
                    label: const Text("Change Photo"),
                  ),

                  const SizedBox(height: 25),

                  infoTile(
                    icon: Icons.person,
                    title: 'Username',
                    value: userName ?? 'Loading...',
                  ),
                  const SizedBox(height: 20),
                  infoTile(
                    icon: Icons.mail,
                    title: 'Email',
                    value: userEmail ?? 'Loading...',
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Settings(isDarkMode: false, onThemeChanged: (bool value) {}),
                        ),
                      );
                    },
                    child: infoTile(
                      icon: Icons.settings,
                      title: 'Settings',
                      value: '',
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      await logoutUser();
                    },
                    child: infoTile(
                      icon: Icons.logout,
                      title: 'Logout',
                      value: '',
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 80,
          padding: const EdgeInsets.only(left: 10),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(icon, size: 40.0, color: Colors.lightBlueAccent),
              const SizedBox(width: 12.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(title, style: AppWidget.headlinetextstyle(18.0)),
                  if (value.isNotEmpty)
                    Text(value, style: AppWidget.normaltextstyle(17)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
