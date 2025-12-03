import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

import 'pages/homepage.dart';
import 'pages/summary.dart';
import 'pages/customizations.dart';
import 'pages/add_expense.dart'; 
import 'pages/profile.dart';
import 'pages/expense_model.dart';

/*
===============
  ENTRY POINT
===============
*/ 
void main() {
  runApp(const MyApp());
}

// Define the root widget, set the application theme, and entry screen (ExpenseHomePage)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ExpenseHomePage(),
    );
  }
}

/*
===============
  Main Screen
===============
*/ 

// Stateful because it needs to track which tab is currently selected
class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({super.key});

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  // Track selected tab: 1 means Home Tab is selected first (index 1 is 'home')
  int _bottomNavIndex = 1;

  // The master list is now static inside HomePage, so this list is removed:
  // final List<Expense> myExpenses = []; 

  final iconList = <IconData>[
    Icons.bar_chart,
    Icons.home,
    Icons.settings,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    // List of all the screens. HomePage must be instantiated with its static key
    // so its state (like the selected date) can be accessed from the FAB.
    final pages = <Widget>[
      const SummaryPage(),
      HomePage(key: HomePage.homePageStateKey),
      const CustomizationPage(),
      const ProfilePage(), 
    ];

    return Scaffold(
      // Light blue/grey background from wireframe
      backgroundColor: const Color(0xFFF5F7FA), 
      body: pages[_bottomNavIndex],
      // Code for the add button
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(), // <--- Makes the button perfectly round
        onPressed: () async {
          // Check if we are in Home Page
          if (_bottomNavIndex == 1) {
            // Get the currently selected date from the HomePage State via the GlobalKey
            final selectedDate = HomePage.homePageStateKey.currentState?.getSelectedDate() ?? DateTime.now();
            
            final newExpense = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddExpensePage(initialDate: selectedDate)),
            );

            if (newExpense != null && newExpense is Expense) {
              setState(() {
                // Add the new expense to the shared static list
                HomePage.expenses.add(newExpense); 
                // Switch back to the Home tab to see the change
                _bottomNavIndex = 1; 
              });
            }
          } else {
            /* If user presses the floating action btn while on another tab,
               Default to Home Page
             */
            setState(() => _bottomNavIndex = 1);
          }
        },
        backgroundColor: const Color(0xFF5E6C85), // Wireframe blue color
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        activeColor: const Color(0xFF5E6C85),
        inactiveColor: Colors.grey,
        // Update the state (selected index) when tapping a tab
        onTap: (index) {
          setState(() => _bottomNavIndex = index);
        },
      ),
    );
  }
}