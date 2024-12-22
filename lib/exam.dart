import 'package:flutter/material.dart';

import 'cie_chat_screen.dart';
//import 'cie_chat_screen.dart';

class ExamRoomPage extends StatelessWidget {
  final String userId;

  ExamRoomPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CIE Chat Rooms')),
      body: ListView(
        children: ['CIE-1', 'CIE-2', 'SEE'].map((title) {
          return ListTile(
            title: Text(title),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CieChatScreen(title: title, userId: 'xxx'),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
