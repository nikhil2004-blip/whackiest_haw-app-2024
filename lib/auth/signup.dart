import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();

  String errorMessage = '';
  bool isSigningUp = false;

  String? selectedSex;
  String? selectedYear;
  String? selectedBranch;
  DateTime? selectedDOB;

  // List of year options
  List<String> yearOptions = ['1st Year', '2nd Year', '3rd Year', '4th Year'];

  // List of branch options (Example with a few branches from Ramiah Institute)
  List<String> branchOptions = [
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

  // Function to generate a unique username
  String _generateUsername(String nickname) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return "${nickname.toLowerCase().replaceAll(' ', '_')}_$timestamp";
  }

  Future<void> _signUp() async {
    setState(() {
      errorMessage = ''; // Clear previous error message
      isSigningUp = true; // Disable button
    });

    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nicknameController.text.isEmpty ||
        _roomController.text.isEmpty ||
        _ageController.text.isEmpty ||
        selectedSex == null ||
        selectedDOB == null ||
        selectedYear == null ||
        selectedBranch == null) {
      setState(() {
        errorMessage = 'All fields are required!';
        isSigningUp = false; // Re-enable button
      });
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      String uniqueUsername = _generateUsername(_nicknameController.text);

      final userId = userCredential.user?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'nickname': _nicknameController.text,
          'room_number': _roomController.text,
          'age': _ageController.text,
          'sex': selectedSex,
          'dob': selectedDOB,
          'year': selectedYear,
          'branch': selectedBranch,
          'username': uniqueUsername,
          'joinedOn': Timestamp.now(),
        });
      }

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        errorMessage = 'Sign up failed: ${e.toString()}';
        isSigningUp = false; // Re-enable button on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        centerTitle: true,
      ),
      body: SingleChildScrollView( // Make the whole page scrollable
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _emailController,
                labelText: 'Email',
                icon: Icons.email,
              ),
              _buildTextField(
                controller: _passwordController,
                labelText: 'Password',
                obscureText: true,
                icon: Icons.lock,
              ),
              _buildTextField(
                controller: _nicknameController,
                labelText: 'Nickname',
                icon: Icons.person,
              ),
              _buildTextField(
                controller: _roomController,
                labelText: 'Room Number',
                icon: Icons.home,
              ),
              _buildTextField(
                controller: _ageController,
                labelText: 'Age',
                icon: Icons.cake,
                keyboardType: TextInputType.number,
              ),
              _buildDatePickerField(),
              _buildDropdownField(
                label: 'Sex',
                value: selectedSex,
                items: ['Male', 'Female', 'Others'],
                onChanged: (newValue) {
                  setState(() {
                    selectedSex = newValue;
                  });
                },
                icon: Icons.person_outline, // Icon for sex dropdown
              ),
              _buildDropdownField(
                label: 'Year',
                value: selectedYear,
                items: yearOptions,
                onChanged: (newValue) {
                  setState(() {
                    selectedYear = newValue;
                  });
                },
                icon: Icons.school, // Icon for year dropdown
              ),
              _buildDropdownField(
                label: 'Branch',
                value: selectedBranch,
                items: branchOptions,
                onChanged: (newValue) {
                  setState(() {
                    selectedBranch = newValue;
                  });
                },
                icon: Icons.business, // Icon for branch dropdown
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(height: screenHeight * 0.03),
              ElevatedButton(
                onPressed: isSigningUp ? null : _signUp,
                child: Text(
                  isSigningUp ? 'Signing Up...' : 'Sign Up',
                  style: TextStyle(fontSize: screenWidth * 0.045),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: selectedDOB ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            setState(() {
              selectedDOB = pickedDate;
              _dobController.text = '${pickedDate.toLocal()}'.split(' ')[0];
            });
          }
        },
        child: AbsorbPointer(
          child: TextField(
            controller: _dobController,
            decoration: InputDecoration(
              labelText: 'Date of Birth',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
    );
  }
}
