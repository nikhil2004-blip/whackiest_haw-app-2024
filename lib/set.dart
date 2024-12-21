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
        title: Text("Settings"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SwitchListTile(
              title: Text('Dark Mode'),
              value: isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  isDarkMode = value;
                });
                // You can add logic to actually switch themes
              },
            ),
            SwitchListTile(
              title: Text('Enable Notifications'),
              value: isNotificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  isNotificationsEnabled = value;
                });
                // Add logic for enabling/disabling notifications
              },
            ),
            SwitchListTile(
              title: Text('Enable Vibration'),
              value: isVibrationEnabled,
              onChanged: (bool value) {
                setState(() {
                  isVibrationEnabled = value;
                });
                // Add logic for enabling/disabling vibration
              },
            ),
          ],
        ),
      ),
    );
  }
}
