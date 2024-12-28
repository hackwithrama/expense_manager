import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:expense_manager/screens/expense_list.dart';

final kColorScheme = ColorScheme.fromSeed(seedColor: const Color.fromARGB(1, 240, 248, 255));

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme().copyWith(
          titleLarge: TextStyle(
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            fontWeight: FontWeight.w500,
          ),
          bodyMedium: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        colorScheme: kColorScheme,
        appBarTheme: AppBarTheme().copyWith(
          backgroundColor: kColorScheme.primary,
          foregroundColor: kColorScheme.onPrimary,
        ),
        cardTheme: CardThemeData().copyWith(
          color: kColorScheme.primaryContainer,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        ),
        iconTheme: IconThemeData().copyWith(
          color: kColorScheme.secondary,
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: kColorScheme.primary,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kColorScheme.primary,
            foregroundColor: kColorScheme.onPrimary,
          ),
        ),
      ),
      home: ExpenseList(),
    );
  }
}
