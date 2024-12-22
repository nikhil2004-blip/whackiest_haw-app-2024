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
                onPressed: () {
                  if (_complaintController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Complaint cannot be empty!')),
                    );
                  } else {
                    _sendEmail();
                  }
                },
                child: Text('Submit Complaint'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
