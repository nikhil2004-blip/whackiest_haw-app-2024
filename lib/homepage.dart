import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haw/guard_tracking.dart';
import 'ad.dart';  // Import the AppDrawer widget
import 'item.dart';  // Replace with your actual import for Item Ledger
import 'money.dart';  // Replace with your actual import for Money Ledger
import 'chat.dart';   // Replace with your actual import for Chat Room
import 'exam.dart';   // Replace with your actual import for Exam Room
import 'complaint.dart'; // Replace with your actual import for Complaint Room

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: AppDrawer(currentUser: currentUser),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 10),
            // Tile Style GridView
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Two tiles per row
                crossAxisSpacing: 10, // Space between columns
                mainAxisSpacing: 10, // Space between rows
                children: [
                  _buildTile(
                    'Item Ledger',
                    Icons.inventory_2,
                    ItemLendingApp(),  // Replace with your actual Item Ledger page
                  ),
                  _buildTile(
                    'Money Ledger',
                    Icons.attach_money,
                    MoneyLedgerPage(),  // Replace with your actual Money Ledger page
                  ),
                  _buildTile(
                    'Chat Room',
                    Icons.chat,
                    ChatPage(),  // Replace with your actual Chat Room page
                  ),
                  _buildTile(
                    'Exam Room',
                    Icons.school,
                    ExamRoomPage(),  // Replace with your actual Exam Room page
                  ),
                  _buildTile(
                    'Complaint Room',
                    Icons.report_problem,
                    ComplaintBoxApp(),  // Replace with your actual Complaint Room page
                  ),
                  _buildTile(
                    'Guard Tracking',
                    Icons.map,
                    GuardMap(), // Replace with your actual Guard Tracking page
                    //isSpecial: true, // Add a flag for special styling if needed
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    //Navigator.pushNamed(context, '/guardTracking');
                  },
                  child: Icon(Icons.handyman_outlined),
                  backgroundColor: Colors.orangeAccent,
                  tooltip: '',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to create a tile
  Widget _buildTile(String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => page,
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
