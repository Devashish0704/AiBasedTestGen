import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Import MediaType from http_parser
import 'package:path/path.dart';
import 'package:mime/mime.dart';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_generator/services/user_service.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserService _userService = UserService();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Controllers for text fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fieldController = TextEditingController();
  final TextEditingController _examController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _profilePic;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// 🔹 Fetch user details from Firestore
  Future<void> _fetchUserData() async {
    Map<String, dynamic>? userData = await _userService.getUserDetails();

    if (userData != null) {
      setState(() {
        _usernameController.text = userData['name'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _fieldController.text = userData['field_of_study'] ?? '';
        _examController.text = userData['exam'] ?? '';
        _dateController.text = userData['exam_date'] != null
            ? userData['exam_date'].toDate().toString().split(' ')[0]
            : '';
        _profilePic = userData['profile_pic'] ?? null;
      });
    }
  }

  /// 🔹 Upload image to Cloudinary
Future<String?> uploadImageToCloudinary(XFile imageFile) async {
  String cloudinaryUrl = "https://api.cloudinary.com/v1_1/dig5imezv/image/upload"; // Your Cloud Name
  String uploadPreset = "flutter_upload"; // Your Upload Preset

  try {
    print("Preparing to upload image to Cloudinary...");
    var request = http.MultipartRequest("POST", Uri.parse(cloudinaryUrl));
    request.fields["upload_preset"] = uploadPreset;

    if (kIsWeb) {
      // 🌐 Handling for Flutter Web
      print("Reading image bytes for web...");
      Uint8List bytes = await imageFile.readAsBytes(); // Convert file to bytes
      request.files.add(http.MultipartFile.fromBytes(
        "file",
        bytes,
        filename: "upload.jpg",
        contentType: MediaType('image', 'jpeg'),
      ));
      print("Image bytes added to request for web.");
    } else {
      // 📱 Handling for Mobile (Android/iOS)
      print("Adding image file to request for mobile...");
      request.files.add(await http.MultipartFile.fromPath(
        "file",
        imageFile.path,
        contentType: MediaType.parse(lookupMimeType(imageFile.path) ?? 'image/jpeg'),
      ));
      print("Image file added to request for mobile.");
    }

    print("Sending request to Cloudinary...");
    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    print("Cloudinary response: $responseData");

    if (response.statusCode == 200) {
      print("Image uploaded successfully to Cloudinary.");
      var jsonData = json.decode(responseData);
      return jsonData["secure_url"]; // Public URL of uploaded image
    } else {
      print("Cloudinary upload failed with status code: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Error uploading image to Cloudinary: $e");
    return null;
  }
}

Future<void> _pickImage() async {
  try {
    print("Picking image from gallery...");
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      print("Image picked: ${image.path}");

      if (kIsWeb) {
        // 🌐 Web: No need to convert to File
        print("Uploading image from web...");
        String? imageUrl = await uploadImageToCloudinary(image);
        
        if (imageUrl != null) {
          print("Image uploaded successfully: $imageUrl");
          setState(() {
            _profilePic = imageUrl;
          });

          // Update profile_pic in Firebase
          print("Updating profile picture in Firebase...");
          await _userService.updateUserDetails({'profile_pic': imageUrl});
          ScaffoldMessenger.of(this.context).showSnackBar(
            SnackBar(content: Text('Profile picture updated successfully!')),
          );
        } else {
          print("Failed to upload image to Cloudinary.");
        }
      } else {
        // 📱 Mobile: Convert XFile to File
        setState(() {
          _imageFile = File(image.path);
        });

        if (!_imageFile!.existsSync()) {
          print("Error: File does not exist!");
          return;
        }

        print("Uploading image from mobile...");
        String? imageUrl = await uploadImageToCloudinary(XFile(_imageFile!.path));

        if (imageUrl != null) {
          print("Image uploaded successfully: $imageUrl");
          setState(() {
            _profilePic = imageUrl;
          });

          // Update profile_pic in Firebase
          print("Updating profile picture in Firebase...");
          await _userService.updateUserDetails({'profile_pic': imageUrl});
          ScaffoldMessenger.of(this.context).showSnackBar(
            SnackBar(content: Text('Profile picture updated successfully!')),
          );
        } else {
          print("Failed to upload image to Cloudinary.");
        }
      }
    } else {
      print("No image selected.");
    }
  } catch (e) {
    print("Error picking image: $e");
    ScaffoldMessenger.of(this.context).showSnackBar(
      SnackBar(content: Text('Error picking image: $e')),
    );
  }
}


  /// 🔹 Update user details in Firestore
  Future<void> _updateUserProfile() async {
    try {
      print("Updating user profile...");
      Map<String, dynamic> updatedData = {
        'name': _usernameController.text,
        'email': _emailController.text,
        'field_of_study': _fieldController.text,
        'exam': _examController.text,
        'exam_date': _dateController.text.isNotEmpty
            ? Timestamp.fromDate(DateTime.parse(_dateController.text))
            : null,
        'profile_pic': _profilePic, // Ensure profile_pic is updated
      };

      await _userService.updateUserDetails(updatedData);
      print("User profile updated successfully.");
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      print("Error updating user profile: $e");
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Customize your Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _updateUserProfile,
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 70,
                backgroundImage: _imageFile != null
                    ? (kIsWeb
                        ? NetworkImage(_imageFile!.path) // Works for web
                        : FileImage(File(_imageFile!.path))
                            as ImageProvider) // Works for mobile
                    : (_profilePic != null && _profilePic!.isNotEmpty
                        ? NetworkImage(_profilePic!) as ImageProvider
                        : AssetImage('assets/profile.jpg') as ImageProvider),
              ),
              TextButton(
                onPressed: _pickImage,
                child: Text(
                  'Change Picture',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildTextField('Username', _usernameController),
              _buildTextField('Email Id', _emailController),
              _buildTextField('Field of Study', _fieldController),
              _buildTextField('Exams Preparing For', _examController),
              _buildTextField(
                'Expected Exam Date',
                _dateController,
                isDate: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() {
                      _dateController.text = picked.toString().split(' ')[0];
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isDate = false, VoidCallback? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            readOnly: isDate,
            onTap: onTap,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: isDate
                  ? Icon(Icons.calendar_today, color: Colors.grey)
                  : null,
            ),
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _fieldController.dispose();
    _examController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
