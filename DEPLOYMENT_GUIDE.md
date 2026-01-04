# EventHub Deployment Guide

## Overview
This guide provides step-by-step instructions for deploying the EventHub application with all implemented features.

## Prerequisites

### Development Environment
- Flutter SDK 3.9.2 or later
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Xcode (for iOS development)
- Firebase CLI
- Git

### Third-Party Accounts
1. **Firebase Account**
   - Create a project at https://console.firebase.google.com
   - Enable Authentication (Email, Google, Facebook)
   - Enable Firestore Database
   - Enable Cloud Messaging

2. **Google Developer Account**
   - For Google Sign-In configuration
   - https://console.developers.google.com

3. **Facebook Developer Account**
   - Create an app at https://developers.facebook.com
   - Get App ID and App Secret

4. **Stripe Account** (Optional for payment testing)
   - Create account at https://stripe.com
   - Get test API keys

## Step 1: Firebase Setup

### 1.1 Create Firebase Project
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project
firebase init
```

### 1.2 Configure Firebase Authentication
1. Go to Firebase Console → Authentication
2. Enable sign-in methods:
   - Email/Password ✓
   - Google ✓
   - Facebook ✓

### 1.3 Download Configuration Files
- **Android**: Download `google-services.json` → Place in `android/app/`
- **iOS**: Download `GoogleService-Info.plist` → Place in `ios/Runner/`

### 1.4 Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth.uid == userId;
      
      // User's bookmarks
      match /bookmarks/{bookmarkId} {
        allow read, write: if request.auth.uid == userId;
      }
      
      // User's followers
      match /followers/{followerId} {
        allow read: if true;
        allow write: if request.auth != null;
      }
      
      // User's following
      match /following/{followingId} {
        allow read: if true;
        allow write: if request.auth.uid == userId;
      }
    }
    
    // Events collection
    match /events/{eventId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.organizerId;
    }
    
    // Bookings collection
    match /bookings/{bookingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
    
    // Reviews collection
    match /reviews/{reviewId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
    
    // Notifications collection
    match /notifications/{notificationId} {
      allow read, update: if request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
    
    // Contact messages collection
    match /contact_messages/{messageId} {
      allow create: if request.auth != null;
      allow read, update: if request.auth != null && 
        request.auth.token.admin == true;
    }
    
    // Payments collection
    match /payments/{paymentId} {
      allow read: if request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
  }
}
```

### 1.5 Firestore Indexes
Create these composite indexes in Firestore:
```
Collection: notifications
Fields: userId (Ascending), createdAt (Descending)

Collection: reviews
Fields: eventId (Ascending), createdAt (Descending)

Collection: bookings
Fields: userId (Ascending), bookedAt (Descending)
```

## Step 2: Platform Configuration

### 2.1 Android Configuration

#### Update `android/app/src/main/AndroidManifest.xml`
```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    
    <application>
        <!-- FCM -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="high_importance_channel" />
            
        <!-- Existing activity configuration -->
    </application>
</manifest>
```

#### Update `android/app/build.gradle`
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
}
```

### 2.2 iOS Configuration

#### Update `ios/Runner/Info.plist`
```xml
<dict>
    <!-- Camera Permission -->
    <key>NSCameraUsageDescription</key>
    <string>Camera access is required to scan QR codes for event check-in</string>
    
    <!-- Photo Library Permission -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Photo library access is required to save QR codes</string>
    
    <!-- Location Permission -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Location access helps you discover nearby events</string>
    
    <!-- Existing configuration -->
</dict>
```

#### Update `ios/Podfile`
```ruby
platform :ios, '13.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
```

## Step 3: Social Authentication Setup

### 3.1 Google Sign-In

#### Android
1. Get SHA-1 fingerprint:
```bash
cd android
./gradlew signingReport
```

2. Add SHA-1 to Firebase Console → Project Settings → Your Apps → Android
3. Download updated `google-services.json`

#### iOS
1. Add URL scheme in `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

2. Get CLIENT_ID from `GoogleService-Info.plist`

### 3.2 Facebook Sign-In

1. Create Facebook App at https://developers.facebook.com
2. Get App ID and App Secret
3. Add Facebook SDK to Firebase Console

#### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data 
    android:name="com.facebook.sdk.ApplicationId" 
    android:value="@string/facebook_app_id"/>

<meta-data 
    android:name="com.facebook.sdk.ClientToken" 
    android:value="@string/facebook_client_token"/>
```

Add to `android/app/src/main/res/values/strings.xml`:
```xml
<string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
<string name="facebook_client_token">YOUR_FACEBOOK_CLIENT_TOKEN</string>
```

#### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>fbYOUR_FACEBOOK_APP_ID</string>
        </array>
    </dict>
</array>

<key>FacebookAppID</key>
<string>YOUR_FACEBOOK_APP_ID</string>
<key>FacebookDisplayName</key>
<string>EventHub</string>
```

