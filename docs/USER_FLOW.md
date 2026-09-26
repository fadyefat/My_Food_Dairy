# User Flow & Information Architecture
## Project Name: My Food Diary Mobile Application
**Document Version:** 1.0.0  
**Status:** Approved  
**Author:** Mobile Engineering Team  
**Date:** September 2026  

---

## 1. Information Architecture (Site Map)

The application structure follows a clear hierarchical model designed for minimal taps and instant navigation:

```mermaid
graph TD
    AppLaunch[Application Launch] --> CheckSession{Has Stored Session?}
    CheckSession -->|No| LoginScreen[Login Screen]
    CheckSession -->|Yes| HomeScreen[Home Screen]

    LoginScreen -->|Tap Register| RegisterScreen[Register Screen]
    LoginScreen -->|Tap Continue as Guest| HomeScreen
    LoginScreen -->|Sign In Success| HomeScreen
    RegisterScreen -->|Sign Up Success| HomeScreen

    HomeScreen -->|Tap Floating Action Button| AddMealScreen[Add Meal Screen]
    HomeScreen -->|Tap Category Card| AddMealWithCategory[Add Meal Screen (Pre-selected)]
    HomeScreen -->|Tap Today's Meals Card| DailyLogScreen[Daily Log Screen (Today)]
    HomeScreen -->|Tap Today's Breakdown| DailySummaryScreen[Daily Summary Screen]
    HomeScreen -->|Tap Weekly Progress| WeeklySummaryScreen[Weekly Summary Screen]
    HomeScreen -->|Tap Theme Toggle Icon| ToggleTheme[Switch Light/Dark Mode]
    HomeScreen -->|Tap Sign Out Icon| LoginScreen

    DailyLogScreen -->|Tap Meal Item| EditMealScreen[Edit Meal Screen]
    DailyLogScreen -->|Tap Calendar Icon| DatePicker[Select Date Modal]
    DailyLogScreen -->|Type Query| FilterList[Live Filtered Meal List]
    DailyLogScreen -->|Select Category Chip| FilterCategory[Category Filtered Meal List]
    DailyLogScreen -->|Tap Export PDF| ShareSheet[Native PDF Share Sheet]

    DailySummaryScreen -->|Tap Export PDF| ShareSheet
    WeeklySummaryScreen -->|Tap Export PDF| ShareSheet
```

---

## 2. Global State Machine

The following state diagram specifies the global authentication and session lifecycle:

```mermaid
stateDiagram-v2
    [*] --> Initializing
    Initializing --> CheckingSession : setupServiceLocator()
    CheckingSession --> Unauthenticated : No valid session found
    CheckingSession --> Authenticated : Valid session restored

    Unauthenticated --> Authenticating : Tap Login / Register / Guest
    Authenticating --> Authenticated : Firebase / Local session created
    Authenticating --> AuthError : Validation or Firebase error
    AuthError --> Unauthenticated : Dismiss error alert

    Authenticated --> ActiveSession : Load Home Screen
    ActiveSession --> ThemeToggled : Switch Light / Dark
    ActiveSession --> MealOperation : Add / Edit / Delete Meal
    MealOperation --> ActiveSession : Local SQLite update + Background Cloud Sync
    ActiveSession --> LoggingOut : Tap Sign Out
    LoggingOut --> Unauthenticated : Clear session in SharedPreferences & Firebase
```

---

## 3. End-to-End User Flow Scenarios

### Flow 1: User Onboarding & Authentication

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant UI as Login / Register UI
    participant Cubit as AuthCubit
    participant Repo as AuthRepo
    participant FB as Firebase Auth & Firestore
    participant Local as SharedPreferences

    alt Standard Login
        User->>UI: Enter Email & Password, tap "Login"
        UI->>Cubit: signIn(email, password)
        Cubit->>Repo: signInWithEmail(email, password)
        Repo->>FB: signInWithEmailAndPassword()
        FB-->>Repo: UserCredential & UID
        Repo->>Local: Cache user session JSON
        Repo-->>Cubit: UserModel
        Cubit-->>UI: Authenticated(user)
        UI-->>User: Navigate to HomeScreen
    else Continue as Guest
        User->>UI: Tap "Continue as Guest"
        UI->>Cubit: signInAsGuest()
        Cubit->>Repo: signInAsGuest()
        Repo->>FB: signInAnonymously()
        Repo->>Local: Cache guest session JSON
        Repo-->>Cubit: UserModel(isGuest: true)
        Cubit-->>UI: Authenticated(user)
        UI-->>User: Navigate to HomeScreen
    end
