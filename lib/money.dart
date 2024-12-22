import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MoneyLedgerPage extends StatefulWidget {
  @override
  _MoneyLedgerPageState createState() => _MoneyLedgerPageState();
}

class _MoneyLedgerPageState extends State<MoneyLedgerPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  List<String> members = ['User1', 'User2', 'User3']; // Replace with actual member list
  String? _selectedMember;

  @override
  void initState() {
    super.initState();
  }

  // Add Expense to Firestore
  Future<void> _addExpense() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final expense = {
      'description': _descriptionController.text,
      'amount': double.parse(_amountController.text),
      'creator_id': user.uid,
      'participants': [user.uid, _selectedMember], // Assuming user selected a member to split
      'split_details': {
        user.uid: double.parse(_amountController.text) / 2, // Split equally
        _selectedMember: double.parse(_amountController.text) / 2,
      },
      'created_at': FieldValue.serverTimestamp(),
      'settled': false,
    };

    await FirebaseFirestore.instance.collection('expenses').add(expense);

    // Optionally, update user expense list
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'expenses': FieldValue.arrayUnion([expense['id']]),
    });

    _descriptionController.clear();
    _amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Money Ledger', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF676F9D), // Soft purple-blue for app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Description Text Field
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Expense Description',
                labelStyle: TextStyle(color: Color(0xFF424769)), // Dark gray-blue for label
                fillColor: Color(0xFFF0F0F0), // Light gray for the background
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF676F9D)), // Soft purple-blue border
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF424769)), // Dark gray-blue border when focused
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Amount Text Field
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(color: Color(0xFF424769)), // Dark gray-blue for label
                fillColor: Color(0xFFF0F0F0), // Light gray for the background
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF676F9D)), // Soft purple-blue border
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF424769)), // Dark gray-blue border when focused
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Dropdown to select a member
            DropdownButton<String>(
              value: _selectedMember,
              hint: Text('Select Member to Split', style: TextStyle(color: Color(0xFF424769))),
              onChanged: (value) {
                setState(() {
                  _selectedMember = value;
                });
              },
              items: members.map<DropdownMenuItem<String>>((String member) {
                return DropdownMenuItem<String>(
                  value: member,
                  child: Text(member),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Add Expense Button
            ElevatedButton(
              onPressed: _addExpense,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF9B17A), // Soft orange color for the button
                foregroundColor: Colors.white, // White text on button
              ),
              child: Text('Add Expense'),
            ),
            SizedBox(height: 20),

            // Display Expenses List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('expenses').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var expenses = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      var expense = expenses[index].data() as Map<String, dynamic>;
                      return Card(
                        elevation: 5,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        color: Color(0xFF2D3250), // Darker gray-blue for card background
                        child: ListTile(
                          title: Text(expense['description'], style: TextStyle(color: Colors.white)),
                          subtitle: Text('Amount: ₹${expense['amount']}', style: TextStyle(color: Colors.white70)),
                          trailing: Text(
                            'Settled: ${expense['settled'] ? "Yes" : "No"}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
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
