import 'package:flutter/material.dart';

class AdminFormOverlay extends StatelessWidget {
  final void Function(String, String, String) onSubmit;  // Callback when form is submitted

  AdminFormOverlay({required this.onSubmit});

  final _formKey = GlobalKey<FormState>(); // Form key to manage the form's state
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Associate the form key with the form
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Admin Details',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6373CC),
                  ),
                ),
                SizedBox(height: 16),
                _buildNameFormField(context),
                _buildEmailFormField(context),
                _buildPhoneFormField(context),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() == true) {
                      // Call the onSubmit function and pass the admin's information
                      onSubmit(
                        nameController.text,
                        emailController.text,
                        phoneController.text,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    'Add Admin',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFF86851),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
// Widget to build the name input field
  Widget _buildNameFormField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter the Name of the Admin',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: nameController,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: Color(0xFF6A696E),
          ),
          validator: (value) {
            if (value?.isEmpty == true) {
              return 'Please enter the Name of the Admin';
            } else if (!_isValidName(value!)) {
              return 'The entered Name of the Admin is not valid';
            }
            return null;
          },
          decoration: InputDecoration(
            fillColor: Color(0xFF6A696E).withOpacity(0.1),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  // Helper function to check if the name contains only alphabets and spaces
  bool _isValidName(String value) {
    final nameRegExp = RegExp(r'^[a-zA-Z ]+$');
    return nameRegExp.hasMatch(value);
  }
// Widget to build the email input field
  Widget _buildEmailFormField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter the Email',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: Color(0xFF6A696E),
          ),
          validator: (value) {
            if (value?.isEmpty == true) {
              return 'Please enter the Email';
            } else if (!_isValidEmail(value!)) {
              return 'The entered Email is not valid';
            }
            return null;
          },
          decoration: InputDecoration(
            fillColor: Color(0xFF6A696E).withOpacity(0.1),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  // Helper function to check if the email is valid
  bool _isValidEmail(String value) {
    final emailRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegExp.hasMatch(value);
  }
 // Helper function to check if the phone number is a 10-digit number
  Widget _buildPhoneFormField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter the Phone no',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: Color(0xFF6A696E),
          ),
          validator: (value) {
            if (value?.isEmpty == true) {
              return 'Please enter the Phone no';
            } else if (!_isValidPhone(value!)) {
              return 'The entered Phone no is not valid';
            }
            return null;
          },
          decoration: InputDecoration(
            fillColor: Color(0xFF6A696E).withOpacity(0.1),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  // Helper function to check if the phone number is a 10-digit number
  bool _isValidPhone(String value) {
    final phoneRegExp = RegExp(r'^[0-9]{10}$');
    return phoneRegExp.hasMatch(value);
  }
}
