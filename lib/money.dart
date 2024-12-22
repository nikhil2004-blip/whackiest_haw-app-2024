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
  List<Map<String, dynamic>> members = [];  // List to store user data (id, nickname)
  String? _selectedPayer;
  List<String> _selectedContributors = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // Fetch all users from Firestore and store their ids and nicknames
  Future<void> _fetchUsers() async {
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      // Now mapping the data from Firestore to include both 'id' and 'nickname'
      members = usersSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'nickname': doc.data()['nickname'] ?? 'Unknown', // Get 'nickname' field
        };
      }).toList();
    });
  }

  // Add Expense and Update Balances
  Future<void> _addExpense() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedPayer == null || _selectedContributors.isEmpty) return;

    final double totalAmount = double.parse(_amountController.text);
    final double splitAmount = totalAmount / _selectedContributors.length;

    final expense = {
      'description': _descriptionController.text,
      'amount': totalAmount,
      'creator_id': user.uid,
      'payer': _selectedPayer,
      'contributors': _selectedContributors,
      'split_details': {
        for (var contributor in _selectedContributors)
          contributor: splitAmount,
      },
      'created_at': FieldValue.serverTimestamp(),
      'settled': false,
    };

    final expenseRef = await FirebaseFirestore.instance.collection('expenses').add(expense);

    // Update balances
    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (var contributor in _selectedContributors) {
      if (contributor == _selectedPayer) continue;

      final payerRef = FirebaseFirestore.instance.collection('users').doc(_selectedPayer);
      final contributorRef = FirebaseFirestore.instance.collection('users').doc(contributor);

      batch.update(payerRef, {
        'balances.$contributor': FieldValue.increment(splitAmount),
      });

      batch.update(contributorRef, {
        'balances.${_selectedPayer}': FieldValue.increment(-splitAmount),
      });
    }

    await batch.commit();

    _descriptionController.clear();
    _amountController.clear();
    setState(() {
      _selectedPayer = null;
      _selectedContributors.clear();
    });
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
            // Modified to handle displaying nicknames for selecting the payer
            DropdownButton<String>(
              value: _selectedPayer,
              hint: Text('Select Payer'),
              onChanged: (value) {
                setState(() {
                  _selectedPayer = value;
                });
              },
              items: members.map<DropdownMenuItem<String>>((member) {
                return DropdownMenuItem<String>(
                  value: member['id'], // Use member ID for selection
                  child: Text(member['nickname']), // Use 'nickname' for display
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            // Modified to display nicknames for contributors
            Wrap(
              spacing: 8.0,
              children: members.map((member) {
                return FilterChip(
                  label: Text(member['nickname']), // Use 'nickname' for display
                  selected: _selectedContributors.contains(member['id']),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedContributors.add(member['id']);
                      } else {
                        _selectedContributors.remove(member['id']);
                      }
                    });
                  },
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
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var userData = snapshot.data!;
                  var balances = userData['balances'] ?? {};

                  if (balances.isEmpty) {
                    return Center(child: Text("No balance data available"));
                  }

                  return ListView.builder(
                    itemCount: balances.keys.length,
                    itemBuilder: (context, index) {
                      String userId = balances.keys.elementAt(index);
                      double amount = balances[userId]?.toDouble() ?? 0.0;

                      // Find the nickname for the userId from the members list
                      String? userNickname = members.firstWhere((member) => member['id'] == userId)['nickname'];

                      return Card(
                        elevation: 5,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          title: Text(userNickname ?? 'Unknown'), // Display the nickname
                          subtitle: Text('Balance: ₹${amount.toStringAsFixed(2)}'),
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
