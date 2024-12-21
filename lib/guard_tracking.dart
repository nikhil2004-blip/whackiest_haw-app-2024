import 'package:flutter/material.dart';

class GuardTrackingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guard '),
      ),
      body: Center(
        child: Text(
          'Guard Tracking Page',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
