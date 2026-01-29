# Firebase Setup Guide for KnowBase App

This guide will walk you through the complete Firebase setup process for your Flutter app.

## Prerequisites

Before you begin, make sure you have:
- Flutter SDK installed
- Node.js installed (required for Firebase CLI)
- A Google account

## Step 1: Install Firebase CLI and FlutterFire CLI

Open your terminal and run the following commands:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

## Step 2: Login to Firebase

```bash
firebase login
```

This will open a browser window for you to sign in with your Google account.

## Step 3: Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Enter your project name (e.g., "KnowBase App")
4. Click **Continue**
5. Enable Google Analytics (recommended)
6. Choose or create a Google Analytics account
7. Click **Create project**
8. Wait for the project to be created

## Step 4: Configure Firebase for Your Flutter App

Navigate to your project directory and run:

```bash
cd c:\StudioProjects\figma_to_flutter_app
flutterfire configure
```

This command will:
- Ask you to select your Firebase project
- Automatically detect all platforms in your Flutter app
- Register your app with Firebase
- Generate the `firebase_options.dart` file
- Download platform-specific configuration files

**Follow the prompts:**
1. Select your Firebase project from the list
2. Choose the platforms you want to configure (Android, iOS, Web, etc.)
3. For Android: Use the existing application ID `com.example.figmapp.figma_to_flutter_app`
4. For iOS: Enter a bundle ID (e.g., `com.example.figmapp.knowbase`)

The CLI will automatically:
- Create `lib/firebase_options.dart`
- Download `google-services.json` for Android
- Download `GoogleService-Info.plist` for iOS
- Update your project configuration

## Step 5: Enable Firebase Services in Console

### 5.1 Enable Firebase Authentication

1. In Firebase Console, go to **Build** → **Authentication**
2. Click **Get started**
3. Click on **Sign-in method** tab
4. Enable **Email/Password** provider:
   - Click on **Email/Password**
   - Toggle **Enable**
   - Click **Save**

### 5.2 Create Firestore Database

1. In Firebase Console, go to **Build** → **Firestore Database**
2. Click **Create database**
3. Select **Start in test mode** (you can update security rules later)
4. Choose your Cloud Firestore location (select one closest to your users)
5. Click **Enable**

### 5.3 Set Up Firebase Storage

1. In Firebase Console, go to **Build** → **Storage**
2. Click **Get started**
3. Start in **test mode** (you can update security rules later)
4. Choose your Cloud Storage location
5. Click **Done**

### 5.4 Enable Firebase Analytics

1. In Firebase Console, go to **Build** → **Analytics**
2. Analytics should be automatically enabled if you chose to enable it during project creation
3. If not, click **Enable Analytics** and follow the prompts

## Step 6: Install Flutter Dependencies

Run the following command to download all Firebase packages:

```bash
flutter pub get
```

## Step 7: Platform-Specific Configuration (Already Done)

✅ **Android Configuration** - Already configured in your project:
- Google services plugin added to `settings.gradle.kts`
- Plugin applied in `app/build.gradle.kts`
- Minimum SDK set to 21

✅ **iOS Configuration** - Will be handled by FlutterFire CLI

## Step 8: Deploy Firestore Security Rules

> [!IMPORTANT]
> **Action Required:** Your Firestore database is currently denying all access because the test mode rules have expired. You must deploy the security rules immediately to restore app functionality.

### Understanding the Issue

When you created your Firestore database, you chose "Start in test mode", which allowed unrestricted access for 30 days. That period has now expired, and all client requests are being denied. This is why you're seeing "Firestore access denied" errors after login.

### Deploy Security Rules via Firebase Console

Your project now includes a `firestore.rules` file with production-ready security rules. Follow these steps to deploy them:

1. **Open the security rules file:**
   - Open `firestore.rules` in your project root
   - Copy the entire contents (Ctrl+A, Ctrl+C)

2. **Navigate to Firebase Console:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project: **KnowBase App** (knowbase-app-47444)

3. **Access Firestore Rules:**
   - Click on **"Firestore Database"** in the left sidebar
   - Click on the **"Rules"** tab at the top

4. **Update the rules:**
   - Delete all existing content in the rules editor
   - Paste the contents from your `firestore.rules` file
   - Click **"Publish"** button

5. **Verify deployment:**
   - You should see a success message
   - The rules should now show as "Active"

### What These Rules Do

