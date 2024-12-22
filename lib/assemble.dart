import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssemblePage extends StatefulWidget {
  @override
  _AssemblePageState createState() => _AssemblePageState();
}

class _AssemblePageState extends State<AssemblePage> with WidgetsBindingObserver {
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
      appBar: AppBar(
        backgroundColor: Color(0xFF676F9D), // Soft Blue for the AppBar
        title: Text('Assemble Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assemble Now',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF424769))),
            SizedBox(height: 20),
            Text(
              'Enter the assembly note for all members:',
              style: TextStyle(fontSize: 18, color: Color(0xFF424769)),
            ),
            TextField(
              controller: _noteController, // Link TextField with controller
              decoration: InputDecoration(
                hintText: 'Enter note here',
                filled: true,
                fillColor: Color(0xFFF1F1F1), // Light Gray background for the TextField
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF676F9D)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _assemble, // Trigger vibration and notification
              child: Text('Assemble'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF8B178),  // Valid gold color
                foregroundColor: Colors.white, // White text color on the button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            if (isAssembling) ...[
              SizedBox(height: 20),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background - Holographic glass effect with glowing outline
                    Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.6),
                            blurRadius: 30,
                            spreadRadius: 20,
                            offset: Offset(0, 0),
                          ),
                          BoxShadow(
                            color: Colors.pinkAccent.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 5,
                            offset: Offset(5, 5),
                          ),
                        ],
                      ),
                    ),
                    // Main alert card with 3D glassy effect
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          width: 2,
                          color: Colors.blueAccent.withOpacity(0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.7),
                            blurRadius: 25,
                            spreadRadius: 15,
                            offset: Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title with Glowing Icon
                          Row(
                            children: [
                              Icon(
                                Icons.warning_rounded,
                                size: 35,
                                color: Colors.purpleAccent,
                              ),
                              SizedBox(width: 15),
                              Text(
                                'Critical Assembly Alert!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10,
                                      color: Colors.purpleAccent.withOpacity(0.6),
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          // Alert message with futuristic font style and animation
                          AnimatedDefaultTextStyle(
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                              fontFamily: 'RobotoMono', // Monospace font for futuristic feel
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(
                                  blurRadius: 15,
                                  color: Colors.greenAccent.withOpacity(0.8),
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            duration: Duration(seconds: 1),
                            child: Text(
                              note,
                              textAlign: TextAlign.justify,
                            ),
                          ),
                          SizedBox(height: 25),
                          // Interactive close button with glowing effect
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: _closeEmergency,
                              icon: Icon(
                                Icons.power_settings_new_rounded,
                                size: 30,
                                color: Colors.white,
                              ),
                              label: Text(
                                'Deactivate Alert',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white, backgroundColor: Colors.deepOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 15,
                                shadowColor: Colors.deepOrange.withOpacity(0.6),
                                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]


          ],
        ),
      ),
    );
  }
}
