import 'package:fins/database/db_helper.dart';
import 'package:fins/themes/constants/app_colors.dart';
import 'package:fins/themes/logic/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/foundation.dart';

import 'pages/homepage.dart';
import 'pages/monthly_view.dart';
import 'pages/summary.dart';
import 'pages/customizations.dart';
import 'pages/expenses/add/add_expense_page.dart'; 
import 'pages/finance_insights.dart';
import 'pages/expense_model.dart';
import 'pages/landing.dart';
import 'utils/notification_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:fins/themes/logic/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  tz_data.initializeTimeZones();
  String timeZoneName = 'Asia/Manila'; // Default starting point
  
  try {
    // Attempt to get the phone's timezone with a strict timeout
    final dynamic tzResult = await FlutterTimezone.getLocalTimezone()
        .timeout(const Duration(seconds: 1));
    final raw = tzResult is String ? tzResult : tzResult.toString();
    final match = RegExp(r'TimezoneInfo\(([^,)]+)').firstMatch(raw);
    timeZoneName = match != null ? match.group(1)!.trim() : raw.trim();

    // Safety check: Ensure the location exists in the database
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  } catch (e) {
    debugPrint("Timezone sync failed, using Asia/Manila fallback: $e");
    // Force set to Manila if anything goes wrong
    tz.setLocalLocation(tz.getLocation('Asia/Manila'));
  }

  try {
    await NotificationHelper.ensureInitialized();
  } catch (e) {
    debugPrint("NotificationHelper init failed: $e");
  }

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
    return ValueListenableBuilder<AppThemeType>(
      valueListenable: ThemeController.notifier,
      builder: (context, themeType, _){
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: getTheme(themeType), // integrate this with your shared preferences for dynamic theme
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
    );
  }
}

Future<bool> _shouldShowLanding() async {
  // final prefs = await SharedPreferences.getInstance();
  // final onboardingComplete = prefs.getBool('hasCompletedOnboarding');
  // if (onboardingComplete != null) {
  //   return !onboardingComplete;
  // }

  // // Backward compatibility with older app versions that only used `isFirstTime`.
  // final isFirstTime = prefs.getBool('isFirstTime');
  // if (isFirstTime != null) {
  //   return isFirstTime;
  // }

  // Default to showing landing if no onboarding state has ever been stored.
  return true;
}

// Optional: developer helper to reset first-run state
Future<void> resetFirstRunForTesting() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isFirstTime', true);
  await prefs.setBool('hasCompletedOnboarding', false);
}

// Stateful because it needs to track which tab is currently selected
class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({super.key});

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  // Track selected tab. 0 is 'Home'.
  int _bottomNavIndex = 0;

  // Whether the monthly view overlay is visible.
  bool _showMonthlyOverlay = false;

  void _openMonthlyOverlay() => setState(() => _showMonthlyOverlay = true);
  void _closeMonthlyOverlay() => setState(() => _showMonthlyOverlay = false);

  final iconList = <IconData>[
    Icons.home,
    Icons.settings,     // budget & customizations (Now Settings tab)
    Icons.bar_chart,    // Summary
    Icons.lightbulb,    // financial insight
  ];

  @override
  void initState() {
    super.initState();
    // After first frame, schedule notifications if pending in prefs.
    // Guarded so a LateInitializationError from the plugin never crashes the UI.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await NotificationHelper.scheduleFromPrefs();
      } catch (e) {
        debugPrint("scheduleFromPrefs failed: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // List of all the screens. HomePage must be instantiated with its static key
    // so its state (like the selected date) can be accessed from the FAB.
    // Restore original 4-tab layout. Monthly view will be shown as an
    // in-scaffold overlay so the bottom navigation remains visible.

    final pages = <Widget>[
      HomePage(
        key: HomePage.homePageStateKey,
        onSummaryTap: () {
          setState(() {
            _bottomNavIndex = 2; // Summary index
          });
        },
        onOpenMonthlyView: _openMonthlyOverlay,
      ),
      const CustomizationPage(),  // budget & expense settings (Now Settings tab)
      const SummaryPage(),
      const ProfilePage(),       // placeholder — will become AI page (Financial Insight)
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      // JAS: i removed the scaffold bg here since the color scheme from app themes is now applied here automatically
      body: Stack(
        children: [
          pages[_bottomNavIndex],
          if (_showMonthlyOverlay)
            Positioned.fill(
              // child: MonthlyViewPage(onClose: _closeMonthlyOverlay),
              child: MonthlyViewPage(
                key: MonthlyViewPage.monthlyViewStateKey,
                onClose: _closeMonthlyOverlay
            ),
            ),
        ],
      ),
      
      // Code for the add button
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: context.primary,
        onPressed: () async {
          DateTime selectedDate;
  
          if (_showMonthlyOverlay) {
            selectedDate = MonthlyViewPage.monthlyViewStateKey.currentState?.getSelectedDate() ?? DateTime.now();
          } else {
            selectedDate = HomePage.homePageStateKey.currentState?.getSelectedDate() ?? DateTime.now();
          }
          final newExpense = await showDialog<Expense>(
            context: context,
            barrierDismissible: false,
            builder: (_) => AddExpensePage(initialDate: selectedDate),
          );

          if (newExpense != null) {
            await DBHelper().insertExpense(newExpense);
            
            setState(() {
              HomePage.expenses.add(newExpense); 
              if (_showMonthlyOverlay) {
                MonthlyViewPage.monthlyViewStateKey.currentState?.loadAllExpenses();
              } else if (_bottomNavIndex != 0) {
                _bottomNavIndex = 0; 
              }
            });
            HomePage.homePageStateKey.currentState?.loadExpenses();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Expense "${newExpense.name}" added successfully.')),
            );
          }
        },
        child: Icon(Icons.add, color: context.surface),
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
            backgroundColor: (() {
              final t = ThemeController.notifier.value;
              if (t == AppThemeType.blue) return AppColors.blue.container;
              if (t == AppThemeType.pink) return AppColors.pink.container;
              if (t == AppThemeType.yellow) return AppColors.yellow.container;
              return AppColors.blue.container;
            })(),
            activeColor: context.onPrimary,
            inactiveColor: context.onPrimary.withValues(alpha: 0.3),
            // Update the state (selected index) when tapping a tab
            onTap: (index) {
              setState(() {
                _bottomNavIndex = index;
                _showMonthlyOverlay = false; // hide overlay when switching tabs
              });
            },
          );
        },
      ),
    );
  }
}