The new security rules ensure:

✅ **Authentication Required:** Only authenticated users can access the database  
✅ **Data Isolation:** Users can only read/write their own notes, events, and profile  
✅ **Ownership Validation:** The `userId` field is validated to prevent spoofing  
✅ **Secure Updates:** Users cannot change the owner of a document

### Example Rules Structure

```javascript
// Notes collection - users can only access their own notes
match /notes/{noteId} {
  allow read: if request.auth.uid == resource.data.userId;
  allow create: if request.auth.uid == request.resource.data.userId;
  allow update: if request.auth.uid == resource.data.userId;
  allow delete: if request.auth.uid == resource.data.userId;
}
```

### Storage Security Rules

For Firebase Storage, also update the rules in **Storage → Rules** tab:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Users can only access files in their own folder
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```



## Step 9: Test Your Firebase Integration

### Test on Android:

```bash
flutter run
```

### Test on iOS (Mac only):

```bash
flutter run -d ios
```

### Test on Web:

```bash
flutter run -d chrome
```

## Verification Checklist

After setup, verify that:
- [ ] The app launches without errors
- [ ] Firebase is initialized (check debug console for "Firebase initialized" type messages)
- [ ] You can see your app in the Firebase Console
- [ ] All four services (Auth, Firestore, Storage, Analytics) are enabled

## Using Firebase Services in Your App

The following service classes are ready to use in your app:

### 1. Firebase Authentication (`firebase_auth_service.dart`)

```dart
import 'package:figma_to_flutter_app/services/firebase_auth_service.dart';

final authService = FirebaseAuthService();

// Sign up
await authService.signUpWithEmailAndPassword(
  email: 'user@example.com',
  password: 'password123',
);

// Sign in
await authService.signInWithEmailAndPassword(
  email: 'user@example.com',
  password: 'password123',
);

// Sign out
await authService.signOut();
```

### 2. Firestore Database (`firestore_service.dart`)

```dart
import 'package:figma_to_flutter_app/services/firestore_service.dart';

final firestoreService = FirestoreService();

// Add a document
await firestoreService.addDocument(
  collectionPath: 'notes',
  data: {'title': 'My Note', 'content': 'Note content'},
);

// Get documents
final notes = await firestoreService.getCollection(
  collectionPath: 'notes',
);

// Real-time updates
firestoreService.streamCollection(
  collectionPath: 'notes',
).listen((notes) {
  // Handle updates
});
```

### 3. Firebase Storage (`storage_service.dart`)

```dart
import 'package:figma_to_flutter_app/services/storage_service.dart';
import 'dart:io';

final storageService = StorageService();

// Upload a file
final downloadUrl = await storageService.uploadFile(
  file: File('path/to/file'),
  storagePath: 'users/user123/files/myfile.pdf',
);

// Download a file
final file = await storageService.downloadFile(
  storagePath: 'users/user123/files/myfile.pdf',
  localFilePath: 'downloads/myfile.pdf',
);
```

### 4. Firebase Analytics (`analytics_service.dart`)

```dart
import 'package:figma_to_flutter_app/services/analytics_service.dart';

final analyticsService = AnalyticsService();

// Log screen views
await analyticsService.logScreenView(screenName: 'home_screen');

// Log custom events
await analyticsService.logEvent(
  eventName: 'button_clicked',
  parameters: {'button_name': 'save'},
);

// Log note creation
await analyticsService.logNoteCreated(noteType: 'text');
```

## Troubleshooting

### Common Issues:

1. **"Firebase not initialized" error**
   - Make sure you ran `flutterfire configure`
   - Check that `firebase_options.dart` exists in your `lib` folder

2. **Android build fails**
   - Make sure `google-services.json` is in `android/app/` directory
   - Run `flutter clean` and `flutter pub get`

3. **iOS build fails** (Mac only)
   - Make sure `GoogleService-Info.plist` is in `ios/Runner/` directory
   - Run `cd ios && pod install`

4. **"Duplicate FirebaseApp" error**
   - Make sure you're only calling `Firebase.initializeApp()` once in `main.dart`

## Next Steps

Now that Firebase is set up, you can:
1. Create authentication screens (login, signup)
2. Implement data persistence with Firestore
3. Add file upload functionality
4. Track user behavior with Analytics

For more information, visit the [FlutterFire documentation](https://firebase.flutter.dev/).
