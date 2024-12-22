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
        title: Text('Expense Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Expense Description'),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount'),
            ),
            DropdownButton<String>(
              value: _selectedMember,
              hint: Text('Select Member to Split'),
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
            ElevatedButton(
              onPressed: _addExpense,
              child: Text('Add Expense'),
            ),
            SizedBox(height: 20),
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
                        child: ListTile(
                          title: Text(expense['description']),
                          subtitle: Text('Amount: ₹${expense['amount']}'),
                          trailing: Text('Settled: ${expense['settled'] ? "Yes" : "No"}'),
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