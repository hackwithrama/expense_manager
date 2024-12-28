import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:expense_manager/models/expense.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({super.key});

  static Route<Expense> route() => MaterialPageRoute(builder: (ctx) => const NewExpense());

  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  Category _selectedCategory = Category.travel;
  DateTime? _selectedDate;

  void _presentDatePicker() async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 1, now.month, now.day);
    final currentDate = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      currentDate: now,
      firstDate: initialDate,
      lastDate: currentDate,
    );

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final savedAmount = double.tryParse(_amountController.text)!;

      final url = Uri.https(dotenv.env['FIREBASE_API']!, 'expenses.json');
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'title': _nameController.text,
            'amount': savedAmount,
            'date': formatter.format(_selectedDate!),
            'category': _selectedCategory.name,
          }));
      final result = json.decode(response.body);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(
        Expense(
          id: result['name'],
          title: _nameController.text,
          amount: savedAmount,
          date: _selectedDate!,
          category: _selectedCategory,
        ),
      );
    }
  }

  void _resetExpense() {
    _formKey.currentState!.reset();
    _nameController.text = '';
    _amountController.text = '';
    _selectedDate = null;
    _selectedCategory = Category.travel;
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _amountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expense'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.cancel)),
        ],
      ),
      body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  maxLength: 20,
                  decoration: InputDecoration(
                    label: Text('Name'),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        maxLength: 10,
                        decoration: InputDecoration(
                          label: Text('Amount'),
                          prefix: Text('\$ '),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              double.tryParse(value) == null ||
                              double.tryParse(value) as double <= 0) {
                            return 'Amount is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Text(
                          _selectedDate == null ? 'No date selected' : formatter.format(_selectedDate!),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        IconButton(onPressed: _presentDatePicker, icon: Icon(Icons.calendar_month)),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Text(
                      'Select category',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Spacer(),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: _selectedCategory,
                        items: Category.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(
                              category.name,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                        onPressed: _resetExpense,
                        icon: Icon(Icons.restore),
                        label: Text(
                          'Reset',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        )),
                    Spacer(),
                    ElevatedButton.icon(
                        onPressed: _saveExpense,
                        icon: Icon(
                          Icons.save,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        label: Text(
                          'Save Expense',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        )),
                  ],
                )
              ],
            ),
          )),
    );
  }
}
