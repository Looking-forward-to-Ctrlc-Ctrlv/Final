import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'card.dart';
import 'navbar.dart';
import 'profile.dart';
import 'doctor_form.dart';
import 'edit_doctor_form.dart';
import 'admin_page.dart';
import 'globals.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<Map<String, String>> doctors = [];

  @override
  void initState() {
    super.initState();
    // Fetch data when the page is first loaded
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://127.0.0.1:5000/doctors'), // Replace 'your_server_ip' with your server IP
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          // Convert the fetched data into a list of doctors
          doctors = data
              .map((item) => {
                    'id': item['id'].toString(),
                    'name': item['name'] as String,
                    'phonenumber': item['phonenumber'] as String,
                    'email': item['email'] as String,
                    'hospitalName': item['hospitalName'] as String,
                    'city': item['city'] as String,
                    'admittedBy': item['admittedBy'] as String,
                    'date_joined': item['date_joined'] as String,
                    'date_last_updated': item['date_last_updated'] as String,
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            AdminName != null
                ? 'Welcome ${AdminName!.split(' ')[0]}!'
                : 'Welcome Admin!',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.normal,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          elevation: 0,
          actions: [
            ProfileWidget(),
            SizedBox(width: 16),
          ],
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
                    width: MediaQuery.of(context).size.width *
                        0.55, // Decreased the width from 0.5 to 0.4
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showDoctorFormOverlay(context);
                      },
                      label: Text(
                        'Add a New Doctor',
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
                'Doctors in the Database',
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
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  return DoctorCard(
                    name: doctors[index]['name']!,
                    email: doctors[index]['email']!,
                    onMoreInfo: () {
                      // Handle "More Information" option
                      _showMoreInfoDialog(context, doctors[index]);
                    },
                    onEdit: () {
                      // Handle "Edit Information" option
                      _editDoctor(context, doctors[index]);
                    },
                    onRemove: () {
                      // Handle "Remove the Doctor" option
                      _removeDoctor(context, index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: NavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index; // Update currentIndex when a tab is tapped
            });

            // Handle navigation when tabs are clicked
            if (index == 1) {
              // Navigate to the AdminPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminPage(),
                ),
              ).then((value) {
                // This block runs when returning from the AdminPage
                // Update currentIndex to 0 (Home tab) when returning from AdminPage
                setState(() {
                  _currentIndex = 0;
                });
              });
            }
          },
        ),
      ),
    );
  }

  void _showDoctorFormOverlay(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DoctorFormOverlay(onSubmit: _sendDoctorData);
      },
    );
  }

  void _sendDoctorData(String name, String phonenumber, String email,
      String hospitalName, String city) async {
    // Determine the value for admittedBy
    String admittedBy = AdminName ?? 'Admin';

    // Create a JSON object with the doctor's information
    final doctorData = {
      'name': name,
      'phonenumber': phonenumber,
      'email': email,
      'hospitalName': hospitalName,
      'city': city,
      'admittedBy': admittedBy,
    };

    // Convert the doctorData map to a JSON string
    String jsonData = jsonEncode({'data': doctorData});

    // Send a POST request to the server using http.post
    final response = await http.post(
      Uri.parse(
          'http://127.0.0.1:5000/process_data'), // Replace 'your_server_ip' with your server IP
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonData,
    );

    if (response.statusCode == 200) {
      // Successful response received from the server
      final responseData = jsonDecode(response.body);
      String doctorName = responseData['name'];

      // Show a success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Doctor "$doctorName" added successfully!'),
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

      // Fetch data again to update the list of doctors
      await fetchData();
    } else {
      // Handle error case
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to submit doctor data.'),
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
  }

  void _showMoreInfoDialog(BuildContext context, Map<String, String?> doctor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Doctor Information',
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
                doctor['id'] ?? '', // Added 'id' here
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 8),
              Text(
                'Name of the Doctor:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                doctor['name'] ?? '',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 8),
              Text(
                'phonenumber no:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                doctor['phonenumber'] ?? '',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 8),
              Text(
                'Email:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                doctor['email'] ?? '',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 8),
              Text(
                'Hospital Name:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                doctor['hospitalName'] ?? '',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 8),
              Text(
                'City:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                doctor['city'] ?? '',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 8),
              Text(
                'Admitted By:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                doctor['admittedBy'] ?? '',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 8),
              Text(
                'Date Joined:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                doctor['date_joined'] ?? '',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 8),
              Text(
                'Date Last Updated:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                doctor['date_last_updated'] ?? '',
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

  void _editDoctor(BuildContext context, Map<String, String> doctor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditDoctorForm(
          initialName: doctor['name']!,
          initialPhonenumber: doctor['phonenumber']!,
          initialEmail: doctor['email']!,
          initialHospitalName: doctor['hospitalName']!,
          initialCity: doctor['city']!,
          onSubmit: (name, phonenumber, email, hospitalName, city) {
            // Handle the edited doctor information here
            Map<String, String> editedDoctor = {
              'id': doctor['id']!,
              'name': name,
              'phonenumber': phonenumber,
              'email': email,
              'hospitalName': hospitalName,
              'city': city,
            };
            _handleEditedDoctor(context, editedDoctor);
          },
        );
      },
    );
  }

  Future<void> _handleEditedDoctor(
    BuildContext context,
    Map<String, String> editedDoctor,
  ) async {
    try {
      // Send a PUT request to the server with the edited doctor data
      final response = await http.put(
        Uri.parse(
            'http://127.0.0.1:5000/edit_doctor'), // Replace with your server URL
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(editedDoctor),
      );

      if (response.statusCode == 200) {
        // Successful response received from the server
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Doctor information updated successfully!'),
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

        // Fetch data again to update the list of doctors
        await fetchData();
      } else {
        // Handle error case
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to update doctor information.'),
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
      print('Error updating doctor information: $error');
    }
  }

  void _removeDoctor(BuildContext context, int index) async {
    // Extract email, phonenumber, and id using the index
    String email = doctors[index]['email']!;
    String phonenumber = doctors[index]['phonenumber']!;
    int id = int.parse(doctors[index]['id']!);

    // Implement the Remove the Doctor option here
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Doctor'),
          content: Text(
              'Are you sure? The Doctor would be permanently removed from the database.'),
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
      // User confirmed to delete the doctor
      try {
        final response = await http.delete(
          Uri.parse('http://127.0.0.1:5000/remove_doctor'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'id': id,
            'email': email,
            'phonenumber': phonenumber,
          }),
        );

        if (response.statusCode == 200) {
          // Successful response received from the server
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Success'),
                content: Text('Doctor removed successfully!'),
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

          // Fetch data again to update the list of doctors
          await fetchData();
        } else {
          // Handle error case
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Failed to remove the doctor.'),
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
        print('Error removing doctor: $error');
      }
    }
  }
}

class DoctorCard extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onMoreInfo;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  DoctorCard({
    required this.name,
    required this.email,
    required this.onMoreInfo,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(
              'assets/images/Doctor1.jpg'), // Replace with your image asset path
        ),
        title: Text(name),
        subtitle: Text(email),
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'more_info') {
              onMoreInfo();
            } else if (value == 'edit') {
              onEdit();
            } else if (value == 'remove') {
              onRemove();
            }
          },
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: 'more_info',
                child: Text('More Information'),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Text('Edit Information'),
              ),
              PopupMenuItem(
                value: 'remove',
                child: Text('Remove the Doctor'),
              ),
            ];
          },
        ),
      ),
    );
  }
}
