import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'item.dart';
import 'money.dart';
import 'chat.dart';
import 'exam.dart';
import 'complaint.dart';

class CommunityDetailsPage extends StatelessWidget {
  final Map<String, dynamic> group;  // Pass group data from the HomePage

  CommunityDetailsPage({required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(group['name']),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupInfoPage(group: group),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,  // 2 tiles per row
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildTile('Item Ledger', Icons.archive, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ItemLedgerPage()),
          );
        }),
        _buildTile('Money Ledger', Icons.money, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MoneyLedgerPage()),
          );
        }),
        _buildTile('Chat Room', Icons.chat, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatPage()),
          );
        }),
        _buildTile('Exam Room', Icons.book, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExamRoomPage()),
          );
        }),
        _buildTile('Complaint Room', Icons.report, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ComplaintRoomPage()),
          );
        }),

          ],
        ),
      ),
    );
  }

  Widget _buildTile(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.blueAccent),
              SizedBox(height: 8),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class GroupInfoPage extends StatefulWidget {
  final Map<String, dynamic> group;

  GroupInfoPage({required this.group});

  @override
  _GroupInfoPageState createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  final _firestore = FirebaseFirestore.instance;
  final _searchController = TextEditingController();
  List<DocumentSnapshot> _participants = [];

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
  }

  // Fetch group participants from Firestore
  void _fetchParticipants() async {
    try {
      final groupDoc = await _firestore.collection('groups').doc(
          widget.group['id']).get();
      if (groupDoc.exists) {
        final memberIds = List<String>.from(groupDoc['members']);
        final participantDocs = await Future.wait(
          memberIds.map((userId) async {
            return await _firestore.collection('users').doc(userId).get();
          }),
        );

        setState(() {
          _participants = participantDocs;
        });
      }
    } catch (e) {
      print('Error fetching participants: $e');
    }
  }

  // Search participants by username
  void _searchParticipants(String query) {
    setState(() {
      _participants = _participants
          .where((participant) {
        // Search by username
        final userData = participant.data() as Map<String, dynamic>;
        return userData['username'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.group['name']} - Group Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Information
            Text(
              'Group Description: ${widget.group['description']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Category: ${widget.group['category']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Participants',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _searchParticipants(value);
              },
            ),
            SizedBox(height: 20),

            // Add Participant Button
            ElevatedButton(
              onPressed: () {
                _showAddParticipantDialog(context);
              },
              child: Text('Add Participant'),
            ),
            SizedBox(height: 20),

            // Participants List
            Expanded(
              child: ListView.builder(
                itemCount: _participants.length,
                itemBuilder: (context, index) {
                  final participant = _participants[index].data() as Map<
                      String,
                      dynamic>;
                  return ListTile(
                    title: Text(participant['username']),
                    subtitle: Text(participant['email']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog to add participants
  void _showAddParticipantDialog(BuildContext context) {
    final usernameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Participant'),
          content: TextField(
            controller: usernameController,
            decoration: InputDecoration(labelText: 'Enter participant username'),
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
                final username = usernameController.text.trim();

                if (username.isNotEmpty) {
                  try {
                    // Search for the user by username
                    final userSnapshot = await _firestore
                        .collection('users')
                        .where('username', isEqualTo: username)
                        .limit(1)
                        .get();

                    if (userSnapshot.docs.isNotEmpty) {
                      // User found
                      final userDoc = userSnapshot.docs.first;
                      final userId = userDoc.id; // Extract user document ID

                      // Fetch the group document
                      final groupDoc = await _firestore.collection('groups').doc(widget.group['id']).get();

                      if (groupDoc.exists) {
                        List members = List<String>.from(groupDoc['members'] ?? []);

                        if (members.contains(userId)) {
                          // User is already a member
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('User is already a member!')),
                          );
                        } else {
                          // Add the user to the group
                          await _firestore.collection('groups').doc(widget.group['id']).update({
                            'members': FieldValue.arrayUnion([userId]),
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Participant added successfully!')),
                          );

                          // Refresh the participant list
                          _fetchParticipants();
                        }
                      } else {
                        // Group not found
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Group not found.')),
                        );
                      }
                    } else {
                      // User not found
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('User not found.')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }

                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

