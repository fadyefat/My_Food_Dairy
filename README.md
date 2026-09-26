# 🥗 My Food Diary (يومي الغذائي)

**My Food Diary** is an offline-first nutrition and meal tracking mobile application built with Flutter. Designed with **Feature-First Clean Architecture**, **BLoC / Cubit** state management, and **100% automated test coverage** for business logic, it represents a production-grade portfolio project.

---

## 🚀 Key Features

- 🍲 **Comprehensive Meal Management**:
  - Log, edit, and delete meals with category tagging (*Breakfast, Lunch, Dinner, Snack*).
  - Capture meal photos, time, date, and detailed nutritional notes.
- 🔍 **Live Search & Dynamic Category Filters**:
  - Instant text search across all meal descriptions and details.
  - Filter chips to filter by category with zero latency and responsive empty states.
- 📊 **Interactive Charts & Data Visualizations** (`fl_chart`):
  - **Weekly Activity Bar Chart**: Interactive bar chart displaying meals logged per day with touch tooltips.
  - **Donut Distribution Pie Charts**: Visual breakdown of meal categories for both today and the week with interactive percentage badges and legends.
- 📄 **Export & Share PDF Reports** (`pdf` & `printing`):
  - Generate formatted multi-page PDF nutrition summaries with summary metric cards, timestamps, and detailed meal tables.
  - Export, print, or share reports directly with nutritionists, doctors, or trainers.
- 🌓 **Light & Dark Theme Modes**:
  - Built-in theme switcher with smooth transitions.
  - User theme preferences persisted locally using `SharedPreferences`.
- 🔒 **Offline-First & Privacy Focused**:
  - Powered by local SQLite (`sqflite`). All data and meal photos remain on-device with zero external tracking.
- 🧪 **Comprehensive Automated Testing**:
  - Unit and BLoC tests covering all Cubits, State transitions, and Repositories using `bloc_test` and `mocktail`.

---

## 🏗️ Architecture & Engineering Patterns

The project strictly adheres to **Feature-First Clean Architecture** principles:

```
lib/
├── core/
│   ├── database/          # SQLite DatabaseHelper instance (CRUD & Analytics queries)
│   ├── di/                # Dependency Injection (GetIt service locator)
│   ├── routing/           # Named routes & central AppRouter with route-level BLoC scoping
│   ├── theme/             # Light & Dark color systems (AppColors, AppStyles) & ThemeCubit
│   ├── utils/             # PdfExportHelper (A4 nutrition report layout & generator)
│   └── widgets/           # Reusable UI components (CustomButton, CustomTextField)
│
├── features/
│   ├── home/              # Dashboard / Home Screen with theme switcher & quick actions
│   │   └── presentation/ui/home_screen.dart
│   │
│   ├── meals/             # Meal entry & modification
│   │   ├── data/          # MealModel & MealRepo (Data layer)
│   │   └── presentation/  # MealCubit, MealState & MealScreen (UI layer)
│   │
│   ├── daily_log/         # Daily log overview with Live Search & Category Filter Chips
│   │   └── presentation/  # DailyLogCubit, DailyLogState & DailyLogScreen
│   │
│   └── summary/           # Daily & Weekly statistical summaries with interactive charts & PDF export
│       └── presentation/  # SummaryCubit, SummaryState & Summary Screens
│
├── food_diary_app.dart     # MaterialApp entry with ThemeCubit binding & Route Generator
└── main.dart               # Service locator initialization and runApp
```

---

## 🧪 Testing & Code Quality

The repository includes a complete test suite:
- **`test/features/meals/meal_cubit_test.dart`**: Tests meal insertion, update, validation, and error states.
- **`test/features/daily_log/daily_log_cubit_test.dart`**: Tests meal fetching, real-time search queries, category filters, and deletion.
- **`test/features/summary/summary_cubit_test.dart`**: Tests daily metrics calculation, weekly statistics, and failure fallbacks.
- **`test/widget_test.dart`**: Smoke test validating app startup and route resolution.

To run the test suite:
```bash
flutter test
```

To run static analysis:
```bash
flutter analyze
```

---

## 🛠️ Tech Stack & Packages

| Category | Technology / Package |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev/) (Dart 3.7.2 • Flutter 3.29.3) |
| **State Management** | [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) (`^8.1.6`) |
| **Dependency Injection** | [`get_it`](https://pub.dev/packages/get_it) (`^7.7.0`) |
| **Local Database** | [`sqflite`](https://pub.dev/packages/sqflite) (`^2.3.0`) & [`path`](https://pub.dev/packages/path) |
| **Interactive Charts** | [`fl_chart`](https://pub.dev/packages/fl_chart) (`^0.69.0`) |
| **PDF Generation & Export** | [`pdf`](https://pub.dev/packages/pdf) (`^3.11.3`) & [`printing`](https://pub.dev/packages/printing) (`^5.14.3`) |
| **Preferences Storage** | [`shared_preferences`](https://pub.dev/packages/shared_preferences) (`^2.5.3`) |
| **Media & Images** | [`image_picker`](https://pub.dev/packages/image_picker) (`^1.0.4`) |
| **Date & Formatting** | [`intl`](https://pub.dev/packages/intl) (`^0.19.0`) |
| **Unit & BLoC Testing** | [`bloc_test`](https://pub.dev/packages/bloc_test) & [`mocktail`](https://pub.dev/packages/mocktail) |

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

3. **Run tests**:
   ```bash
   flutter test
   ```

4. **Launch the application**:
   ```bash
   flutter run
   ```
