# 🥗 My Food Diary (يومي الغذائي)

**My Food Diary** is a simple, offline-first Android mobile app built with Flutter, designed to help users **track their daily meals** in a clean and beautiful interface.  
It stores all data **locally** using SQLite and does **not require any internet connection or user account**.

---

## 📱 Features

- ✅ **Add New Meal**
    - Choose meal type (Breakfast, Lunch, Dinner, Snack)
    - Write meal details (e.g., "Eggs + Bread + Tea")
    - Auto-filled date/time (editable)
    - Optional meal photo

- 📋 **Daily Log View**
    - Displays all meals grouped by meal type
    - Shows image (if available), description, and time

- 📆 **Daily Summary Screen**
    - Overview of today's meals in a clean scrollable layout

- 📊 **Weekly Summary Screen**
    - Graph (bar/pie) showing number of meals or common food items over the last 7 days

- ✏️ **Edit & Delete Meals**
    - Modify existing meals or remove them

- 🎨 **Attractive UI**
    - Soft colors (green, orange, white), rounded corners, modern and calming design
    - Fully responsive and optimized for Android screen sizes

---

## 🔧 Technical Details

| Feature                     | Tech Used                 |
|----------------------------|---------------------------|
| Language                   | Flutter (Dart)            |
| Offline Storage            | SQLite (sqflite package)  |
| State Management           | Provider / setState       |
| Image Picker               | image_picker package      |
| Charts                     | fl_chart or similar       |
| Platform                   | Android only              |
| Internet Requirement       | ❌ No internet needed     |
| Authentication             | ❌ No login/signup needed |

---

## 🗂️ Folder Structure (Typical)

