# 📱 RaktSetu - Blood Donor Finder (Mobile App)

A cross-platform mobile application built using **Flutter & Dart**, designed to run smoothly on **Android**, **iOS**, and **Mobile Web**.

---

## 🚀 Mobile App Features
- **Modern Material 3 Design**: Crimson red medical color scheme with soft rounded cards and bottom navigation bar.
- **Instant Search & Compatibility Engine**: Filter donors by blood group, city, or toggle clinical blood compatibility.
- **One-Tap Actions**:
  - Direct Phone Call integration (`tel:<phone>`).
  - Direct WhatsApp chat integration (`https://wa.me/...`) with pre-filled distress messages.
- **Urgent Need Broadcast**: Patients and attendants can post emergency blood needs with units required and urgency level (*Critical*, *Immediate*, *Scheduled*).
- **Interactive Blood Matrix Tool**: Educational tool showing who can donate and receive red blood cells.
- **Offline Resilient**: Communicates with the Flask REST backend (`http://<ip>:5000/api`) with fallback sample data if offline.

---

## 📂 Mobile Project Structure
```text
mobile_app/
├── pubspec.yaml                 # Dependencies (http, url_launcher, etc.)
├── README.md                    # Mobile setup and run guide
└── lib/
    ├── main.dart                # App entry point & Material 3 theme
    ├── models/
    │   ├── donor.dart           # Donor data model & JSON serializers
    │   └── blood_request.dart   # Emergency request model
    ├── services/
    │   └── api_service.dart     # HTTP client & phone/WhatsApp launcher
    └── screens/
        ├── home_screen.dart          # Home dashboard & bottom navigation
        ├── donor_search_screen.dart  # Search donors with filter chips & city input
        ├── register_screen.dart      # Donor registration with form validation
        ├── emergency_feed_screen.dart# Urgent requests feed + post dialog
        └── matrix_screen.dart        # Interactive blood group compatibility tool
```

---

## 🛠️ How to Run the Mobile App

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- Android Studio / VS Code or an Android device connected via USB with Developer Mode & USB Debugging enabled.

### 2. Connect to Your Flask Backend
In `lib/services/api_service.dart`, set `baseUrl`:
- For **Android Emulator**: `http://10.0.2.2:5000` (already set by default)
- For **Physical Android Device**: `http://<YOUR_COMPUTER_LOCAL_IP>:5000` (e.g. `http://192.168.1.15:5000`)

### 3. Install Dependencies
```bash
cd mobile_app
flutter pub get
```

### 4. Run the App
```bash
# Run on connected Android phone or Emulator:
flutter run

# Or run as a Flutter Web App:
flutter run -d chrome
```

### 5. Build Release Android APK
```bash
flutter build apk --release
```
The generated APK will be at:
`build/app/outputs/flutter-apk/app-release.apk`
