# Deployment Guide for Online Graveyard

This guide covers everything needed to deploy the Online Graveyard app to production using Firebase Spark (free) plan.

## 1. Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed
- [Firebase CLI](https://firebase.google.com/docs/cli) installed (`npm install -g firebase-tools`)
- A Google account with access to the Firebase project `online-graveyard-d1d24`

## 2. Firebase Configuration (Critical First Step)

You must link your local project to the Firebase project to generate the required API keys.

1.  **Login to Firebase:**
    ```bash
    firebase login
    ```

2.  **Configure FlutterFire:**
    Run this command in the project root:
    ```bash
    flutterfire configure --project=online-graveyard-d1d24
    ```
    - Select **android**, **ios**, **web**, and **windows**.
    - This will overwrite `lib/firebase_options.dart` with your *real* keys.
    - It will also generate `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`.

3.  **Deploy Security Rules & Indexes:**
    Deploy the rules I created for you:
    ```bash
    firebase deploy --only firestore:rules,firestore:indexes,storage
    ```

## 3. Local Testing

Before building, verify everything works locally:

1.  **Run on Web (Chrome):**
    ```bash
    flutter run -d chrome
    ```
2.  **Run on Android Emulator:**
    ```bash
    flutter run
    ```
3.  **Check Critical Flows:**
    - [ ] App launches without crashing
    - [ ] Home feed loads (shows empty state or existing memorials)
    - [ ] **Create Memorial:** Tap `+`, fill details, upload photo (pick from gallery), submit. Verifies Storage & Firestore write.
    - [ ] **View Profile:** Tap the new memorial. Verifies Navigation & Data passing.
    - [ ] **Light Candle:** Tap candle button. Verifies atomic increment.
    - [ ] **Post Tribute:** Write a tribute. Verifies sub-collection write.
    - [ ] **Search:** Type in search bar. Verifies Firestore query.
    - [ ] **QR Code:** Tap QR icon on a card. Verifies the QR code is visible (dark on white).

## 4. Build for Production

### Web (Firebase Hosting)

1.  **Build Web:**
    ```bash
    flutter build web --release
    ```
    Output: `build/web/`

2.  **Deploy to Firebase Hosting:**
    ```bash
    firebase init hosting
    # Set public directory to: build/web
    # Configure as single-page app: Yes
    firebase deploy --only hosting
    ```
    Your app will be live at `https://online-graveyard-d1d24.web.app`

### Android (APK & App Bundle)

1.  **Update Version:**
    Update `version` in `pubspec.yaml` (e.g., `1.0.0+1`).

2.  **Build APK (for direct install):**
    ```bash
    flutter build apk --release
    ```
    Output: `build/app/outputs/flutter-apk/app-release.apk`

3.  **Build App Bundle (for Play Store):**
    ```bash
    flutter build appbundle --release
    ```
    Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (Requires macOS)

1.  **Build Archive:**
    ```bash
    flutter build ipa --release
    ```
    Output: `build/ios/archive/Runner.xcarchive`

## 5. Client Handoff

When delivering to the client, provide:

1.  **Source Code:** Zip the entire project folder (exclude `build/`, `.dart_tool/`, `.idea/`).
2.  **Keystore:** The `upload-keystore.jks` file (if you created one) and its credentials. **Critical for future updates.**
3.  **Firebase Ownership:**
    - Go to [Firebase Console](https://console.firebase.google.com/) > Project Settings > Users and permissions.
    - Add the client's email as **Owner**.
    - Once they accept, you can remove yourself if needed.
4.  **Web Hosting URL:** `https://online-graveyard-d1d24.web.app` (if deployed to Firebase Hosting).

## 6. Registered Firebase Apps

| Platform | App ID | Bundle/Package ID |
|----------|--------|-------------------|
| Android  | `1:662161459184:android:f23924bfee0c6c91d3bf35` | `com.example.online_graveyard` |
| Web      | `1:662161459184:web:d03644ccd7022952d3bf35` | — |
| Windows  | `1:662161459184:web:36097fc423275031d3bf35` | — |

## 7. Maintenance & Limits

**Firebase Spark Plan Limits (Free):**
- **Firestore:** 50,000 reads/day, 20,000 writes/day.
- **Storage:** 5 GB total space, 1 GB downloads/day.
- **Hosting:** 10 GB/month transfer (if used).

**If the app grows:**
- The app will stop working if limits are hit (e.g., images won't load).
- Upgrade to **Blaze Plan** (Pay as you go) to remove limits.
