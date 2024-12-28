import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:expense_manager/models/expense.dart';
import 'package:expense_manager/screens/new_expense.dart';
import 'package:expense_manager/widgets/expense_item.dart';

final formatter = DateFormat.yMMMEd();

class ExpenseList extends StatefulWidget {
  const ExpenseList({super.key});

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  List<Expense> _registeredExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() async {
    final url = Uri.https(dotenv.env['FIREBASE_API']!, 'expenses.json');
    final response = await http.get(url);
    final Map<String, dynamic> result = json.decode(response.body);
    final List<Expense> loadedExpenses = [];
    for (final item in result.entries) {
      loadedExpenses.add(
        Expense(
          id: item.key,
          title: item.value['title'],
          amount: item.value['amount'],
          date: formatter.parse(item.value['date']),
          category: _categoryString(item.value['category']),
        ),
      );
    }
    setState(() {
      _registeredExpenses = loadedExpenses;
    });
  }

  Category _categoryString(String cat) {
    switch (cat) {
      case 'food':
        return Category.food;
      case 'travel':
        return Category.travel;
      case 'insurance':
        return Category.insurance;
      case 'luxary':
        return Category.luxary;
      case 'work':
        return Category.work;
      case 'tution':
        return Category.tution;
      default:
        throw Exception('Unknown Category : $cat');
    }
  }

  void _addExpense() async {
    Expense? getExpense = await Navigator.of(context).push<Expense>(NewExpense.route());

    if (getExpense == null) {
      return;
    }

    setState(() {
      _registeredExpenses.add(getExpense);
    });

    _loadExpenses();
  }

  void _removeExpense(Expense expense) {
    final expenseIndex = _registeredExpenses.indexOf(expense);

    setState(() {
      _registeredExpenses.remove(expense);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          action: SnackBarAction(
            textColor: Theme.of(context).colorScheme.onPrimary,
            backgroundColor: Theme.of(context).colorScheme.primary,
            label: 'UNDO',
            onPressed: () {
              setState(
                () {
                  _registeredExpenses.insert(expenseIndex, expense);
                },
              );
            },
          ),
          content: Row(
            children: [
              Icon(
                Icons.delete_forever,
                color: Colors.white,
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                'Expense Removed',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
              ),
            ],
          ),
          width: 350, // Width of the SnackBar.
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 5.0,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = Center(
      child: Text(
        'No Expense found, please add some.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );

    if (_registeredExpenses.isNotEmpty) {
      mainContent = ListView.builder(
        itemCount: _registeredExpenses.length,
        itemBuilder: (ctx, index) {
          return Dismissible(
            key: ValueKey(_registeredExpenses[index].id),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _removeExpense(_registeredExpenses[index]);
            },
            child: ExpenseItem(
              expense: _registeredExpenses[index],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Manager'),
        actions: [IconButton(onPressed: _addExpense, icon: Icon(Icons.add_task))],
      ),
      body: mainContent,
    );
  }
}
