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
        title: Text('All Members',style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF676F9D), Color(0xFF424769)],  // Gradient with shades of blue/grey
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
                  hintStyle: TextStyle(color: Color(0xFF676F9D)),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF676F9D)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,  // White background for the search box
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
                    color: Color(0xFF2D3250),  // Dark blue card background
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFF676F9D),  // Blue accent color for avatar
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,  // White text for title
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            'Nickname: $nickname',
                            style: TextStyle(color: Colors.white70),  // Light white color for subtitle
                          ),
                          Text(
                            'Room: $roomNumber',
                            style: TextStyle(color: Colors.white70),  // Light white color for subtitle
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
