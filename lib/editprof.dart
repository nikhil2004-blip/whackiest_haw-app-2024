import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  final DocumentSnapshot userData;
  final String userId;

  EditProfilePage({required this.userData, required this.userId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late String nickname;
  late String roomNumber;
  late String age;
  late String year;
  late String branch;
  bool _isLoading = false;

  // Dropdown lists for year and branch
  final List<String> years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
  final List<String> branches = [
    'Civil Engineering',
    'Computer Science and Engineering',
    'Electrical and Electronics Eng',
    'Electronics and Instrumentation Eng',
    'Information Science and Engineering',
    'Mechanical Engineering',
    'Industrial Eng and Management',
    'Biotechnology',
    'Chemical Engineering',
    'Telecommunication Engineering',
    'AIML',
    'AIDS',
    'Structural Eng (M.Tech)',
    'Environmental Eng (M.Tech)',
    'Construction Management (M.Tech)',
    'Software Engineering (M.Tech)',
    'VLSI Design (M.Tech)',
    'Embedded Systems (M.Tech)',
    'Thermal Engineering (M.Tech)',
    'Power Systems (M.Tech)',
    'DEC (M.Tech)',
    'Others'
  ];

  @override
  void initState() {
    super.initState();
    nickname = widget.userData['nickname'] ?? '';
    roomNumber = widget.userData['room_number'] ?? '';
    age = widget.userData['age'] ?? '';
    year = widget.userData['year'] ?? '';
    branch = widget.userData['branch'] ?? '';
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Update the user's profile in Firestore
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'nickname': nickname,
        'room_number': roomNumber,
        'age': age,
        'year': year,
        'branch': branch,
      });

      // After updating the profile, navigate to the homepage
      Navigator.pushReplacementNamed(context, '/home');

    } catch (e) {
      // If there's an error, show it in a Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: nickname,
                  decoration: InputDecoration(labelText: 'Nickname'),
                  onChanged: (value) => nickname = value,
                  validator: (value) => value == null || value.isEmpty ? 'Nickname is required' : null,
                ),
                TextFormField(
                  initialValue: roomNumber,
                  decoration: InputDecoration(labelText: 'Room Number'),
                  onChanged: (value) => roomNumber = value,
                  validator: (value) => value == null || value.isEmpty ? 'Room Number is required' : null,
                ),
                TextFormField(
                  initialValue: age,
                  decoration: InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => age = value,
                  validator: (value) => value == null || value.isEmpty ? 'Age is required' : null,
                ),
                // Year Dropdown
                DropdownButtonFormField<String>(
                  value: year.isEmpty ? null : year,
                  decoration: InputDecoration(labelText: 'Year'),
                  items: years.map((yearOption) {
                    return DropdownMenuItem<String>(
                      value: yearOption,
                      child: Text(yearOption),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      year = value!;
                    });
                  },
                  validator: (value) => value == null || value.isEmpty ? 'Year is required' : null,
                ),
                // Branch Dropdown
                DropdownButtonFormField<String>(
                  value: branch.isEmpty ? null : branch,
                  decoration: InputDecoration(labelText: 'Branch'),
                  items: branches.map((branchOption) {
                    return DropdownMenuItem<String>(
                      value: branchOption,
                      child: Text(branchOption),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      branch = value!;
                    });
                  },
                  validator: (value) => value == null || value.isEmpty ? 'Branch is required' : null,
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _updateProfile();
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
