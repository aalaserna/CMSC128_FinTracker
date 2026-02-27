# Creating the App 

>> flutter clean                                                                       
>> flutter pub get
>> flutter build apk --debug

>> flutter clean
>> flutter pub get
>> flutter build apk --release  
                                                       
>> adb install -r android/app/build/outputs/flutter-apk/app-release.apk


# CMSC128 FinTracker – MVC Project Structure

Authors:
Andrea Laserna
Sam Lansoy
Marinelle Joan Tambolero
Michaela Borces
Christel Hope Ong
Sophe Mae Dela Cruz

## Overview

This document shows how the **FinTracker** Flutter application is organized using the **MVC (Model–View–Controller)** architectural pattern, adapted from the FERN-MVC structure pattern.

---

## High-Level MVC Architecture

```
Flutter App (FinTracker)
├── Models          # Data structures, database logic
├── Views           # UI screens and pages
└── Controllers     # Business logic, state management, data operations
```

---

## Current Project Structure (As-Is)

```
CMSC128_FinTracker/
├── lib/
│   ├── main.dart                          # Entry point
│   │
│   ├── database/
│   │   └── db_helper.dart                 # Database operations (SQLite)
│   │
│   ├── pages/
│   │   ├── expense_model.dart             # Model: Expense data structure
│   │   ├── homepage.dart                  # View: Main screen
│   │   ├── add_expense.dart               # View: Add expense form
│   │   ├── summary.dart                   # View: Summary/Reports
│   │   ├── customizations.dart            # View: Settings
│   │   ├── profile.dart                   # View: User profile
│   │   └── landing.dart                   # View: Landing/splash screen
│   │
│   └── utils/
│       └── notification_helper.dart       # Utility: Notifications
│
├── android/                               # Android platform code
├── ios/                                   # iOS platform code
├── web/                                   # Web platform code
├── windows/                               # Windows platform code
├── linux/                                 # Linux platform code
├── macos/                                 # macOS platform code
│
└── pubspec.yaml                           # Package dependencies
```

---

## MVC Mapping: Current Structure

### **MODEL** – Data & Business Rules

| Current Location | Component | Responsibility |
|------------------|-----------|-----------------|
| `lib/database/db_helper.dart` | **DBHelper** | Database initialization, CRUD operations |
| `lib/pages/expense_model.dart` | **Expense** class | Data structure for expenses (toMap, fromMap conversions) |

**What it does:**
- Manages SQLite database connection
- Stores and retrieves expense data
- Defines data schema and validation rules

---

### **VIEW** – User Interface

| Current Location | Component | Responsibility |
|------------------|-----------|-----------------|
| `lib/pages/landing.dart` | **LandingPage** | Splash/onboarding screen |
| `lib/pages/homepage.dart` | **HomePage** | Main dashboard, expense list view |
| `lib/pages/add_expense.dart` | **AddExpensePage** | Form for creating/updating expenses |
| `lib/pages/summary.dart` | **SummaryPage** | Reports and analytics view |
| `lib/pages/customizations.dart` | **CustomizationsPage** | User preferences/settings |
| `lib/pages/profile.dart` | **ProfilePage** | User profile information |

**What it does:**
- Displays UI elements (buttons, forms, lists)
- Collects user input
- Shows status and information to users
- Calls Controllers to process user actions

---

### **CONTROLLER** – Business Logic & State Management

| Current Location | Component | Responsibility |
|------------------|-----------|-----------------|
| Scattered in `pages/` | Business logic in page widgets | Handles expenses loading, filtering, data passing |
| `lib/utils/notification_helper.dart` | **NotificationHelper** | Triggers notifications |

**Issues Identified:**
- Business logic is currently mixed within View pages
- No dedicated service/controller layer
- State management could be better organized

---

## Future Project Structure

For better organization and separation of concerns, the project will be restructured as follows:

