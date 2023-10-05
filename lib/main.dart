import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gpa_calculator/screens/CreateAccount.dart';
import 'package:gpa_calculator/screens/Degree.dart';
import 'package:gpa_calculator/screens/LoginPage.dart';
import 'package:gpa_calculator/screens/courses.dart';

void main() => runApp(const GpaCalculator());

class GpaCalculator extends StatelessWidget {
  const GpaCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "GPA Calculator",
        routes: <String, WidgetBuilder> {
        'createAccount': (context) => const CreateAccount(),
        'loginPage': (context) => const LoginPage(),
        'courses': (context) => const Courses(),
        'degree': (context) => const Degree(),
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6F61C0))
        ),
      home: const LoginPage(),
    );
  }

}