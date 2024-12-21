import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddItemScreen extends StatefulWidget {
  final String userId;

  AddItemScreen({required this.userId});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  Future<void> _addItem(Map<String, String> newItem) async {
    await FirebaseFirestore.instance.collection('items').add(newItem);
  }

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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newItem = {
                      'name': _nameController.text,
                      'status': 'Available',
                      'owner': widget.userId,
                      'borrower': '',
                      'room': '',
                    };
                    _addItem(newItem);
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

  UpdateItemScreen({required this.item, required this.userId});

  @override
  _UpdateItemScreenState createState() => _UpdateItemScreenState();
}

class _UpdateItemScreenState extends State<UpdateItemScreen> {
  final _borrowerController = TextEditingController();
  final _roomController = TextEditingController();

  Future<void> _updateItem(Map<String, dynamic> updatedItem) async {
    await FirebaseFirestore.instance
        .collection('items')
        .doc(widget.item['id'])
        .update(updatedItem);
  }

  Future<void> _deleteItem() async {
    await FirebaseFirestore.instance.collection('items').doc(widget.item['id']).delete();
  }

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
                    _updateItem(updatedItem);
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
                    _updateItem(updatedItem);
                    Navigator.pop(context);
                  },
                  child: Text('Mark as Returned'),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _deleteItem();
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
