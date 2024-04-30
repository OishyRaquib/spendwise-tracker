import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../const_config/color_config.dart';
import '../custom_buttons/rounded_blue_button.dart';

import '../../services/utils/database_manipulation/expense_mod.dart';

class AddExpenseModal extends StatefulWidget {
  const AddExpenseModal({Key? key}) : super(key: key);

  @override
  State<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<AddExpenseModal> {
  final TextEditingController amountController = TextEditingController();
  DateTime? selectedDate;
  String? selectedCategoryID;

  List<DropdownMenuItem<String>> buildDropdownItems(
      List<Map<String, dynamic>> categories) {
    return categories.map((category) {
      return DropdownMenuItem<String>(
        value: category['id'],
        child: Text(category['name']),
      );
    }).toList();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // void addExpense() async {
  //   double amount = double.tryParse(amountController.text.trim()) ?? 0.0;
  //   String? categoryID = selectedCategoryID;
  //
  //   if (amount > 0 && categoryID != null && selectedDate != null) {
  //     Timestamp date = Timestamp.fromDate(selectedDate!);
  //
  //     DocumentReference expenseRef = await FirebaseFirestore.instance
  //         .collection('Users')
  //         .doc(FirebaseAuth.instance.currentUser?.uid)
  //         .collection('expenses')
  //         .add({
  //       'amount': amount,
  //       'date': date,
  //       'categoryID': categoryID,
  //     });
  //
  //     await FirebaseFirestore.instance
  //         .collection('Users')
  //         .doc(FirebaseAuth.instance.currentUser?.uid)
  //         .collection('categories')
  //         .doc(categoryID)
  //         .update({
  //       'expenseID': FieldValue.arrayUnion([expenseRef.id]),
  //     });
  //
  //     amountController.clear();
  //     setState(() {
  //       selectedCategoryID = null;
  //       selectedDate = null;
  //     });
  //   }
  //
  // }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Expense'),
      surfaceTintColor: MyColor.powderBlue,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            InkWell(
              onTap: () => selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(selectedDate != null
                        ? DateFormat('dd, MMMM yyyy').format(selectedDate!)
                        : 'Select Date'),
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .collection('categories')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                List<Map<String, dynamic>> categories =
                    snapshot.data!.docs.map((doc) {
                  return {'id': doc.id, 'name': doc['name']};
                }).toList();
                return DropdownButtonFormField<String>(
                  value: selectedCategoryID,
                  onChanged: (String? value) {
                    setState(() {
                      selectedCategoryID = value;
                    });
                  },
                  items: buildDropdownItems(categories),
                  decoration: InputDecoration(labelText: 'Category'),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        RoundedBlueButton(
          onClick: () {
            addExpense(
              selectedCategoryID!,
              double.tryParse(amountController.text.trim()) ?? 0.0,
              selectedDate!,
            );
            Navigator.of(context).pop();
          },
          label: 'Add Expense',
          width: 65,
          backgroundColor: MyColor.yinminBlue,
        ),

      ],
    );
  }
}