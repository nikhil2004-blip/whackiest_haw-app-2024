import 'package:flutter/material.dart';

class ItemLedgerPage extends StatelessWidget {
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