```

---

### Flow 2: Meal Creation & Visual Documentation

```mermaid
flowchart TD
    Start([User taps Add Meal Button]) --> Screen[Open AddMealScreen]
    Screen --> CategorySelect{Select Category}
    CategorySelect -->|Default / Chosen| Breakfast["Breakfast"]
    CategorySelect --> Lunch["Lunch"]
    CategorySelect --> Dinner["Dinner"]
    CategorySelect --> Snack["Snack"]

    Breakfast & Lunch & Dinner & Snack --> InputDetails[Enter Meal Description]
    InputDetails --> SelectMedia{Attach Photo?}
    SelectMedia -->|Camera| TakePhoto[Capture camera image]
    SelectMedia -->|Gallery| PickPhoto[Select image from gallery]
    SelectMedia -->|Skip| ConfirmDate[Confirm Date & Time]

    TakePhoto & PickPhoto --> ConfirmDate
    ConfirmDate --> TapSave[Tap 'Save Meal' Button]
    
    TapSave --> Validate{Is Description Valid?}
    Validate -->|No| ShowError[Display 'Please enter meal details' Banner]
    Validate -->|Yes| InsertLocal[Insert into Local SQLite Database]

    InsertLocal --> ImmediateSuccess[Close Screen & Show Success Snackbar]
    InsertLocal --> BackgroundSync{Is Network & Auth Available?}
    BackgroundSync -->|Yes| UploadMedia[Upload photo to Firebase Storage]
    UploadMedia --> SetFirestore[Set meal document in Cloud Firestore]
    BackgroundSync -->|No / Offline| LocalOnly[Persisted in SQLite for future sync]
```

---

### Flow 3: Daily Log Exploration & Real-Time Filtering

```mermaid
flowchart TD
    OpenLog[User opens Daily Log Screen] --> FetchToday[Load meals for current date from SQLite]
    FetchToday --> DisplayList[Display chronological meal cards]

    DisplayList --> ActionChoice{User Action}
    
    ActionChoice -->|Change Date| PickDate[Open Calendar Picker]
    PickDate --> ReloadDate[Reload meals for selected date]
    ReloadDate --> DisplayList

    ActionChoice -->|Type in Search Bar| SearchQuery[Filter by keyword in meal details]
    SearchQuery --> UpdateUI[Update visible meal list in real time]

    ActionChoice -->|Tap Category Chip| SelectChip[Filter by All, Breakfast, Lunch, Dinner, Snack]
    SelectChip --> UpdateUI

    ActionChoice -->|Delete Meal| ConfirmDelete{Show delete confirmation}
    ConfirmDelete -->|Confirm| DeleteDB[Delete from SQLite & Cloud Firestore]
    DeleteDB --> UpdateUI
