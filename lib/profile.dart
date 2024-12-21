import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'editpass.dart';
import 'editprof.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late User? _currentUser;
  late DocumentSnapshot? _userData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _getUserData();
    }
  }

  // Fetch user data from Firestore
  Future<void> _getUserData() async {
    try {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(_currentUser!.uid).get();
      setState(() {
        _userData = userDoc.exists ? userDoc : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching user data. Please try again later.';
      });
    }
  }

  // Navigate to EditProfilePage and refresh data upon return
  Future<void> _navigateToEditProfile() async {
    if (_userData != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfilePage(
            userData: _userData!,
            userId: _currentUser!.uid,
          ),
        ),
      );

      // If result is true, refresh the profile data
      if (result == true) {
        setState(() {
          _isLoading = true;
        });
        await _getUserData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Profile')),
        body: Center(child: Text('User not logged in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _navigateToEditProfile,
          ),
          IconButton(
            icon: Icon(Icons.lock),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangePasswordPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : _userData == null
          ? Center(
        child: Text(
            'No profile data found. Please complete your profile.'),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileField('Nickname', _userData!['nickname']),
                    _buildProfileField('Room Number', _userData!['room_number']),
                    _buildProfileField('Age', _userData!['age']),
                    _buildProfileField('Sex', _userData!['sex']),
                    _buildProfileField('Year', _userData!['year']),
                    _buildProfileField('Branch', _userData!['branch']),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Container with border for Username and User ID
            _buildProfileBox('Username', _userData!['username']),
            SizedBox(height: 20),
            _buildProfileBox('User ID', _currentUser!.uid),
          ],
        ),
      ),
    );
  }

  // Helper method to create profile fields with uniform styling
  Widget _buildProfileField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        '$label: ${value ?? 'N/A'}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Helper method to create profile fields with a border around them
  Widget _buildProfileBox(String label, String? value) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ${value ?? 'N/A'}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
