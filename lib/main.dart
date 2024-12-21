import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'auth/login.dart'; // Import the login page
import 'auth/signup.dart'; // Import the signup page
import 'homepage.dart';
import 'profile.dart'; // Import the ProfilePage
import 'set.dart'; // Import SettingsPage
import 'package:firebase_auth/firebase_auth.dart';
import 'guard_tracking.dart';// For checking if the user is logged in
import 'members.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(); // Ensure Firebase is initialized
    print("Firebase initialized successfully");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hostel App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/', // Start route based on login state
      routes: {
        '/': (context) => AuthenticationWrapper(), // Start by checking login state
        '/signup': (context) => SignUpPage(),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
        '/settings': (context) => SettingsPage(), // Settings page route
        '/login': (context) => LoginPage(), // Ensure /login route is defined
        '/guardTracking': (context) => GuardMap(),
        '/members': (context) => MembersPage(),

      },
    );
  }
}

// Authentication wrapper to check if the user is logged in
class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Check if Firebase Auth is actively trying to get the authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          print("Waiting for auth state");
          return Center(child: CircularProgressIndicator());
        }

        // Handle the authentication state
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            print("User is logged in: ${snapshot.data?.uid}");
            return HomePage(); // User is logged in, navigate to HomePage
          } else {
            print("User is not logged in");
            return LoginPage(); // User is not logged in, navigate to LoginPage
          }
        }

        // In case of error, show an error message
        return Center(child: Text('Error checking authentication state'));
      },
    );
  }
}
