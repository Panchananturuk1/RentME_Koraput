# RentMe Koraput 🏠

A modern Flutter web application for rental property management in Koraput. This platform connects property owners with potential tenants, providing a seamless rental experience with authentication, property listings, and user management.

## 🌐 Live Demo

**Production URL:** [https://rentme-mykoraput.web.app](https://rentme-mykoraput.web.app)

## ✨ Features

- **User Authentication**: Secure login and registration system powered by Firebase
- **Property Listings**: Browse and manage rental properties
- **Responsive Design**: Optimized for web, mobile, and tablet devices
- **Modern UI**: Clean and intuitive user interface
- **Real-time Updates**: Live data synchronization
- **Form Validation**: Comprehensive input validation
- **External Links**: Integrated URL launcher for external resources

## 🛠️ Tech Stack

- **Frontend**: Flutter Web
- **Backend**: Firebase (Authentication & Cloud Firestore)
- **State Management**: Provider
- **HTTP Client**: HTTP package
- **UI Components**: Material Design with custom styling
- **Icons**: Cupertino Icons & Flutter SVG
- **Responsive Design**: Flutter ScreenUtil
- **Local Storage**: Shared Preferences
- **Deployment**: Vercel with GitHub Actions CI/CD

## 📋 Prerequisites

Before running this project, make sure you have:

- Flutter SDK (^3.8.1)
- Dart SDK
- Web browser (Chrome, Firefox, Safari, Edge)
- Git
- Code editor (VS Code, Android Studio, etc.)

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd rentme_koraput
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Update the configuration in `lib/config/firebase_config.dart`
3. Add your Firebase web configuration options

### 4. Run the Application

#### For Web Development:
```bash
flutter run -d web-server --web-port 3001
```

#### For Production Build:
```bash
flutter build web --release
```

## 📱 Development

### Project Structure

```
lib/
├── config/
│   └── firebase_config.dart    # Firebase configuration
├── providers/
│   └── auth_provider.dart      # Authentication state management
├── screens/
│   ├── auth/                   # Authentication screens
│   ├── dashboard/              # Dashboard screens
│   └── splash_screen.dart      # Splash screen
├── services/
│   └── auth_service.dart       # Authentication services
└── main.dart                   # App entry point
```

### Available Scripts

- `flutter run -d web-server --web-port 3001` - Start development server
- `flutter build web --release` - Build for production
- `flutter test` - Run tests
- `flutter analyze` - Analyze code quality
- `flutter pub get` - Install dependencies

## 🚀 Deployment

This project is configured for automatic deployment to Vercel using GitHub Actions.

### Automatic Deployment

1. Push changes to the main branch
2. GitHub Actions will automatically:
   - Build the Flutter web app
   - Deploy to Vercel
   - Update the production URL

### Manual Deployment

```bash
# Build the project
flutter build web --release

# Deploy to Vercel
vercel deploy build/web --prod
```

## 🔧 Configuration Files

- **`vercel.json`**: Vercel deployment configuration with SPA routing
- **`.github/workflows/deploy.yml`**: GitHub Actions CI/CD pipeline
- **`pubspec.yaml`**: Flutter dependencies and project metadata
- **`analysis_options.yaml`**: Dart/Flutter linting rules

## 📦 Dependencies

### Main Dependencies
- `firebase_core: ^3.10.1` - Core Firebase SDK
- `firebase_auth: ^5.4.1` - Authentication services
- `cloud_firestore: ^5.6.2` - NoSQL database
- `provider: ^6.1.1` - State management
- `http: ^1.1.0` - HTTP client
- `flutter_screenutil: ^5.9.0` - Responsive design
- `form_validator: ^2.1.1` - Form validation
- `flutter_svg: ^2.0.9` - SVG support
- `url_launcher: ^6.2.2` - External links
- `shared_preferences: ^2.2.2` - Local storage

### Dev Dependencies
- `flutter_test` - Testing framework
- `flutter_lints: ^5.0.0` - Code linting

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions, please contact the development team or create an issue in the repository.

## 🔗 Useful Links

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Vercel Documentation](https://vercel.com/docs)
- [Provider Package](https://pub.dev/packages/provider)
