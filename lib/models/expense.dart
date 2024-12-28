import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

const uuid = Uuid();
final formatter = DateFormat.yMMMEd();

enum Category {
  food,
  travel,
  insurance,
  luxary,
  work,
  tution,
}

const categoryIcons = {
  Category.food: Icons.lunch_dining,
  Category.insurance: Icons.safety_check,
  Category.luxary: Icons.spa,
  Category.travel: Icons.flight_takeoff,
  Category.tution: Icons.school,
  Category.work: Icons.work
};

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  Expense({required this.title, required this.amount, required this.date, required this.category}) : id = uuid.v4();

  String get formattedDate {
    return formatter.format(date);
  }
}
