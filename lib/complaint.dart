import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

void main() {
  runApp(ComplaintBoxApp());
}

class ComplaintBoxApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Complaint Box',
      theme: ThemeData(
        // Use the new colorScheme property instead of accentColor
        colorScheme: ColorScheme.light(
          primary: Color(0xFF676F9D), // Soft purple-blue for primary color
          secondary: Color(0xFFF9B17A), // Light orange for secondary/accent color
        ),
        scaffoldBackgroundColor: Color(0xFFFFFFFF), // White background for scaffold
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF424769)), // Dark gray for body text
          bodyMedium: TextStyle(color: Color(0xFF424769)), // Dark gray for smaller body text
          headlineSmall: TextStyle(color: Color(0xFF424769)), // Dark gray for headline (AppBar title)
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Color(0xFF424769)), // Label text color
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF676F9D)), // Border color for text fields
            borderRadius: BorderRadius.circular(8), // Rounded corners for text field
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF676F9D)), // Border color on focus
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFFF9B17A), // Set button color to light orange
          textTheme: ButtonTextTheme.primary, // Ensure button text is legible
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Color(0xFF2D3250), // Dark background for snackbars
          contentTextStyle: TextStyle(color: Colors.white), // White text in snackbar
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.transparent,
          selectedColor: Color(0xFF676F9D), // Selected color for Choice Chips
          disabledColor: Color(0xFF2D3250), // Disabled color for Choice Chips
          labelStyle: TextStyle(color: Colors.white), // White text on the chips
        ),
      ),
      home: ComplaintFormScreen(),
    );
  }
}

class ComplaintFormScreen extends StatefulWidget {
  @override
  _ComplaintFormScreenState createState() => _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends State<ComplaintFormScreen> {
  String selectedPerson = 'Warden';
  final TextEditingController _complaintController = TextEditingController();

  // Editable email addresses
  String wardenEmail = 'warden@hostel.com';
  String supervisorEmail = 'supervisor.dummy404@gmail.com';
  String defaultEmail = 'sbiy6996@gmail.com';

  // Function to handle sending email
  Future<void> _sendEmail() async {
    String recipientEmail;

    if (selectedPerson == 'Warden') {
      recipientEmail = wardenEmail;
    } else if (selectedPerson == 'Supervisor') {
      recipientEmail = supervisorEmail;
    } else {
      recipientEmail = defaultEmail;
    }

    // Replace with your email and app password
    final smtpServer = gmail('sbiy6996@gmail.com', 'formalcharge');

    final message = Message()
      ..from = Address('sbiy6996@gmail.com', 'Complaint Box') // Sender details
      ..recipients.add(recipientEmail) // Recipient email
      ..subject = 'Complaint to $selectedPerson' // Email subject
      ..text = _complaintController.text; // Complaint content

    try {
      await send(message, smtpServer);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complaint sent successfully!')),
      );
      _complaintController.clear(); // Clear the text field
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send complaint: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaint Box'),
        backgroundColor: Color(0xFF676F9D), // App bar with soft purple-blue color
        foregroundColor: Colors.white, // White text on app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warden and Supervisor selection
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Text(
                    'Warden',
                    style: TextStyle(color: selectedPerson == 'Warden' ? Colors.white : Colors.black), // Text is black initially, white when selected
                  ),
                  selected: selectedPerson == 'Warden',
                  selectedColor: Color(0xFF676F9D), // Soft purple-blue when selected
                  onSelected: (selected) {
                    setState(() {
                      selectedPerson = 'Warden';
                    });
                  },
                ),
                SizedBox(width: 16),
                ChoiceChip(
                  label: Text(
                    'Supervisor',
                    style: TextStyle(color: selectedPerson == 'Supervisor' ? Colors.white : Colors.black), // Text is black initially, white when selected
                  ),
                  selected: selectedPerson == 'Supervisor',
                  selectedColor: Color(0xFF676F9D), // Soft purple-blue when selected
                  onSelected: (selected) {
                    setState(() {
                      selectedPerson = 'Supervisor';
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),

            // Complaint text area
            TextField(
              controller: _complaintController,
              decoration: InputDecoration(
                labelText: 'Write your complaint here',
                hintText: 'Enter your complaint',
                border: OutlineInputBorder(),
              ),
              maxLines: 6,
            ),
            SizedBox(height: 20),

            // Submit button with updated color
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_complaintController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Complaint cannot be empty!')),
                    );
                  } else {
                    _sendEmail();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF9B17A), // Set the button color to light orange (#F9B17A)
                  foregroundColor: Color(0xFF424769), // Text color of the button
                ),
                child: Text('Submit Complaint'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
