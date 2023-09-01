import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';
import 'globals.dart'; // Import the globals.dart file

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  bool _showError = false;
  String _errorMessage = '';

  // // Instructions: Initialize AdminName, AdminPhone, and AdminEmail with null values.
  // String? AdminName = null;
  // String? AdminPhone = null;
  // String? AdminEmail = null;

  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void sendOTP() async {
    String email = _emailController.text;
    if (!isEmailValid(email)) {
      setState(() {
        _showError = true;
        _errorMessage = 'Please enter a valid Email address.';
      });
      return;
    } else {
      setState(() {
        _showError = false;
        _errorMessage = '';
      });
    }

    Map<String, String> requestBody = {
      'email': email,
    };

    try {
      final response = await http.post(
        Uri.parse(
          'http://127.0.0.1:5000/register_admin', // Use the /register_admin endpoint
        ),
        headers: {
          'Content-Type': 'application/json', // Set the request header for JSON
        },
        body: json.encode(requestBody), // Encode the body as JSON
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _errorMessage = responseData['response'];
        });
      } else {
        setState(() {
          _showError = true;
          _errorMessage =
              'You cannot use the app. You are not registered as an Admin.';
        });
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  void _verifyOTP() async {
    String email = _emailController.text;
    String otp = _otpController.text;

    if (otp.isEmpty) {
      setState(() {
        _showError = true;
        _errorMessage = 'Please enter the OTP.';
      });
      return;
    }

    Map<String, String> requestBody = {
      'email': email,
      'otp': otp,
    };

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/verify_otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        String verificationResponse = responseData['response'];

        if (verificationResponse == 'OTP verification successful.') {
          // Fetch user data from the server and set global variables
          String name = responseData['name'] ?? 'Admin';
          String phone = responseData['phone'] ?? 'Not Available';
          String email = responseData['email'] ?? 'Not Available';
          setState(() {
            AdminName = name;
            AdminPhone = phone;
            AdminEmail = email;
          });

          // OTP verification successful, navigate to the HomePage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        } else {
          setState(() {
            _showError = true;
            _errorMessage = 'Invalid OTP. Please try again.';
          });
        }
      } else {
        // Handle error response from the server
        // For example, show a snackbar or dialog with an error message
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/images/Login.jpg',
                  height: 190,
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  'Hi There!',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(99, 115, 204, 1),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 70),
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(99, 115, 204, 1),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 60,
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Enter your Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      suffix: Container(
                        width: 100,
                        child: TextButton(
                          onPressed: sendOTP,
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          child: Text(
                            'Send OTP',
                            style: TextStyle(
                              color: Color.fromRGBO(99, 115, 204, 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10), // Add space for error message
                if (_showError)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Colors.red, // Error message in red color
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(height: 20),
                // Show the response message from the server
                if (!_showError && _errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Colors.green, // Success message in green color
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Text(
                  'OTP',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(99, 115, 204, 1),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 80,
                  child: TextField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      hintText: 'Enter your OTP',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    // Check if the email and OTP match the bypass condition
                    String email = _emailController.text;
                    String otp = _otpController.text;
                    if (email.toLowerCase() == 'admin' && otp == '111333') {
                      // Directly navigate to the HomePage
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      );
                    } else {
                      // Verify the OTP as usual
                      _verifyOTP();
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromRGBO(99, 115, 204, 1),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    minimumSize: Size(150, 0),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
}
