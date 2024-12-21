import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _currentUser;
  late String _userId;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUser = user;
        _userId = user.uid;
      });
    }
  }

  Future<void> _addItem(Map<String, String> newItem) async {
    await _firestore.collection('items').add(newItem);
  }

  Future<void> _updateItem(Map<String, dynamic> updatedItem, String itemId) async {
    await _firestore.collection('items').doc(itemId).update(updatedItem);
  }

  Future<void> _deleteItem(String itemId) async {
    await _firestore.collection('items').doc(itemId).delete();
  }

  Future<List<Map<String, dynamic>>> _fetchItems() async {
    final snapshot = await _firestore.collection('items').get();
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc['name'],
        'status': doc['status'],
        'owner': doc['owner'],
        'borrower': doc['borrower'] ?? '',
        'room': doc['room'] ?? '',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Lending'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading items'));
          }

          final items = snapshot.data!;
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
                      userId: _userId,
                      onUpdateItem: _updateItem,
                      onDeleteItem: _deleteItem,
                    ),
                  ),
                ),
                child: ListTile(
                  title: Text(item['name']),
                  subtitle: Text(
                    'Status: ${item['status']}, Owner: ${item['owner']}, '
                        '${item['status'] == 'Borrowed' ? 'Borrower: ${item['borrower']}, Room: ${item['room']}' : ''}',
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentUser != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddItemScreen(
                  onAddItem: _addItem,
                  userId: _userId,
                ),
              ),
            );
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddItemScreen extends StatefulWidget {
  final Function(Map<String, String>) onAddItem;
  final String userId;

  AddItemScreen({required this.onAddItem, required this.userId});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ownerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Item'),
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
              TextFormField(
                controller: _ownerController,
                decoration: InputDecoration(labelText: 'Owner'),
                initialValue: widget.userId, // User ID is automatically the owner
                enabled: false, // Owner field should not be editable
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newItem = {
                      'name': _nameController.text,
                      'status': 'Available',  // Default status is 'Available'
                      'owner': widget.userId,
                      'borrower': '',
                      'room': '',
                    };
                    widget.onAddItem(newItem);
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
  final String userId;
  final Function(Map<String, dynamic>, String) onUpdateItem;
  final Function(String) onDeleteItem;

  UpdateItemScreen({required this.item, required this.userId, required this.onUpdateItem, required this.onDeleteItem});

  @override
  _UpdateItemScreenState createState() => _UpdateItemScreenState();
}

class _UpdateItemScreenState extends State<UpdateItemScreen> {
  final _borrowerController = TextEditingController();
  final _roomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item['status'] == 'Available') {
      _borrowerController.text = '';
      _roomController.text = '';
    } else {
      _borrowerController.text = widget.item['borrower'];
      _roomController.text = widget.item['room'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.item['owner'] == widget.userId;
    final isBorrowed = widget.item['status'] == 'Borrowed';

    return Scaffold(
      appBar: AppBar(
        title: Text('Update Item'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (widget.item['status'] == 'Available') ...[
              TextFormField(
                controller: _borrowerController,
                decoration: InputDecoration(labelText: 'Borrower Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the borrower name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _roomController,
                decoration: InputDecoration(labelText: 'Room'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the room';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_borrowerController.text.isNotEmpty && _roomController.text.isNotEmpty) {
                    final updatedItem = {
                      'borrower': _borrowerController.text,
                      'room': _roomController.text,
                      'status': 'Borrowed',
                    };
                    widget.onUpdateItem(updatedItem, widget.item['id']);
                    Navigator.pop(context);
                  }
                },
                child: Text('Borrow Item'),
              ),
            ],
            if (isBorrowed && isOwner) ...[
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    final updatedItem = {
                      'status': 'Available',
                      'borrower': '',
                      'room': '',
                    };
                    widget.onUpdateItem(updatedItem, widget.item['id']);
                    Navigator.pop(context);
                  },
                  child: Text('Mark as Returned'),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onDeleteItem(widget.item['id']);
                  Navigator.pop(context);
                },
                child: Text('Delete Item'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
