import 'package:flutter/material.dart';

class Doctor {
  final String name;
  final String email;

  Doctor(this.name, this.email);
}

class DoctorCard extends StatelessWidget {
  final String name;
  final String email;
  final String image;
  final VoidCallback onMoreInfo;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  DoctorCard({
    required this.name,
    required this.email,
    required this.image,
    required this.onMoreInfo,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(image),
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
