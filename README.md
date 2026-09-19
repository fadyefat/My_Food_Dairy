# 🥗 My Food Diary (يومي الغذائي)

**My Food Diary** is a clean, offline-first mobile app built with Flutter, designed to help users track their daily nutrition and meals with an elegant, modern UI.

The app has been refactored and built following **Feature-First Clean Architecture**, state management using **BLoC / Cubit**, dependency injection with **GetIt**, and centralized routing with **AppRouter**.

---

## 📱 Features

- 🍲 **Meal Logging & Tracking**:
  - Add, edit, and delete meals by category (*Breakfast, Lunch, Dinner, Snack*).
  - Record date, time, detailed descriptions, and meal photos.
- 📋 **Daily Log Screen**:
  - Filter meals by date with an interactive date picker.
  - Quick action popup menu for editing or deleting records.
- 📊 **Daily & Weekly Summaries**:
  - Instant dashboard calculating total daily meals and unique meal types.
  - Weekly analytics showing total weekly meals, daily averages, and most common meal types.
- 🔒 **Offline-First & Private**:
  - All data is securely stored locally using SQLite (`sqflite`). No internet or account registration required.
- 🎨 **Modern & Calming UI**:
  - Consistent design system with custom buttons, input fields, and theme colors (*soft green & vibrant orange*).

---

## 🏗️ Architecture & Engineering Patterns

The project follows the **Feature-First Clean Architecture** principles for scalability, testability, and separation of concerns:

```
lib/
├── core/
│   ├── database/          # SQLite DatabaseHelper instance
│   ├── di/                # Dependency Injection (GetIt service locator)
│   ├── routing/           # Named routes & central AppRouter with BlocProvider injection
│   ├── theme/             # AppColors & AppStyles centralized theme
│   └── widgets/           # Reusable custom UI components (CustomButton, CustomTextField)
│
├── features/
│   ├── home/              # Dashboard / Home Screen
│   │   └── presentation/ui/home_screen.dart
│   │
│   ├── meals/             # Meal management (Add & Edit)
│   │   ├── data/          # MealModel & MealRepo (Data layer)
│   │   └── presentation/  # MealCubit, MealState & MealScreen (UI layer)
│   │
│   ├── daily_log/         # Daily log overview
│   │   └── presentation/  # DailyLogCubit, DailyLogState & DailyLogScreen
│   │
│   └── summary/           # Daily & Weekly statistical summaries
│       └── presentation/  # SummaryCubit, SummaryState & Summary Screens
│
├── food_diary_app.dart     # MaterialApp entry with Route Generator
└── main.dart               # Service locator initialization and runApp
```

---

## 🚀 Key Improvements & What Was Learned

| Aspect | Previous Implementation | Modern Refactored Architecture |
| :--- | :--- | :--- |
| **Project Architecture** | Flat `Screens/` directory with tightly coupled code | **Feature-First Clean Architecture** (`core` + `features`) |
| **State Management** | Local `setState` mixing UI and business logic | **BLoC / Cubit** with distinct reactive states (*Loading, Success, Error*) |
| **Data Layer** | Screens querying SQLite directly | **Repository Pattern (`MealRepo`)** isolating data sources from UI |
| **Dependency Injection** | Instantiating objects manually across widgets | **Service Locator (`GetIt`)** for memory efficiency and loose coupling |
| **Navigation** | Hardcoded `MaterialPageRoute` calls in buttons | **Centralized Routing (`AppRouter`)** with route-level BLoC scoping |
| **Design System** | Duplicated styles and widget structures | **Reusable Widgets & Theming** (`AppColors`, `AppStyles`, `CustomButton`) |

---

## 🛠️ Tech Stack & Packages

- **Framework**: [Flutter](https://flutter.dev/) (Dart SDK `^3.7.2`)
- **State Management**: [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) (`^8.1.6`)
- **Dependency Injection**: [`get_it`](https://pub.dev/packages/get_it) (`^7.7.0`)
- **Local Database**: [`sqflite`](https://pub.dev/packages/sqflite) (`^2.3.0`) & [`path`](https://pub.dev/packages/path)
- **Date Formatting**: [`intl`](https://pub.dev/packages/intl) (`^0.19.0`)
- **Media & Images**: [`image_picker`](https://pub.dev/packages/image_picker) (`^1.0.4`)

---

## 📦 Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/fadyefat/My_Food_Dairy.git
   cd My_Food_Dairy
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

4. **Run analysis and tests**:
   ```bash
   flutter analyze
   flutter test
   ```
