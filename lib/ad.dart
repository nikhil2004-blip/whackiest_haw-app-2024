import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'set.dart'; // Import the settings page
import 'members.dart';

class AppDrawer extends StatelessWidget {
  final User? currentUser;

  AppDrawer({this.currentUser});

  Future<String?> _fetchNickname() async {
    if (currentUser != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      return snapshot.data()?['nickname'] ?? "Guest";
    }
    return "Guest";
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<String?>(  // Fetch user nickname
        future: _fetchNickname(),
        builder: (context, snapshot) {
          String nickname = snapshot.data ?? "Loading...";

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF676F9D)), // Soft Blue Background
                accountName: Text(
                  nickname,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  currentUser?.email ?? "No email available",
                  style: TextStyle(color: Colors.white70),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    nickname.isNotEmpty ? nickname[0].toUpperCase() : "G",
                    style: TextStyle(
                      fontSize: 40.0,
                      color: Color(0xFF2D3250), // Dark Blue for initials
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person, color: Color(0xFF2D3250)), // Dark Blue for Icons
                title: Text(
                  'Profile',
                  style: TextStyle(color: Color(0xFF424769)), // Dark Gray for Text
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              ListTile(
                leading: Icon(Icons.group, color: Color(0xFF2D3250)), // Dark Blue for Icons
                title: Text(
                  'Members',
                  style: TextStyle(color: Color(0xFF424769)), // Dark Gray for Text
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/members');
                },
              ),
              // ListTile(
              //   leading: Icon(Icons.settings, color: Color(0xFF2D3250)), // Dark Blue for Icons
              //   title: Text(
              //     'Settings',
              //     style: TextStyle(color: Color(0xFF424769)), // Dark Gray for Text
              //   ),
              //   onTap: () {
              //     Navigator.pushNamed(context, '/settings');
              //   },
              // ),
              ListTile(
                leading: Icon(Icons.logout, color: Color(0xFF2D3250)), // Dark Blue for Icons
                title: Text(
                  'Log Out',
                  style: TextStyle(color: Color(0xFF424769)), // Dark Gray for Text
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
