import 'package:expense_manager/widgets/expense_item.dart';
import 'package:flutter/material.dart';

import 'package:expense_manager/models/expense.dart';

class ExpenseList extends StatefulWidget {
  const ExpenseList({super.key});

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  final List<Expense> _registeredExpenses = [
    Expense(title: 'Flight Ticket', amount: 200, date: DateTime.now(), category: Category.travel),
    Expense(title: 'Dinner', amount: 50, date: DateTime.now(), category: Category.food),
    Expense(title: 'Life Insurance', amount: 100.75, date: DateTime.now(), category: Category.insurance)
  ];

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Manager'),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.add_task))],
      ),
      body: ListView.builder(
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
      ),
    );
  }
}