import 'package:fins/database/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/foundation.dart';

import 'pages/homepage.dart';
import 'pages/summary.dart';
import 'pages/customizations.dart';
import 'pages/add_expense.dart'; 
import 'pages/profile.dart';
import 'pages/expense_model.dart';
import 'pages/landing.dart';
import 'utils/notification_helper.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; 

/*
===============
  ENTRY POINT
===============
*/ 
void main() async {
// 1. Critical first step
  WidgetsFlutterBinding.ensureInitialized(); 

  // 2. Initialize global timezone database
  tz.initializeTimeZones();

  String timeZoneName = 'Asia/Manila'; // Default starting point
  
  try {
    // Attempt to get the phone's timezone with a strict timeout
    final dynamic tzResult = await FlutterTimezone.getLocalTimezone()
        .timeout(const Duration(seconds: 1));
    
    timeZoneName = tzResult is String ? tzResult : tzResult.toString();
    
    // Safety check: Ensure the location exists in the database
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  } catch (e) {
    debugPrint("Timezone error: $e. Falling back to Manila.");
    // Force set to Manila if anything goes wrong
    tz.setLocalLocation(tz.getLocation('Asia/Manila'));
  }

  // 3. Match the name in your NotificationHelper
  // Ensure this is PUBLIC in notification_helper.dart
  // Ensures that engine is ready
  await NotificationHelper.ensureInitialized(); 

  if (!kIsWeb && (
    defaultTargetPlatform == TargetPlatform.windows ||
    defaultTargetPlatform == TargetPlatform.linux ||
    defaultTargetPlatform == TargetPlatform.macOS
  )) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

// Define the root widget, set the application theme, and entry screen (ExpenseHomePage)
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<bool> _showLandingFuture;

  @override
  void initState() {
    super.initState();
    // Cache first-run check so rebuilds don't restart the loading future.
    _showLandingFuture = _shouldShowLanding();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _showLandingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final showLanding = snapshot.data ?? true;
          if (showLanding) {
            return const LandingPage();
          }
          return const ExpenseHomePage();
        },
      ),
    );
  }
}

Future<bool> _shouldShowLanding() async {
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('hasCompletedOnboarding');
  if (onboardingComplete != null) {
    return !onboardingComplete;
  }

  // Backward compatibility with older app versions that only used `isFirstTime`.
  final isFirstTime = prefs.getBool('isFirstTime');
  if (isFirstTime != null) {
    return isFirstTime;
  }

  // Default to showing landing if no onboarding state has ever been stored.
  return true;
}

// Optional: developer helper to reset first-run state
Future<void> resetFirstRunForTesting() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isFirstTime', true);
  await prefs.setBool('hasCompletedOnboarding', false);
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
  // Track selected tab. 0 is 'Home'.
  int _bottomNavIndex = 0;

  // The master list is now static inside HomePage, so this list is removed:
  // final List<Expense> myExpenses = []; 

  final iconList = <IconData>[
    Icons.home,
    Icons.bar_chart,
    Icons.settings,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    // After first frame, schedule notifications if pending in prefs.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationHelper.scheduleFromPrefs();
    });
  }

  @override
  Widget build(BuildContext context) {
    // List of all the screens. HomePage must be instantiated with its static key
    // so its state (like the selected date) can be accessed from the FAB.
    final pages = <Widget>[
      HomePage(key: HomePage.homePageStateKey),
      const SummaryPage(),
      const CustomizationPage(),
      const ProfilePage(), 
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // Light blue/grey background from wireframe
      backgroundColor: const Color(0xFFF5F7FA), 
      body: pages[_bottomNavIndex],
      // Code for the add button
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(), // <--- Makes the button perfectly round
        onPressed: () async {
          // Check if we are in Home Page (index 0)
          if (_bottomNavIndex == 0) {
            // Get the currently selected date from the HomePage State via the GlobalKey
            final selectedDate = HomePage.homePageStateKey.currentState?.getSelectedDate() ?? DateTime.now();
            
            final newExpense = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddExpensePage(initialDate: selectedDate)),
            );

            if (newExpense != null && newExpense is Expense) {
              // Add database
              await DBHelper().insertExpense(newExpense);
              setState(() {
                // Add the new expense to the shared static list
                HomePage.expenses.add(newExpense); 
                // Switch back to the Home tab to see the change
                _bottomNavIndex = 0; 
              });
            }
          } else {
            /* If user presses the floating action btn while on another tab,
               Default to Home Page
             */
            setState(() => _bottomNavIndex = 0);
          }
        },
        backgroundColor: const Color(0xFF5E6C85), // Wireframe blue color
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      bottomNavigationBar: LayoutBuilder(
        builder: (BuildContext innerContext, BoxConstraints constraints) {
          return AnimatedBottomNavigationBar(
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
          );
        },
      ),
    );
  }
}