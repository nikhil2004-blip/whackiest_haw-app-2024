import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  late String _userId;
  late String _username;
  final ScrollController _scrollController = ScrollController(); // Scroll controller

  @override
  void initState() {
    super.initState();
    _initFCM();
    _userId = _auth.currentUser?.uid ?? ''; // Get user ID
    _username = _auth.currentUser?.email ?? 'Guest'; // Set a default username (email)
    _loadNickname(); // Fetch nickname
  }

  // Initialize Firebase Cloud Messaging
  Future<void> _initFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
    });

    // Request notification permission for iOS
    await _firebaseMessaging.requestPermission();
  }

  // Show local notifications
  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'chat_channel_id',
      'Chat Channel',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: 'chat',
    );
  }

  // Fetch nickname from Firestore
  Future<void> _loadNickname() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Fetch the nickname from Firestore 'users' collection
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _username = userDoc['nickname'] ?? 'Guest'; // Update to nickname if available
        });
      }
    }
  }

  // Send a message to Firestore
  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      await _firestore.collection('chat').add({
        'message': _controller.text,
        'sender': _username, // Use nickname as sender
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();
    }
  }

  // Build the chat UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),

      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('chat').orderBy('timestamp').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final messages = snapshot.data?.docs ?? [];
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // Ensure the list is scrolled to the bottom when new data is loaded
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController, // Attach the controller here
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index]['message'];
                    final sender = messages[index]['sender'];
                    final isSentByCurrentUser = sender == _username;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0), // Padding added here
                      child: Row(
                        mainAxisAlignment: isSentByCurrentUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: isSentByCurrentUser ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sender, // Display the nickname
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSentByCurrentUser ? Colors.white : Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  message,
                                  style: TextStyle(
                                    color: isSentByCurrentUser ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },

                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Enter your message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Scroll to the bottom of the list
  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }
}
