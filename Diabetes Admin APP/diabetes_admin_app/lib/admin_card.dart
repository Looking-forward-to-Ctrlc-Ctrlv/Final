// Import the Flutter material library, which provides pre-designed UI components.
import 'package:flutter/material.dart';

// Define a class called 'Admin' to represent an administrator with a name and email.
class Admin {
  final String name;
  final String email;

  // Constructor for the 'Admin' class to initialize name and email.
  Admin(this.name, this.email);
}

// Define a widget class called 'AdminCard' to display information about an admin in a card format.
class AdminCard extends StatelessWidget {
  // Properties of the 'AdminCard' widget.
  final String name;
  final String email;
  final VoidCallback onMoreInfo;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  // Constructor for the 'AdminCard' widget.
  AdminCard({
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
        // Display a circular avatar with an image representing the admin.
        leading: CircleAvatar(
          backgroundImage: AssetImage('assets/images/admin1.png'), // Replace with your image asset path
        ),
        // Display the admin's name as the title of the card.
        title: Text(name),
        // Display the admin's email as a subtitle of the card.
        subtitle: Text(email),
        // Add a popup menu button with options for more actions.
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert), // Display vertical ellipsis icon.
          onSelected: (value) {
            // When a menu item is selected, execute the appropriate callback function.
            if (value == 'more_info') {
              onMoreInfo(); // Call the 'onMoreInfo' callback.
            } else if (value == 'edit') {
              onEdit(); // Call the 'onEdit' callback.
            } else if (value == 'remove') {
              onRemove(); // Call the 'onRemove' callback.
            }
          },
          itemBuilder: (context) {
            // Build the menu items for the popup menu.
            return [
              PopupMenuItem(
                value: 'more_info',
                child: Text('More Information'), // Display 'More Information' option.
              ),
              PopupMenuItem(
                value: 'edit',
                child: Text('Edit Information'), // Display 'Edit Information' option.
              ),
              PopupMenuItem(
                value: 'remove',
                child: Text('Remove the Admin'), // Display 'Remove the Admin' option.
              ),
            ];
          },
        ),
      ),
    );
  }
}
