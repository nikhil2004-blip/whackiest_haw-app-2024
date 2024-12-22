import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssemblePage extends StatefulWidget {
  @override
  _AssemblePageState createState() => _AssemblePageState();
}

class _AssemblePageState extends State<AssemblePage> with WidgetsBindingObserver{
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final TextEditingController _noteController = TextEditingController();


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isAssembling = false;
  String note = '';

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _listenForAssembleMessages();
  }


  // Initialize local notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Show local notification
  Future<void> _showNotification(String note) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'assemble_channel',
      'Assemble Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Assemble Now!',
      note,
      notificationDetails,
      payload: 'assemble',
    );
  }

  // Start vibrations
  Future<void> _startVibration() async {
    bool? hasVibrator = await Vibration.hasVibrator();

    if (hasVibrator != null && hasVibrator) {
      Vibration.vibrate(pattern: [1000, 500, 1000, 500], repeat: 2); // Emergency vibration
    }
  }

  // Stop vibrations
  Future<void> _stopVibration() async {
    Vibration.cancel();
  }

  // Trigger an assemble action
  Future<void> _assemble() async {
    String note = _noteController.text;


    // Update Firestore to trigger the message on all devices
    await _firestore.collection('assemble').doc('message').set({
      'note': note,
      'vibrating': true,
      'showMessage': true,
    });

    // Start vibration on the initiating device
    await _startVibration();

    // Exit this page and navigate to the homepage
    Navigator.pop(context);
  }


  // Listen for changes in Firestore
  void _listenForAssembleMessages() {
    _firestore.collection('assemble').doc('message').snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;

        // Check if it's a new assembly
        if (data['showMessage'] == true && !isAssembling) {
          setState(() {
            isAssembling = true;
            note = data['note'] ?? '';
          });

          // Show notification to all devices
          _showNotification(note);

          // Start vibration on other devices
          if (data['vibrating'] == true) {
            _startVibration();
          }
        }
      }
    });
  }

  // Close the emergency page and stop vibration
  Future<void> _closeEmergency() async {
    setState(() {
      isAssembling = false;
    });

    // Stop vibration
    await _stopVibration();

    // Update Firestore to stop the message and vibration
    await _firestore.collection('assemble').doc('message').set({
      'note': '',
      'vibrating': false,
      'showMessage': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assemble Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assemble Now', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('Enter the assembly note for all members:', style: TextStyle(fontSize: 18)),
            TextField(

              controller: _noteController, // Link TextField with controller

              decoration: InputDecoration(hintText: 'Enter note here'),

            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _assemble, // Trigger vibration and notification
              child: Text('Assemble'),
            ),
            if (isAssembling) ...[
              SizedBox(height: 20),
              Card(
                color: Colors.red,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Emergency! Assembly Needed:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 10),
                      Text(note, style: TextStyle(fontSize: 18, color: Colors.white)),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _closeEmergency, // Close the emergency message and stop vibration
                        child: Text('Close', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
