import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibration/vibration.dart';
import 'ad.dart'; // Import the AppDrawer widget
import 'item.dart'; // Replace with your actual import for Item Ledger
import 'money.dart'; // Replace with your actual import for Money Ledger
import 'chat.dart'; // Replace with your actual import for Chat Room
import 'exam.dart'; // Replace with your actual import for Exam Room
import 'complaint.dart'; // Replace with your actual import for Complaint Room
import 'guard_tracking.dart'; // Replace with your actual import for Guard Tracking

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool isAssembling = false;
  String note = '';

  @override
  void initState() {
    super.initState();
    _listenForAssembleMessages();

    // Add lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Ensure FocusNode is unfocused when returning to the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.unfocus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _noteController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _focusNode.unfocus();
    }
    super.didChangeAppLifecycleState(state);
  }

  // Listen for changes in Firestore
  void _listenForAssembleMessages() {
    _firestore.collection('assemble').doc('message').snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (data['showMessage'] == true && !isAssembling) {
          setState(() {
            isAssembling = true;
            note = data['note'] ?? '';
          });

          // Start vibration
          if (data['vibrating'] == true) {
            _startVibration();
          }
        } else if (data['showMessage'] == false) {
          setState(() {
            isAssembling = false;
            note = '';
          });

          // Stop vibration
          _stopVibration();
        }
      }
    });
  }

  // Start vibrations
  Future<void> _startVibration() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(pattern: [1000, 500, 1000, 500], repeat: 2);
    }
  }

  // Stop vibrations
  Future<void> _stopVibration() async {
    Vibration.cancel();
  }

  // Trigger an assemble action
  Future<void> _assemble() async {
    String note = _noteController.text;

    await _firestore.collection('assemble').doc('message').set({
      'note': note,
      'vibrating': true,
      'showMessage': true,
    });

    _noteController.clear();
  }

  // Close the emergency card
  Future<void> _closeEmergency() async {
    await _firestore.collection('assemble').doc('message').set({
      'note': '',
      'vibrating': false,
      'showMessage': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Home',style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF676F9D), // #676f9d for AppBar background
        ),
        drawer: AppDrawer(currentUser: currentUser),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isAssembling)
                Card(
                  color: Colors.red, // Red card for emergency
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emergency! Assembly Needed:',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Text(
                          note,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _closeEmergency,
                          child: Text('Close'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 10),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildTile('Item Ledger', Icons.inventory_2, ItemLendingApp()),
                    _buildTile('Money Ledger', Icons.attach_money, MoneyLedgerPage()),
                    _buildTile('Chat Room', Icons.chat, ChatPage()),
                    _buildTile('Exam Room', Icons.school, ExamRoomPage(userId: '')),
                    _buildTile('Complaint Room', Icons.report_problem, ComplaintBoxApp()),
                    _buildTile('Guard Tracking', Icons.map, GuardMap()),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _noteController,
                      focusNode: _focusNode, // Linked FocusNode
                      decoration: InputDecoration(
                        hintText: 'Enter assembly note',
                        filled: true,
                        fillColor: Color(0xFFF0F0F0), // Light gray background for text input
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  FloatingActionButton(
                    onPressed: _assemble,
                    child: Icon(Icons.campaign),
                    backgroundColor: Color(0xFFF9B17A), // Soft orange button
                    tooltip: 'Assemble Now',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to create a tile
  Widget _buildTile(String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus(); // Unfocus before navigating
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Color(0xFF676F9D), // Tile color
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}