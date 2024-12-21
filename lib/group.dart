import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupPage extends StatefulWidget {
  final String groupId; // Pass group ID for Firebase query.

  GroupPage({required this.groupId});

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> members = [];
  String groupName = "";

  @override
  void initState() {
    super.initState();
    _fetchGroupData();
  }

  void _fetchGroupData() async {
    try {
      // Fetch group details from Firebase.
      final groupSnapshot =
      await _firestore.collection('groups').doc(widget.groupId).get();

      if (groupSnapshot.exists) {
        final groupData = groupSnapshot.data();
        setState(() {
          groupName = groupData?['name'] ?? 'Group';
          members = List<Map<String, dynamic>>.from(groupData?['members'] ?? []);
        });
      }
    } catch (e) {
      print("Error fetching group data: $e");
    }
  }

  void _triggerAssemble() async {
    try {
      // Log the assemble action in Firebase.
      await _firestore
          .collection('groups')
          .doc(widget.groupId)
          .update({'lastAssemble': DateTime.now().toString()});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assemble triggered!')),
      );

      // Add additional functionality like notifications or sound here.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to trigger assemble: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
      ),
      body: members.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two tiles per row.
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: member['profilePicture'] != null
                      ? NetworkImage(member['profilePicture'])
                      : null,
                  child: member['profilePicture'] == null
                      ? Icon(Icons.person, size: 30)
                      : null,
                ),
                SizedBox(height: 10),
                Text(
                  member['name'] ?? 'Unknown',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  member['status'] ?? 'Inactive',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _triggerAssemble,
        child: Icon(Icons.campaign), // Icon for assemble action.
        tooltip: 'Assemble',
      ),
    );
  }
}
