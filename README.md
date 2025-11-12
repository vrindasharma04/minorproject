# 📱 Digithela – Connecting Street Food Vendors to Customers

Digithela is a cross-platform mobile application built using **Flutter** and **Firebase** that empowers street food vendors by giving them a digital presence and helps customers discover and coordinate with them in real time. Designed with simplicity, inclusivity, and local culture in mind, Digithela bridges the gap between informal vendors and tech-savvy customers.



## 🚀 Features

### 👨‍🍳 Vendor Module
- Role-based login and signup
- Add and manage business profile
- Upload and edit menu items
- View and manage customer orders
- Real-time order updates

### 👤 Customer Module
- Browse vendors by event or location
- View vendor profiles and menus
- Add items to cart and place orders
- Confirm pickup and view order success screen

### ⚙️ General
- Firebase Authentication
- Firestore real-time database
- Clean UI with Material 3 design
- Role-based navigation and routing



## 🛠️ Tech Stack

| Layer        | Technology         |
|--------------|--------------------|
| Frontend     | Flutter (Dart)     |
| Backend      | Firebase Firestore |
| Auth         | Firebase Auth      |
| State Mgmt   | setState / basic logic |
| UI Framework | Material 3         |



## 📂 Project Structure
lib/
│
├── main.dart                        # Entry point of the application
│
├── screens/
│   ├── splash_screen.dart            # Initial splash screen
│   ├── role_selection_screen.dart    # Lets user choose vendor or customer
│   ├── login_screen.dart             # Handles login for both roles
│   ├── signup_screen.dart            # Handles signup for both roles
│   │
│   ├── vendors/                      # Vendor module
│   │   ├── vendor_dashboard.dart
│   │   ├── menu_management_screen.dart
│   │   ├── add_business_screen.dart
│   │   └── business_profile_screen.dart
│   │
│   └── customer/                     # Customer module
│       ├── customer_dashboard.dart
│       ├── vendor_detail_screen.dart
│       ├── cart_screen.dart
│       └── order_success_screen.dart
│
└── firebase_options.dart             # Firebase configuration (auto-generated)

 cbaac0b782d991cc9603c6b7a7c2cc1869dbec03
