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
        primarySwatch: Colors.blue,
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
  String wardenEmail = 'warden@hostel.com'; // Editable Warden email
  String supervisorEmail = 'supervisor@hostel.com'; // Editable Supervisor email
  String defaultEmail = 'admin@hostel.com'; // Editable Default email

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

    final smtpServer = gmail('your-email@gmail.com', 'your-app-password'); // Replace with your email and app-specific password

    final message = Message()
      ..from = Address('your-email@gmail.com', 'Your Name') // Replace with your email and name
      ..recipients.add(recipientEmail)
      ..subject = 'Complaint to $selectedPerson'
      ..text = _complaintController.text;

    try {
      final sendReport = await send(message, smtpServer);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Complaint sent successfully!'),
      ));
      _complaintController.clear(); // Clear the complaint after sending
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send complaint. Please try again!'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaint Box'),
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
                  label: Text('Warden'),
                  selected: selectedPerson == 'Warden',
                  onSelected: (selected) {
                    setState(() {
                      selectedPerson = 'Warden';
                    });
                  },
                ),
                SizedBox(width: 16),
                ChoiceChip(
                  label: Text('Supervisor'),
                  selected: selectedPerson == 'Supervisor',
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
                border: OutlineInputBorder(),
                hintText: 'Enter your complaint',
              ),
              maxLines: 6,
            ),
            SizedBox(height: 20),

            // Submit button
            Center(
              child: ElevatedButton(
                onPressed: _sendEmail,
                child: Text('Submit Complaint'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