```

---

### Flow 4: Visual Analytics & Progress Tracking

```mermaid
flowchart LR
    subgraph Daily Summary
        D1[User taps Daily Breakdown] --> D2[Calculate Today's Category Totals]
        D2 --> D3[Render Interactive Donut Chart]
        D3 --> D4[Display Percentage Badges & Legend]
    end

    subgraph Weekly Summary
        W1[User taps Weekly Progress] --> W2[Query Mon-Sun 7-Day Meals]
        W2 --> W3[Render 7-Day Bar Chart]
        W3 --> W4[Enable Touch Tooltips & Totals]
        W4 --> W5[Render Weekly Category Breakdown Chart]
    end
```

---

### Flow 5: PDF Dietary Report Generation & Native Sharing

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant Screen as DailyLog / Summary Screen
    participant Helper as PdfExportHelper
    participant PDF as pdf Package
    participant Share as printing / share_plus

    User->>Screen: Tap "Export PDF" icon in AppBar
    Screen->>Screen: Display loading indicator
    Screen->>Helper: generateDailyMealReport(date, meals, stats)
    Helper->>PDF: Build A4 Document Layout (Header, Metrics, Meal Tables)
    PDF-->>Helper: Document Uint8List bytes
    Helper->>Share: Printing.sharePdf(bytes, filename)
    Share-->>User: Open Native OS Share Sheet (Print, Email, WhatsApp, Save to Files)
```

---

## 4. Screen-by-Screen UI Component Specifications

### 4.1 Login Screen (`LoginScreen`)
- **Header:** Food Diary Logo, App Title, and welcoming subtitle.
- **Form Controls:**
  - Email TextField (`TextInputType.emailAddress`, email regex validation).
  - Password TextField (`obscureText: true`, visibility toggle).
- **Actions:**
  - "Sign In" Primary Button.
  - "Continue as Guest" Outlined Button.
  - "Don't have an account? Sign Up" navigation link.

### 4.2 Register Screen (`RegisterScreen`)
- **Form Controls:**
  - Full Name TextField (Mandatory).
  - Email Address TextField (Format validation).
  - Password TextField (Minimum 6 characters).
  - Confirm Password TextField (Exact matching validator).
- **Actions:**
  - "Create Account" Primary Button.
  - Back navigation to Login Screen.

### 4.3 Home Screen (`HomeScreen`)
- **AppBar:**
  - Greeting header: `"Hello, {DisplayName}"` or `"Hello, Guest"`.
  - Theme mode toggle button (Sun / Moon icon).
  - Sign-out action icon with confirmation dialog.
- **Body Dashboard:**
  - Meal Category Quick Shortcuts (4 interactive cards: Breakfast, Lunch, Dinner, Snack).
  - "Today's Meals" quick entry card with progress count.
  - "Daily Breakdown" interactive summary card.
  - "Weekly Progress" 7-day analytical summary card.
- **Floating Action Button (FAB):** Centered (+) button to add a new meal instantly.

### 4.4 Daily Log Screen (`DailyLogScreen`)
- **AppBar:**
  - Title with calendar date selector (`IconButton(icon: Icons.calendar_month)`).
  - "Export PDF" action button.
- **Search & Filter Bar:**
  - Real-time text search bar with clear icon.
  - Horizontal filter chips: `All`, `Breakfast`, `Lunch`, `Dinner`, `Snack`.
- **Meal List:**
  - Card view showing meal type badge, formatted time, details snippet, and thumbnail image.
  - Slide-to-dismiss or delete button with confirmation dialog.

### 4.5 Summary Screens (`DailySummaryScreen` & `WeeklySummaryScreen`)
- **AppBar:** Screen title and "Export PDF" action button.
- **Metric Cards:** Total meals logged, most active meal category, logging streak.
- **Interactive Charts:**
  - FlChart PieChart with animated touch expansion.
  - FlChart BarChart with Mon-Sun labels and tooltip badges.

---

## 5. Edge Cases & Resilience Engineering

| Edge Case | Potential Impact | System Resolution |
| :--- | :--- | :--- |
| **No Internet Connectivity** | Cloud sync fails | App operates 100% normally using local SQLite database. Firebase synchronization is caught gracefully without error popups. |
| **User Skips Photo Capture** | Meal has no visual asset | Default meal type vector graphic is rendered in the UI and PDF report. |
| **Search Yields No Results** | Empty list | Beautiful empty-state illustration with "No meals match your search query" and a "Reset Filters" action button. |
| **First-Time User (Zero Meals)** | Blank dashboard | Guided call-to-action cards encouraging user to log their first meal. |
| **Camera Permission Denied** | Inability to take photo | Graceful fallback prompting the user to pick from the photo library or continue with text details only. |
| **Session Expiry / Token Refresh** | Potential auth failure | Silent token refresh via Firebase SDK, with automatic graceful fallback to cached session. |
