import 'package:flutter/material.dart';
import 'navbar.dart';
import 'admin_form.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'admin_card.dart';
import 'edit_admin_form.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Map<String, String>> admins = [];

  @override
  void initState() {
    super.initState();
    // Fetch admin data when the page is first loaded
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://127.0.0.1:5000/admins'), // Replace with your server URL
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          // Convert the fetched data into a list of admins
          admins = data
              .map((item) => {
                    'id': item['id'].toString(),
                    'name': item['name'] as String,
                    'email': item['email'] as String,
                    'phoneNumber': item['phoneNumber'] as String,
                  })
              .toList();
        });
      } else {
        // Handle error case
        print('Failed to fetch data: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      // Handle error case
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 40,
                  width: MediaQuery.of(context).size.width * 0.55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showAdminFormOverlay(context);
                    },
                    label: Text(
                      'Add an Admin',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    icon: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 18,
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFF86851),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: Text(
              'Admins in the Database',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: admins.length,
              itemBuilder: (context, index) {
                return AdminCard(
                  name: admins[index]['name']!,
                  email: admins[index]['email']!,
                  onMoreInfo: () {
                    _showMoreInfoDialog(context, admins[index]);
                  },
                  onEdit: () {
                    // Handle "Edit Information" option
                    _editAdmin(context, admins[index]);
                  },
                  onRemove: () {
                    _removeAdmin(context, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavBar(
        currentIndex: 1, // Set the index of the Admin tab to 1
        onTap: (index) {
          // Handle navigation when tabs are clicked
          if (index == 0) {
            // Navigate back to the HomePage
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  // Function to show the More Information dialog
  void _showMoreInfoDialog(BuildContext context, Map<String, String> admin) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Admin Information',
            style: TextStyle(color: Color(0xFF6373CC)),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ID:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                admin['id'] ?? '', // Added 'id' here
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 8),
              Text(
                'Name of the Admin:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                admin['name'] ?? '',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 8),
              Text(
                'Email:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                admin['email'] ?? '',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 8),
              Text(
                'Phone Number:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                admin['phoneNumber'] ?? '',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFF86851),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to remove the selected admin
  void _removeAdmin(BuildContext context, int index) async {
    int adminId = int.parse(admins[index]['id']!);
    String email = admins[index]['email']!;
    String phoneNumber = admins[index]['phoneNumber']!;

    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Admin'),
          content: Text(
              'Are you sure? The Admin would be permanently removed from the database.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true if user confirms
              },
              child: Text('Yes'),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFF86851),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false if user cancels
              },
              child: Text('No'),
              style: ElevatedButton.styleFrom(
                primary:
                    Colors.grey, // You can adjust the color for "No" button
              ),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        final response = await http.delete(
          Uri.parse('http://127.0.0.1:5000/remove_admin'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'id': adminId,
            'email': email,
            'phoneNumber': phoneNumber,
          }),
        );

        if (response.statusCode == 200) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Success'),
                content: Text('Admin removed successfully!'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'),
                  ),
                ],
              );
            },
          );

          // Fetch data again to update the list of admins
          await fetchData();
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Failed to remove the admin.'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'),
                  ),
                ],
              );
            },
          );
        }
      } catch (error) {
        print('Error removing admin: $error');
      }
    }
  }

  void _showAdminFormOverlay(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AdminFormOverlay(
          onSubmit: _sendAdminData,
        );
      },
    );
  }

  void _sendAdminData(String name, String email, String phoneNumber) async {
    // Create a JSON object with the admin's information
    final adminData = {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber, // Include the phone number in the request
    };

    // Convert the adminData map to a JSON string
    String jsonData = jsonEncode(adminData);

    try {
      // Send a POST request to the server using http.post
      final response = await http.post(
        Uri.parse(
            'http://127.0.0.1:5000/add_admin'), // Replace with your server URL
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonData,
      );

      if (response.statusCode == 200) {
        // Successful response received from the server
        final responseData = jsonDecode(response.body);
        String adminName = responseData['name'];

        // Show a success dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Admin "$adminName" added successfully!'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );

        // Fetch data again to update the list of admins
        await fetchData();
      } else {
        // Handle error case
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to submit admin data.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      // Handle error case
      print('Error sending admin data: $error');
    }
  }

  void _editAdmin(BuildContext context, Map<String, String> admin) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditAdminForm(
          initialName: admin['name']!,
          initialPhone: admin['phoneNumber']!,
          initialEmail: admin['email']!,
          onSubmit: (name, phone, email) {
            // Handle the edited admin information here
            Map<String, String> editedAdmin = {
              'id': admin['id']!,
              'name': name,
              'phoneNumber': phone,
              'email': email,
            };
            _handleEditedAdmin(context, editedAdmin);
          },
        );
      },
    );
  }

  // Function to handle updating the admin's information on the server
  Future<void> _handleEditedAdmin(
    BuildContext context,
    Map<String, String> editedAdmin,
  ) async {
    try {
      // Send a PUT request to the server with the edited admin data
      final response = await http.put(
        Uri.parse(
            'http://127.0.0.1:5000/edit_admin'), // Replace with your server URL
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(editedAdmin),
      );

      if (response.statusCode == 200) {
        // Successful response received from the server
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Admin information updated successfully!'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );

        // Fetch data again to update the list of admins
        await fetchData();
      } else {
        // Handle error case
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to update admin information.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      // Handle error case
      print('Error updating admin information: $error');
    }
  }
}
