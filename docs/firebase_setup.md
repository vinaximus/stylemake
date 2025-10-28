# Firebase Setup Guide for Stylemake

This guide explains how to set up Firebase Crashlytics for error logging and monitoring in Stylemake.

## Prerequisites

- Firebase account (create one at https://firebase.google.com/)
- Firebase CLI (optional, for easier configuration)

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: "Stylemake" (or your preferred name)
4. Enable/disable Google Analytics (optional for this use case)
5. Click "Create project"

## Step 2: Register Android App

1. In Firebase console, click "Add app" and select "Android"
2. Enter package name: `com.example.stylemake` (or your actual package name from `android/app/build.gradle.kts`)
3. Enter app nickname: "Stylemake Android" (optional)
4. Skip SHA-1 for now (not needed for Crashlytics)
5. Click "Register app"
6. Download `google-services.json`
7. Place the file in `android/app/google-services.json`

## Step 3: Register iOS App

1. In Firebase console, click "Add app" and select "iOS"
2. Enter bundle ID: from `ios/Runner.xcodeproj/project.pbxproj`
3. Enter app nickname: "Stylemake iOS" (optional)
4. Download `GoogleService-Info.plist`
5. Open `ios/Runner.xcworkspace` in Xcode
6. Drag and drop `GoogleService-Info.plist` into the Runner folder
7. Ensure "Copy items if needed" is checked

## Step 4: Configure Android

The Flutter Firebase plugins handle most configuration automatically, but verify these files exist:

**android/build.gradle.kts:**
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
        classpath("com.google.firebase:firebase-crashlytics-gradle:2.9.9")
    }
}
```

**android/app/build.gradle.kts:**
```kotlin
plugins {
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}
```

## Step 5: Enable Crashlytics in Firebase Console

1. Go to Firebase Console > Crashlytics
2. Click "Enable Crashlytics"
3. Follow the setup wizard (most steps are already complete)

## Step 6: Test Crashlytics Integration

Run the app and test crash reporting:

```bash
flutter run
```

In the app, you can trigger a test crash through the performance/debug menu (if implemented), or check the Firebase console after a few minutes of app usage.

## Step 7: Verify in Firebase Console

1. Go to Firebase Console > Crashlytics
2. After running the app, you should see crash reports and logs
3. It may take a few minutes for the first data to appear

## Configuration Files Location

After setup, you should have:

- `android/app/google-services.json` (Android config)
- `ios/Runner/GoogleService-Info.plist` (iOS config)

**Important:** Add these files to `.gitignore` if they contain sensitive information or use environment-specific configurations.

## Troubleshooting

### Crashlytics Not Showing Data

- Ensure app is running in release mode or profile mode (Crashlytics disabled in debug by default)
- Check Firebase console after 10-15 minutes (initial setup can be slow)
- Verify `google-services.json` and `GoogleService-Info.plist` are in the correct locations

### Build Errors on Android

- Run `flutter clean`
- Delete `android/.gradle` folder
- Run `flutter pub get`
- Rebuild: `flutter build apk`

### Build Errors on iOS

- Run `pod install` in `ios/` directory
- Clean build folder in Xcode (Cmd+Shift+K)
- Rebuild

## Disable Crashlytics (Optional)

To disable Crashlytics temporarily:

In `lib/core/services/crashlytics_service.dart`, the service automatically disables collection in debug mode. To completely disable:

```dart
await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
```

## Additional Resources

- [Firebase Crashlytics Documentation](https://firebase.google.com/docs/crashlytics)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/crashlytics/overview)

## Notes for v0.5

- Crashlytics is configured but optional
- App works without Firebase configuration (initialization errors are caught and logged)
- In production, ensure Firebase is properly configured for full monitoring capabilities