```
CMSC128_FinTracker/
├── lib/
│   ├── main.dart                          # Entry point
│   │
│   ├── models/                            # MODEL LAYER
│   │   ├── expense.dart                   # Expense data class
│   │   └── user.dart                      # User profile data 
│   │
│   ├── views/                             # VIEW LAYER
│   │   ├── screens/
│   │   │   ├── landing_screen.dart
│   │   │   ├── home_screen.dart
│   │   │   ├── add_expense_screen.dart
│   │   │   ├── summary_screen.dart
│   │   │   ├── customizations_screen.dart
│   │   │   └── profile_screen.dart
│   │   │
│   │   └── widgets/
│   │       ├── expense_item.dart          # Reusable expense list item
│   │       ├── bottom_nav_bar.dart        # Navigation widget
│   │       └── expense_form.dart          # Reusable form component
│   │
│   ├── controllers/                       # CONTROLLER LAYER
│   │   ├── expense_controller.dart        # Business logic for expenses
│   │   ├── user_controller.dart           # Business logic for user data
│   │   └── notification_controller.dart   # Notification handling
│   │
│   ├── services/                          # Service/Helper layer
│   │   ├── database_service.dart          # Database operations wrapper
│   │   ├── notification_service.dart      # Notification service
│   │   └── storage_service.dart           # SharedPreferences wrapper
│   │
│   └── config/                            # Configuration
│       ├── constants.dart                 # App-wide constants
│       └── theme.dart                     # Theme configuration
│
├── android/                               # Android platform
├── ios/                                   # iOS platform
├── web/                                   # Web platform
├── windows/                               # Windows platform
├── linux/                                 # Linux platform
├── macos/                                 # macOS platform
│
└── pubspec.yaml
```

---

## MVC Mapping: Future Project Structure

### **MODEL** ✓

```
lib/models/
├── expense.dart       # Expense data model with toMap() and fromMap()
└── user.dart          # User/Profile data model
```

**Responsibility:**
- Define data structures
- Implement serialization/deserialization (toMap, fromMap, toJson)
- Data validation rules
- NO database calls, NO UI logic
---

### **VIEW** ✓

```
lib/views/
├── screens/
│   ├── landing_screen.dart
│   ├── home_screen.dart
│   ├── add_expense_screen.dart
│   └── summary_screen.dart
│
└── widgets/
    ├── expense_item.dart
    ├── expense_form.dart
    └── bottom_nav_bar.dart
```

**Responsibility:**
- Build UI layouts
- Respond to user interactions
- Call Controllers to process actions
- Update UI based on Controller responses
- NO business logic, NO database calls

---

### **CONTROLLER** ✓

```
lib/controllers/
├── expense_controller.dart     # Manages expense CRUD operations
├── user_controller.dart        # Manages user data
└── notification_controller.dart # Manages notifications
```

**Responsibility:**
- Implement business logic
- Orchestrate between Views and Models
- Handle data validation and processing
- Call Services for database/storage operations
- Return data to Views for display

---

## Example Flow Comparison

### Current (Problematic):
```
View (HomePage) 
  ↓ (mixture of UI + business logic)
  ├→ Directly calls DBHelper
  ├→ Manages state with static variables
  └→ Performs filtering and calculations
```

### Future flow:
```
View (HomeScreen) 
  ↓ (user interaction)
  → Controller (ExpenseController)
    ↓
    → Service (DatabaseService)
      ↓
      → Model (Expense class)
        ↓
        SQLite Database
```

---

## Benefits of Future Structure

| Benefit | Current | Recommended |
|---------|---------|-------------|
| **Code Reusability** | Low (logic tied to pages) | High (controllers can be used by multiple views) |
| **Testing** | Difficult (mixed concerns) | Easy (isolated layers) |
| **Maintenance** | Hard (scattered logic) | Easy (clear organization) |
| **Scalability** | Limited | Excellent |
| **Unit Testing** | Almost impossible | Straightforward |
| **Code Clarity** | Confusing | Clear responsibilities |

---

## Migration Steps

To reorganize the project to follow this structure:

1. **Create new folder structure** under `lib/`
   - Move `expense_model.dart` → `models/expense.dart`
   - Create `controllers/` folder
   - Create `services/` folder
   - Rename `pages/` → `views/screens/`
   - Extract reusable widgets → `views/widgets/`

2. **Extract controllers**
   - Move database logic from pages to `controllers/expense_controller.dart`
   - Move notification logic to `controllers/notification_controller.dart`

3. **Create service layer**
   - Wrap `db_helper.dart` into `services/database_service.dart`
   - Wrap notification helper into `services/notification_service.dart`

4. **Update imports** in all files

5. **Add state management** (optional but recommended)
   - Consider using Provider, GetX, or Riverpod for better state management

---

## Summary

The **CMSC128 FinTracker** follows basic MVC principles but can be significantly improved by:

- ✓ **Keeping Models** (data classes and DB layer) clearly separated
- ✓ **Keeping Views** (UI screens and widgets) focused on display only  
- ✓ **Creating Controllers** to handle business logic and orchestration
- ✓ **Adding Services** for reusable infrastructure operations

This structure directly mirrors the **FERN-MVC pattern** shown in the sample, adapted for Flutter's mobile-first architecture.
