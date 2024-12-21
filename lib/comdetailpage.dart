import 'package:flutter/material.dart';

class CommunityDetailsPage extends StatelessWidget {
  final Map<String, dynamic> group;  // Pass group data from the HomePage

  CommunityDetailsPage({required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(group['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,  // 2 tiles per row
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildTile('Item Ledger', Icons.archive, () {
              // Navigate to Item Ledger page
            }),
            _buildTile('Money Ledger', Icons.money, () {
              // Navigate to Money Ledger page
            }),
            _buildTile('Chat Room', Icons.chat, () {
              // Navigate to Chat Room page
            }),
            _buildTile('Exam Room', Icons.book, () {
              // Navigate to Exam Room page
            }),
            _buildTile('Complaint Room', Icons.report, () {
              // Navigate to Complaint Room page
            }),
            _buildTile('Other Room', Icons.more_horiz, () {
              // Navigate to other pages or functionality
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.blueAccent),
              SizedBox(height: 8),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
