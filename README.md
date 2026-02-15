# RentMe Koraput 🏠

A modern Flutter web application for rental property management in Koraput. This platform connects property owners with potential tenants, providing a seamless rental experience with authentication, property listings, and user management.

## 🌐 Live Demo

**Production URL:** [https://rentme-mykoraput.web.app](https://rentme-mykoraput.web.app)

## 📱 Screenshots
 <img src="https://drive.google.com/uc?export=view&id=1cuKVlqo2rKgQZqZvpcV88a9bTlJ64LL2" alt="Home-Page" width="300"> <img src="https://drive.google.com/uc?export=view&id=11P93aNH3Z4QWp722ejJ6WSA0sxCBf2tM" alt="signin" width="300"> <img src="https://drive.google.com/uc?export=view&id=1cZAM3oeiHK7gbW3YF5op8YMxbn8dp0e0" alt="booking" width="300"> <img src="https://drive.google.com/uc?export=view&id=1WlKMBnMbCvcCDIOuIpOlp2hfUnyPz1KE" alt="booking" width="300">

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
