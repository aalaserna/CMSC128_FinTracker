import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

import 'pages/homepage.dart';
import 'pages/summary.dart';
import 'pages/customizations.dart';
import 'pages/add_expense.dart'; 
import 'pages/profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ExpenseHomePage(),
    );
  }
}

class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({super.key});

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  int _bottomNavIndex = 1;

  final iconList = <IconData>[
    Icons.bar_chart,
    Icons.home,
    Icons.settings,
    Icons.person, // dummy
  ];

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const SummaryPage(),
      HomePage(),
      const CustomizationPage(),
      const ProfilePage(), // dummy
    ];

    return Scaffold(
      body: pages[_bottomNavIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newExpense = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpensePage()),
          );

          if (newExpense != null) {
            setState(() {
              HomePage.expenses.add(newExpense); // rebuild HomePage
              _bottomNavIndex = 1; // switch to Home tab
            });
          }
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) {
          // if (index == 3) return;
          setState(() => _bottomNavIndex = index);
        },
      ),
    );
  }
}
