import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ad.dart';  // Import the AppDrawer widget
import 'comdetailpage.dart';  // Import the new page

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isCreating = false;

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
            Text(
              'Your Communities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('groups')
                    .where('createdBy', isEqualTo: currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No groups found.'));
                  }
                  final groups = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index].data() as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          title: Text(group['name']),
                          subtitle: Text(group['description']),
                          onTap: () {
                            // Navigate to Group Details page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommunityDetailsPage(group: group),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton(
                  onPressed: _isCreating ? null : _createCommunity,
                  child: _isCreating
                      ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  )
                      : Icon(Icons.add),
                  backgroundColor: Colors.blueAccent,
                  tooltip: 'Create Community',
                ),
                FloatingActionButton(
                  onPressed: _joinCommunity,
                  child: Icon(Icons.group_add),
                  backgroundColor: Colors.blueAccent,
                  tooltip: 'Join Community',
                ),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/guardTracking');
                  },
                  child: Icon(Icons.map),
                  backgroundColor: Colors.orangeAccent,
                  tooltip: 'Guard Tracking',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Create and Join Community functions are unchanged


// Function to create a new community
  void _createCommunity() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();
    final participantsController = TextEditingController(); // Controller for number of participants

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Community'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Group Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Group Description'),
                ),
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Group Category'),
                ),
                TextField(
                  controller: participantsController,
                  decoration: InputDecoration(labelText: 'Number of Participants'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isCreating
                  ? null
                  : () async {
                final groupName = nameController.text;
                final groupDescription = descriptionController.text;
                final groupCategory = categoryController.text;
                final participants =
                    int.tryParse(participantsController.text) ?? 0;

                if (groupName.isNotEmpty &&
                    groupDescription.isNotEmpty &&
                    groupCategory.isNotEmpty &&
                    participants > 0) {
                  setState(() {
                    _isCreating = true; // Disable button and show loading
                  });

                  try {
                    await _firestore.collection('groups').add({
                      'name': groupName,
                      'description': groupDescription,
                      'category': groupCategory,
                      'participants': participants, // Store the number of participants
                      'createdBy': currentUser?.uid,
                      'createdAt': DateTime.now(),
                      'members': [currentUser?.uid],
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Group created successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to create group: $e')),
                    );
                  }

                  setState(() {
                    _isCreating = false; // Re-enable the button after the operation
                  });

                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields correctly.')),
                  );
                }
              },
              child: _isCreating
                  ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              )
                  : Text('Create'),
            ),
          ],
        );
      },
    );
  }

  // Function to join an existing community using a unique group ID
  void _joinCommunity() {
    final groupIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Join Community'),
          content: TextField(
            controller: groupIdController,
            decoration: InputDecoration(labelText: 'Enter Group ID'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final groupId = groupIdController.text;

                if (groupId.isNotEmpty) {
                  try {
                    // Check if the group exists in the database
                    final groupSnapshot = await _firestore.collection('groups').doc(groupId).get();

                    if (groupSnapshot.exists) {
                      // If the group exists, add the user to the group's members list
                      await _firestore.collection('groups').doc(groupId).update({
                        'members': FieldValue.arrayUnion([currentUser?.uid]),
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Joined community successfully!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Group not found.')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to join group: $e')),
                    );
                  }
                }
                Navigator.pop(context);
              },
              child: Text('Join'),
            ),
          ],
        );
      },
    );
  }
}

