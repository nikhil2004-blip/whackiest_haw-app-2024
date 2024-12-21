import 'package:flutter/material.dart';

class ExamRoomPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Ledger'),
      ),
      body: Center(
        child: Text(
          'Welcome to the Item Ledger',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}