## Step 4: Stripe Payment Setup (Optional)

### 4.1 Get Stripe Keys
1. Create account at https://stripe.com
2. Get test publishable key from Dashboard → Developers → API keys

### 4.2 Initialize Stripe in `main.dart`
```dart
import 'package:event_hub/services/payment_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Stripe
  await PaymentService.initializeStripe(
    publishableKey: 'pk_test_YOUR_PUBLISHABLE_KEY',
  );
  
  runApp(const ProviderScope(child: MyApp()));
}
```

### 4.3 Backend Setup (Required for Production)
Create a Cloud Function or backend API:

```javascript
// Example Cloud Function (Node.js)
const functions = require('firebase-functions');
const stripe = require('stripe')('sk_test_YOUR_SECRET_KEY');

exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
  const paymentIntent = await stripe.paymentIntents.create({
    amount: data.amount,
    currency: data.currency,
    metadata: {
      userId: context.auth.uid,
      bookingId: data.bookingId,
    },
  });
  
  return {
    clientSecret: paymentIntent.client_secret,
    paymentIntentId: paymentIntent.id,
  };
});
```

## Step 5: Install Dependencies

```bash
flutter pub get
flutter pub upgrade
```

## Step 6: Build and Run

### Development
```bash
# Run on Android
flutter run

# Run on iOS
flutter run

# Run on web
flutter run -d chrome
```

### Production Build

#### Android APK
```bash
flutter build apk --release
```

#### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

## Step 7: Testing Checklist

### Authentication
- [ ] Email/Password sign-up
- [ ] Email/Password sign-in
- [ ] Email verification
- [ ] Password reset
- [ ] Google Sign-In
- [ ] Facebook Sign-In
- [ ] Remember Me functionality
- [ ] Logout

### Events
- [ ] Create event
- [ ] View event details
- [ ] Book tickets
- [ ] View bookings
- [ ] Bookmark events
- [ ] View bookmarked events

### Social Features
- [ ] Follow/Unfollow users
- [ ] View followers list
- [ ] View following list
- [ ] Add reviews
- [ ] View reviews

### Notifications
- [ ] Receive push notifications
- [ ] View notifications list
- [ ] Mark as read

### Other Features
- [ ] Contact form submission
- [ ] Settings screen
- [ ] Profile management

## Step 8: Deployment

### Play Store (Android)
1. Create signed app bundle
2. Upload to Google Play Console
3. Complete store listing
4. Submit for review

### App Store (iOS)
1. Create archive in Xcode
2. Upload to App Store Connect
3. Complete app information
4. Submit for review

## Troubleshooting

### Common Issues

#### Google Sign-In not working
- Verify SHA-1 fingerprint is added to Firebase
- Check package name matches
- Ensure google-services.json is up to date

#### Facebook Sign-In not working
- Verify App ID is correct
- Check callback URL configuration
- Ensure app is in development mode

#### Build errors
```bash
# Clean build
flutter clean
flutter pub get

# iOS specific
cd ios
pod deinstall
pod install
```

#### Permission issues
- Check AndroidManifest.xml has all required permissions
- Verify Info.plist has usage descriptions
- Request permissions at runtime

## Support & Resources

- **Firebase Documentation**: https://firebase.google.com/docs
- **Flutter Documentation**: https://flutter.dev/docs
- **Stripe Documentation**: https://stripe.com/docs
- **Google Sign-In**: https://developers.google.com/identity
- **Facebook Login**: https://developers.facebook.com/docs/facebook-login

## Security Best Practices

1. **Never commit sensitive keys** to version control
2. Use **environment variables** or **Firebase Remote Config** for API keys
3. Implement **Firestore security rules** properly
4. Use **backend services** for payment processing
5. Enable **App Check** in Firebase for additional security
6. Implement **rate limiting** for API endpoints
7. Use **SSL/TLS** for all network communications
8. Implement **proper error handling** without exposing sensitive information

## Maintenance

### Regular Updates
- Keep Flutter SDK updated
- Update dependencies regularly
- Monitor Firebase usage
- Review security rules
- Check for deprecated APIs

### Monitoring
- Set up Firebase Crashlytics
- Monitor Firebase Analytics
- Track user feedback
- Review app performance

## Conclusion

Your EventHub application is now ready for deployment! Follow this guide step by step to ensure all features work correctly in production. For any issues, refer to the troubleshooting section or consult the official documentation.

Remember to thoroughly test all features before releasing to production, especially payment processing and authentication flows.
