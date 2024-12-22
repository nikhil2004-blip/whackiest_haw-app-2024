import 'package:flutter/material.dart';
import 'cie_chat_screen.dart'; // Assuming this is the correct import for the CieChatScreen

class ExamRoomPage extends StatelessWidget {
  final String userId;

  ExamRoomPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CIE Chat Rooms'),
        centerTitle: true,
        backgroundColor: Colors.teal, // Changed to a more modern color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: ['CIE-1', 'CIE-2', 'SEE'].map((title) {
            return Card(
              elevation: 4, // Gives a slight shadow effect
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                title: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(Icons.arrow_forward, color: Colors.teal),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CieChatScreen(title: title, userId: userId),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
