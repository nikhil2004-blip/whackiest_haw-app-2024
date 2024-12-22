import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool isNotificationsEnabled = true;
  bool isVibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(color: Colors.white)), // AppBar title text color
        backgroundColor: Color(0xFF2D3250), // Darker Blue color for AppBar
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // White back icon
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Dark Mode Switch Tile
            SwitchListTile(
              title: Text(
                'Dark Mode',
                style: TextStyle(
                  color: Color(0xFF676F9D), // Light Blue-Grey color for titles
                ),
              ),
              value: isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  isDarkMode = value;
                });
                // You can add logic here to actually switch themes if needed
              },
              activeColor: Color(0xFFf8b17a), // Golden color when active
            ),
            // Notifications Switch Tile
            SwitchListTile(
              title: Text(
                'Enable Notifications',
                style: TextStyle(
                  color: Color(0xFF676F9D), // Light Blue-Grey color for titles
                ),
              ),
              value: isNotificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  isNotificationsEnabled = value;
                });
                // Add logic for enabling/disabling notifications
              },
              activeColor: Color(0xFFf8b17a), // Golden color when active
            ),
            // Vibration Switch Tile
            SwitchListTile(
              title: Text(
                'Enable Vibration',
                style: TextStyle(
                  color: Color(0xFF676F9D), // Light Blue-Grey color for titles
                ),
              ),
              value: isVibrationEnabled,
              onChanged: (bool value) {
                setState(() {
                  isVibrationEnabled = value;
                });
                // Add logic for enabling/disabling vibration
              },
              activeColor: Color(0xFFf8b17a), // Golden color when active
            ),
          ],
        ),
      ),
    );
  }
}
