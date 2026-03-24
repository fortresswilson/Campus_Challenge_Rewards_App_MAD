# campus_challenge_rewards_app_mad
# 🏆 CampusQuest — Campus Challenge & Rewards App

> **Georgia State University | Mobile Application Development (MAD)**
> A cross-platform Flutter application that gamifies campus life through challenges, points, badges, and leaderboards.

---

## 📖 Project Overview

CampusQuest is a mobile app built for GSU students to join and create campus challenges across categories like Fitness, Academic, Mindfulness, and Health. Users earn points by completing challenges, unlock badges, and compete on a live leaderboard. The app uses local SQLite persistence so all data survives app restarts and works fully offline.

### Key Features
- **Authentication** — Sign up and sign in with email/password validation, duplicate email prevention, and wrong password detection
- **Challenge List** — Browse, search, and filter challenges by category; join or leave in real time
- **Challenge Detail** — View progress, log daily activity, and earn points on completion
- **Create Challenge** — Build custom challenges with a live preview card before submitting
- **Home Dashboard** — Personalized greeting, real-time stats (points, joined, completed, active), and active challenge progress bars
- **Profile** — Dynamic stats, earned badges, active challenges, and a live leaderboard that auto-refreshes every 30 seconds with rank change indicators (▲▼)

---

## ⚙️ Setup Instructions

### Prerequisites
Make sure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x or higher)
- [Dart](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) or [Xcode](https://developer.apple.com/xcode/) (for iOS)
- A connected device or emulator

### 1. Clone the repository
```bash
git clone https://github.com/fortresswilson/Campus_Challenge_Rewards_App_MAD.git
cd Campus_Challenge_Rewards_App_MAD
```

### 2. Install dependencies
```bash
flutter pub get
```

Make sure your `pubspec.yaml` includes:
```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.9.0
  google_fonts: ^6.0.0
```

### 3. Run the app
```bash
flutter run
```

For a specific device:
```bash
flutter run -d <device_id>
```

> **Note:** On first launch the database is created automatically and seeded with 4 starter challenges. No manual database setup is required.

### 4. Clean build (if you see database errors)
```bash
flutter clean
flutter pub get
flutter run
```

---

## 🗂️ File Structure

```
lib/
├── main.dart                        # App entry point, theme setup, orientation lock
│
├── database/                        # All SQLite logic
│   ├── database_helper.dart         # DB initialization, table creation, seed data
│   ├── auth_service.dart            # createUser() — sign up with duplicate email check
│   ├── login_service.dart           # loginUser() — validates email then password separately
│   └── challenge_service.dart       # All challenge, participant, rewards, and leaderboard functions
│
├── models/
│   └── mock_data.dart               # Mock data used during UI development (replaced by SQLite)
│
├── screens/
│   ├── login_screen.dart            # Login and sign up screen with animations
│   ├── home_screen.dart             # Bottom nav shell + home dashboard with real-time stats
│   ├── challenge_list_screen.dart   # Browse/search/filter challenges, join/leave buttons
│   ├── challenge_detail_screen.dart # Challenge info, progress bar, log activity, join/leave
│   ├── create_challenge_screen.dart # Form to create a new challenge with live preview
│   └── profile_screen.dart          # User stats, badges, active challenges, live leaderboard
│
└── theme/
    └── app_theme.dart               # Colors, gradients, text styles, dark theme config
```

### Database Tables
```
users         → id, name, email, password, points, streak
challenges    → id, title, description, category, difficulty, duration_days, points_reward, emoji, created_by
participants  → id, user_id, challenge_id, progress, joined_at, completed
rewards       → id, user_id, badge_name, earned_at, points_required
```

---

## 👥 Team

| Role | Responsibility |
|------|---------------|
| Person 1 | All UI screens, animations, theme, navigation |
| Person 2 | SQLite database, all service functions, backend wiring |

---

## 🛠️ Tech Stack

- **Flutter** — Cross-platform UI framework
- **Dart** — Programming language
- **SQLite (sqflite)** — Local data persistence
- **Google Fonts (Nunito)** — Typography
- **setState** — State management

---

*Georgia State University — Mobile Application Development*
