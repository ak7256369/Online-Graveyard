# The Online Graveyard (Flutter App)

A complete memorial application built with Flutter Clean Architecture and Firebase.

## Prerequisites

1.  **Flutter SDK**: Ensure Flutter is installed and in your PATH.
    -   Verify with `flutter doctor`.
2.  **Firebase CLI**: Install with `npm install -g firebase-tools`.
    -   Login with `firebase login`.
3.  **Node.js**: Required for Cloud Functions deployment.

## 1. Setup Backend (One-Time)

The app relies on Firebase Cloud Functions for AI moderation and notifications.

1.  Navigate to the functions directory:
    ```bash
    cd functions
    npm install
    # If there are vulnerabilities, you can run: npm audit fix --force
    cd ..
    ```

2.  Deploy the functions:
    ```bash
    firebase deploy --only functions
    ```
    *Note: This deploys `moderateTribute` and `checkAnniversaries`.*

## 2. Run the App (Frontend)

1.  Install dependencies:
    ```bash
    flutter pub get
    ```

2.  Run on your connected device (Emulator or Physical):
    ```bash
    flutter run
    ```

## Features to Test

-   **Create Memorial**: Tap the **+** (Create) button on the home screen.
-   **Search**: Tap the **Search** icon in the header.
-   **Profile View**: Tap any card to see the parallax profile, video, and gallery.
-   **Light a Candle**: Tap the 🔥 FAB on a profile.
-   **Add Tribute**: Tap "Write a Tribute" on a profile to post a message (AI moderated!).

## Troubleshooting

-   **CocoaPods Error (iOS)**:
    ```bash
    cd ios
    pod install
    cd ..
    ```
-   **Firestore Permission Error**: Ensure your Firestore rules allow read/write (for development).
    -   Check `firestore.rules` in Firebase Console.
