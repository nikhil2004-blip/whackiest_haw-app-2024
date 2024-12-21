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
      child: FutureBuilder<String?>(
        future: _fetchNickname(),
        builder: (context, snapshot) {
          String nickname = snapshot.data ?? "Loading...";

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.blueAccent),
                accountName: Text(
                  nickname,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                accountEmail: Text(
                  currentUser?.email ?? "No email available",
                  style: TextStyle(color: Colors.white70),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    nickname.isNotEmpty ? nickname[0].toUpperCase() : "G",
                    style: TextStyle(fontSize: 40.0, color: Colors.blueAccent),
                  ),
                ),
              ),

              ListTile(
                leading: Icon(Icons.person),
                title: Text('Profile'),
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },

              ),
              ListTile(
                leading: Icon(Icons.group),
                title: Text('Members'),
                onTap: () {
                  Navigator.pushNamed(context, '/members');
                },

              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  Navigator.pushNamed(context, '/settings'); // Use push instead of pushReplacementNamed
                },

              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Log Out'),
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
