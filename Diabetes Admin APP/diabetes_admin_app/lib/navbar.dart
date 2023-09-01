import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  NavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.white,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        elevation: 0,
        selectedItemColor: Color(0xFF6373CC),
        unselectedItemColor: Colors.grey,
        currentIndex: currentIndex,
        onTap: onTap,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30,
              color: currentIndex == 0
                  ? Color(0xFF6373CC)
                  : Colors.grey, // Set color based on selected index
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.admin_panel_settings,
              size: 30,
              color: currentIndex == 1
                  ? Color(0xFF6373CC)
                  : Colors.grey, // Set color based on selected index
            ),
            label: 'Admin',
          ),
        ],
      ),
    );
  }
}
