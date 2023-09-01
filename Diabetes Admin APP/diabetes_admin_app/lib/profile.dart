import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'globals.dart'; // Import the globals.dart file

class ProfileWidget extends StatefulWidget {
  final String? adminName;
  final String? adminPhone;
  final String? adminEmail;

  ProfileWidget({this.adminName, this.adminPhone, this.adminEmail});

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  File? _profileImage;
  final picker = ImagePicker();

  Future<void> _pickProfileImage() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String name = AdminName ?? 'Admin';
    String phone = AdminPhone ?? 'Not Available';
    String email = AdminEmail ?? 'Not Available';

    return GestureDetector(
      onTap: () {
        _showProfileOverlay(context, name, phone, email);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 0.0), // Add padding from top
            child: ClipOval(
              child: CircleAvatar(
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : AssetImage('assets/images/defa.jpg')
                        as ImageProvider<Object>?,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showProfileOverlay(
      BuildContext context, String name, String phone, String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Phone: $phone'),
              Text('Email: $email'),
            ],
          ),
        );
      },
    );
  }
}
