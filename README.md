# EventHub - Event Management Application

A comprehensive Flutter application for discovering, organizing, and managing events with social features, ticketing, and real-time notifications.

## 🚀 Features

### Authentication & Security
- ✅ Email/Password authentication
- ✅ Google Sign-In integration
- ✅ Facebook Sign-In integration
- ✅ Email verification system
- ✅ Remember Me with secure credential storage
- ✅ Password reset functionality

### Event Management
- ✅ Browse and discover events
- ✅ Create new events
- ✅ Event details with location and pricing
- ✅ Ticket booking system
- ⏳ Edit and delete events (infrastructure complete)
- ⏳ QR code generation for tickets
- ⏳ Event check-in with QR scanner

### Social Features
- ✅ Follow/Unfollow users
- ✅ Followers and Following lists
- ✅ Event reviews and ratings
- ✅ Bookmark favorite events
- ⏳ Social sharing (infrastructure complete)

### Payments
- ✅ Stripe integration for test payments
- ✅ Payment history tracking
- ⏳ Production payment flow (requires backend setup)

### Notifications
- ✅ Firebase Cloud Messaging integration
- ✅ Local notifications
- ✅ Follower notifications
- ✅ Booking confirmations
- ✅ Event reminders
- ⏳ UI integration in notifications screen

### Additional Features
- ✅ Comprehensive settings screen
- ✅ Contact us form
- ✅ User profiles
- ✅ Search functionality
- ✅ Chat system

## 📱 Screenshots

_(Screenshots will be added after UI implementation)_

## 🛠️ Tech Stack

- **Framework**: Flutter 3.9.2+
- **State Management**: Riverpod
- **Backend**: Firebase (Auth, Firestore, Cloud Messaging)
- **Authentication**: Firebase Auth, Google Sign-In, Facebook Login
- **Payments**: Stripe
- **Maps**: Google Maps
- **Storage**: Flutter Secure Storage
- **QR Codes**: qr_flutter, qr_code_scanner

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^4.2.1
  firebase_auth: ^6.1.2
  cloud_firestore: ^6.1.0
  firebase_messaging: ^14.7.10
  
  # Authentication
  google_sign_in: ^6.2.1
  flutter_facebook_auth: ^6.0.4
  flutter_secure_storage: ^9.0.0
  
  # State Management
  flutter_riverpod: ^3.0.3
  
  # UI & Utilities
  cupertino_icons: ^1.0.8
  intl: ^0.20.2
  image_picker: ^1.0.7
  
  # Maps & Location
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  permission_handler: ^11.0.1
  
  # Payments
  flutter_stripe: ^10.1.1
  
  # QR Codes
  qr_flutter: ^4.1.0
  qr_code_scanner: ^1.0.1
  
  # Notifications
  flutter_local_notifications: ^16.3.2
  
  # Social
  share_plus: ^7.2.2
  url_launcher: ^6.2.4
  
  # Navigation
  persistent_bottom_nav_bar: ^6.2.1
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or later)
- Dart SDK
- Firebase account
- Google Developer account (for Google Sign-In)
- Facebook Developer account (for Facebook Login)
- Stripe account (for payments - optional)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/mmyahya29/EventHub.git
   cd EventHub
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Add your Android and iOS apps
   - Download configuration files:
     - `google-services.json` for Android → `android/app/`
     - `GoogleService-Info.plist` for iOS → `ios/Runner/`
   - Enable Authentication providers (Email, Google, Facebook)
   - Set up Firestore Database
   - Enable Cloud Messaging

4. **Configure Social Authentication**
   - Follow the instructions in `DEPLOYMENT_GUIDE.md` for detailed setup
   - Configure Google Sign-In with SHA-1 fingerprint
   - Set up Facebook App and add credentials

5. **Run the app**
   ```bash
   flutter run
   ```

## 📖 Documentation

- **[IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md)** - Detailed feature implementation status
- **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Complete deployment instructions
- **[API Documentation](lib/services/)** - Service layer documentation

## 🏗️ Project Structure

```
lib/
├── auth_screens/           # Authentication screens
├── main_screens/           # Main app screens
│   ├── events_subscreens/  # Event-related screens
│   └── explore_subscreens/ # Explore and discovery screens
├── models/                 # Data models
├── providers/              # Riverpod providers
├── services/               # Business logic and API services
├── utils/                  # Utility functions
├── widgets/                # Reusable widgets
└── main.dart              # App entry point
```

## 🔐 Security

- Credentials stored securely using `flutter_secure_storage`
- Firebase security rules implemented
- Payment processing follows PCI compliance guidelines
- Sensitive data never exposed in client code

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 📝 Implementation Status

**Current Status: ~75% Complete**

### ✅ Completed
- Core infrastructure (services, models, providers)
- Authentication system (all methods)
- Social features backend
- Payment integration
- Notification system
- Essential UI screens and widgets
- Comprehensive documentation

### ⏳ In Progress
- UI integration for remaining features
- Event edit/delete screens
- QR code scanner screen
- Social sharing implementation

See [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md) for detailed status.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- **Yahya Hyder** - *Initial work* - [mmyahya29](https://github.com/mmyahya29)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- All contributors and testers

## 📞 Support

For support, email support@eventhub.com or open an issue in the repository.

## 🔄 Version History

- **1.0.0** (Current)
  - Initial release with core features
  - Authentication system
  - Event management
  - Social features
  - Payment integration
  - Notification system

## 🗺️ Roadmap

- [ ] Complete UI integration for all features
- [ ] Add event categories and filtering
- [ ] Implement advanced search
- [ ] Add chat enhancements
- [ ] Performance optimizations
- [ ] Offline support
- [ ] Analytics dashboard for organizers
- [ ] Multi-language support

---

Made with ❤️ using Flutter
