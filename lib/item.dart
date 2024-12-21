import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(ItemLendingApp());
}

class ItemLendingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Item Lending App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ItemListScreen(),
    );
  }
}

class ItemListScreen extends StatefulWidget {
  @override
  _ItemListScreenState createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new item to Firestore
  Future<void> _addItem(Map<String, dynamic> newItem) async {
    await _firestore.collection('items').add(newItem);
  }

  // Update an item in Firestore
  Future<void> _updateItem(Map<String, dynamic> updatedItem) async {
    final docId = updatedItem['id'];
    await _firestore.collection('items').doc(docId).update(updatedItem);
  }

  // Delete an item from Firestore
  Future<void> _deleteItem(String itemId) async {
    await _firestore.collection('items').doc(itemId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Lending'),
      ),


      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('items').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              'name': data['name'] ?? '',
              'status': data['status'] ?? 'Available',
              'owner': data['owner'] ?? '',
              'borrower': data['borrower'] ?? '',
              'room': data['room'] ?? '',
            };
          }).toList();

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateItemScreen(
                      item: item,
                      onUpdateItem: _updateItem,
                      onDeleteItem: _deleteItem,
                    ),
                  ),
                ),
                child: ListTile(
                  title: Text(item['name'] ?? 'Unnamed Item'),
                  subtitle: Text(
                    'Status: ${item['status'] ?? 'Unknown'}, Owner: ${item['owner'] ?? 'Unknown'}, '
                        '${item['status'] == 'Borrowed' ? 'Borrower: ${item['borrower'] ?? 'None'}, Room: ${item['room'] ?? 'N/A'}' : ''}',
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddItemScreen(onAddItem: _addItem),
          ),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddItemScreen extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic>) onAddItem;

  AddItemScreen({required this.onAddItem});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedOwner;
  List<String> _owners = [];

  @override
  void initState() {
    super.initState();
    _fetchOwners();
  }

  void _fetchOwners() async {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final currentUserDoc = await usersCollection.doc(currentUser.uid).get();
      final currentUserNickname = currentUserDoc['nickname'];

      final snapshot = await usersCollection.get();
      setState(() {
        _owners = snapshot.docs
            .map((doc) => doc['nickname'] as String)
            .where((nickname) => nickname != currentUserNickname)
            .toList();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Item'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Item Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item name';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedOwner,
                hint: Text('Select Owner'),
                onChanged: (value) {
                  setState(() {
                    _selectedOwner = value;
                  });
                },
                items: _owners.map((owner) {
                  return DropdownMenuItem<String>(
                    value: owner,
                    child: Text(owner),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select an owner';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final newItem = {
                      'name': _nameController.text,
                      'owner': _selectedOwner ?? '',
                      'status': 'Available',
                      'borrower': '',
                      'room': '',
                    };
                    await widget.onAddItem(newItem);
                    Navigator.pop(context);
                  }
                },
                child: Text('Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdateItemScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final Future<void> Function(Map<String, dynamic>) onUpdateItem;
  final Future<void> Function(String) onDeleteItem;

  UpdateItemScreen({
    required this.item,
    required this.onUpdateItem,
    required this.onDeleteItem,
  });

  @override
  _UpdateItemScreenState createState() => _UpdateItemScreenState();
}

class _UpdateItemScreenState extends State<UpdateItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedBorrower;
  List<String> _users = [];
  String? _currentUserNickname;
  String _room = 'N/A'; // Default value

  @override
  void initState() {
    super.initState();
    _fetchUsersAndCurrentUser();
  }

  Future<void> _fetchUsersAndCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final usersCollection = FirebaseFirestore.instance.collection('users');

      final currentUserDoc = await usersCollection.doc(currentUser.uid).get();
      setState(() {
        _currentUserNickname = currentUserDoc['nickname'];
      });

      final snapshot = await usersCollection.get();
      setState(() {
        _users = snapshot.docs.map((doc) => doc['nickname'] as String).toList();
      });
    }
  }

  Future<void> _fetchRoomForBorrower(String borrowerNickname) async {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final borrowerDoc = await usersCollection.where('nickname', isEqualTo: borrowerNickname).get();

    if (borrowerDoc.docs.isNotEmpty) {
      setState(() {
        _room = borrowerDoc.docs.first['room_number'] ?? 'N/A';
      });
    } else {
      setState(() {
        _room = 'N/A';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Item'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (widget.item['status'] == 'Available') ...[
                DropdownButtonFormField<String>(
                  value: _selectedBorrower,
                  hint: Text('Select Borrower'),
                  onChanged: (value) {
                    setState(() {
                      _selectedBorrower = value;
                    });
                    if (value != null && value != _currentUserNickname) {
                      _fetchRoomForBorrower(value);
                    }
                  },
                  items: _users.map((user) {
                    return DropdownMenuItem<String>(
                      value: user,
                      child: Text(user),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a borrower';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Room: $_room',
                  style: TextStyle(fontSize: 16),
                ),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_selectedBorrower == widget.item['owner']) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('You cannot borrow an item from yourself!')),
                      );
                      return;
                    }

                    widget.item['borrower'] = _selectedBorrower!;
                    widget.item['room'] = _room;
                    widget.item['status'] = 'Borrowed';
                    widget.onUpdateItem(widget.item);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Item updated successfully!')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Update Item'),
              ),
              if (widget.item['status'] == 'Borrowed') ...[
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    widget.item['status'] = 'Available';
                    widget.item['borrower'] = '';
                    widget.item['room'] = '';
                    widget.onUpdateItem(widget.item);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Item marked as returned!')),
                    );
                    Navigator.pop(context);
                  },
                  child: Text('Mark as Returned'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
              if (widget.item['status'] == 'Available') ...[
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    widget.onDeleteItem(widget.item['id']);
                    Navigator.pop(context);
                  },
                  child: Text('Remove Item'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
