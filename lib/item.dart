import 'package:flutter/material.dart';

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
  final List<Map<String, String>> items = [
    {'id': '1', 'name': 'Laptop', 'status': 'Available', 'owner': 'Alice', 'borrower': '', 'room': ''},
    {'id': '2', 'name': 'Projector', 'status': 'Borrowed', 'owner': 'Bob', 'borrower': 'John', 'room': '101'},
    {'id': '3', 'name': 'Camera', 'status': 'Available', 'owner': 'Charlie', 'borrower': '', 'room': ''},
  ];

  void _addItem(Map<String, String> newItem) {
    setState(() {
      items.add(newItem);
    });
  }

  void _updateItem(Map<String, String> updatedItem) {
    setState(() {
      final index = items.indexWhere((item) => item['id'] == updatedItem['id']);
      if (index != -1) {
        items[index] = updatedItem;
      }
    });
  }

  void _deleteItem(String itemId) {
    setState(() {
      items.removeWhere((item) => item['id'] == itemId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Lending'),
      ),
      body: ListView.builder(
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
  final Function(Map<String, String>) onAddItem;

  AddItemScreen({required this.onAddItem});

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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the owner name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newItem = {
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'name': _nameController.text,
                      'owner': _ownerController.text,
                      'status': 'Available',  // Default status is 'Available'
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
  final Map<String, String> item;
  final Function(Map<String, String>) onUpdateItem;
  final Function(String) onDeleteItem;

  UpdateItemScreen({required this.item, required this.onUpdateItem, required this.onDeleteItem});

  @override
  _UpdateItemScreenState createState() => _UpdateItemScreenState();
}

class _UpdateItemScreenState extends State<UpdateItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _borrowerController = TextEditingController();
  final _roomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _borrowerController.text = widget.item['borrower'] ?? '';
    _roomController.text = widget.item['room'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Item'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Show Borrower and Room Fields when Item is Available
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
              ],
              SizedBox(height: 20),
              // Only show the Update button if the item is available
              if (widget.item['status'] == 'Available') ...[
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        widget.item['borrower'] = _borrowerController.text;
                        widget.item['room'] = _roomController.text;
                        widget.item['status'] = 'Borrowed';
                      });
                      widget.onUpdateItem(widget.item);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Item updated successfully!')),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Update Item'),
                ),
              ],
              SizedBox(height: 20),
              // Centered "Mark as Returned" button when the item is borrowed
              if (widget.item['status'] == 'Borrowed') ...[
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        widget.item['status'] = 'Available';
                        widget.item['borrower'] = '';
                        widget.item['room'] = '';
                      });
                      widget.onUpdateItem(widget.item);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Item marked as returned!')),
                      );
                      Navigator.pop(context);
                    },
                    child: Text('Mark as Returned'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
              ],
              // Show "Delete Item" button only when the item is returned
              if (widget.item['status'] == 'Available') ...[
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onDeleteItem(widget.item['id']!);
                      Navigator.pop(context);
                    },
                    child: Text('Delete Item'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}