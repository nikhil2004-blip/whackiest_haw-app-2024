import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MembersPage extends StatefulWidget {
  @override
  _MembersPageState createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  final _firestore = FirebaseFirestore.instance;
  final _searchController = TextEditingController();
  List<DocumentSnapshot> _members = [];
  List<DocumentSnapshot> _filteredMembers = [];

  @override
  void initState() {
    super.initState();
    _fetchAllMembers();
  }

  // Fetch all users from Firestore
  void _fetchAllMembers() async {
    try {
      final userDocs = await _firestore.collection('users').get();
      setState(() {
        _members = userDocs.docs;
        _filteredMembers = userDocs.docs; // Initially show all users
      });
    } catch (e) {
      print('Error fetching members: $e');
    }
  }

  // Filter members based on search query
  void _filterMembers(String query) {
    setState(() {
      _filteredMembers = _members.where((member) {
        final memberData = member.data() as Map<String, dynamic>;
        final username = (memberData['username'] ?? '').toLowerCase();
        final nickname = (memberData['nickname'] ?? '').toLowerCase();
        return username.contains(query.toLowerCase()) || nickname.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Members'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Members...',
                  prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (query) {
                  _filterMembers(query);
                },
              ),
            ),
            SizedBox(height: 16),

            // Members List
            Expanded(
              child: ListView.builder(
                itemCount: _filteredMembers.length,
                itemBuilder: (context, index) {
                  final memberData = _filteredMembers[index].data() as Map<String, dynamic>;

                  // Handle potential null values for username and nickname
                  final username = memberData['username'] ?? 'Unknown User';
                  final nickname = memberData['nickname'] ?? 'No Nickname';
                  final roomNumber = memberData['room_number'] ?? 'N/A';

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            'Nickname: $nickname',
                            style: TextStyle(color: Colors.black54),
                          ),
                          Text(
                            'Room: $roomNumber',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
