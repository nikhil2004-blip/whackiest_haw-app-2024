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
      appBar: AppBar(
        title: Text('Edit Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF2D3250), // Darker Blue for AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Add padding to each form field to ensure spacing
                _buildTextFormField(
                  initialValue: nickname,
                  label: 'Nickname',
                  onChanged: (value) => nickname = value,
                  validator: (value) => value == null || value.isEmpty ? 'Nickname is required' : null,
                ),
                SizedBox(height: 16), // Space between fields
                _buildTextFormField(
                  initialValue: roomNumber,
                  label: 'Room Number',
                  onChanged: (value) => roomNumber = value,
                  validator: (value) => value == null || value.isEmpty ? 'Room Number is required' : null,
                ),
                SizedBox(height: 16), // Space between fields
                _buildTextFormField(
                  initialValue: age,
                  label: 'Age',
                  keyboardType: TextInputType.number,
                  onChanged: (value) => age = value,
                  validator: (value) => value == null || value.isEmpty ? 'Age is required' : null,
                ),
                SizedBox(height: 16), // Space between fields

                // Year Dropdown with padding
                _buildDropdownField(
                  label: 'Year',
                  value: year.isEmpty ? null : year,
                  items: years,
                  onChanged: (value) {
                    setState(() {
                      year = value!;
                    });
                  },
                  validator: (value) => value == null || value.isEmpty ? 'Year is required' : null,
                ),
                SizedBox(height: 16), // Space between fields

                // Branch Dropdown with padding
                _buildDropdownField(
                  label: 'Branch',
                  value: branch.isEmpty ? null : branch,
                  items: branches,
                  onChanged: (value) {
                    setState(() {
                      branch = value!;
                    });
                  },
                  validator: (value) => value == null || value.isEmpty ? 'Branch is required' : null,
                ),
                SizedBox(height: 20), // Space before the button

                // Loading or Save button
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _updateProfile();
                    }
                  },
                  child: Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF8B17A), // Golden Yellow for button
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: TextStyle(fontSize: 16, color: Color(0xFF424769)), // Dark Blue-Grey for text
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom text field widget with consistent styling
  Widget _buildTextFormField({
    required String initialValue,
    required String label,
    TextInputType? keyboardType,
    required ValueChanged<String> onChanged,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF676F9D)), // Light Blue-Grey label color
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF676F9D), width: 2), // Light Blue-Grey border
        ),
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
    );
  }

  // Custom dropdown field with consistent styling
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required FormFieldValidator<String?> validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF676F9D)), // Light Blue-Grey label color
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF676F9D), width: 2), // Light Blue-Grey border
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      validator: validator,
    );
  }
}
