# Firebase Authentication Setup Guide

This guide will help you set up Firebase Authentication for your RentME Koraput app. You'll need to provide specific details from your Firebase account to complete the integration.

## 🔧 What You Need From Your Firebase Account

### 1. Firebase Project Setup
**Required from your Firebase Console:**
- **Project ID**: Found in Firebase Console → Project Settings → General tab
- **API Key**: Found in Firebase Console → Project Settings → General tab → Web API Key
- **App ID**: Found in Firebase Console → Project Settings → General tab → App ID
- **Messaging Sender ID**: Found in Firebase Console → Project Settings → Cloud Messaging tab
- **Storage Bucket**: Found in Firebase Console → Project Settings → Storage tab

### 2. Authentication Methods Setup
**Enable these authentication methods in Firebase Console:**

#### Email/Password Authentication
1. Go to Firebase Console → Authentication → Sign-in method
2. Enable **Email/Password**
3. Configure email templates if needed

#### Phone Authentication
1. Go to Firebase Console → Authentication → Sign-in method
2. Enable **Phone**
3. Add your domain to authorized domains (for web)
4. Configure reCAPTCHA settings

### 3. Platform-Specific Configuration

#### For Android:
- **SHA certificate fingerprints**: Generate from your keystore
- **Package name**: `com.rentme.koraput` (or your actual package name)

#### For iOS:
- **Bundle ID**: `com.rentme.koraput` (or your actual bundle ID)
- **App Store ID**: If deploying to App Store

#### For Web:
- **Authorized domains**: Add your domain (e.g., `localhost`, `yourdomain.com`)

## 📱 Step-by-Step Setup Instructions

### Step 1: Install Firebase CLI
```bash
npm install -g firebase-tools
firebase login
```

### Step 2: Configure Firebase in Your Project
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (this will create firebase_options.dart)
flutterfire configure
```

### Step 3: Enable Authentication Methods
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Authentication** → **Sign-in method**
4. Enable:
   - **Email/Password**
   - **Phone**

### Step 4: Update Firebase Configuration
After running `flutterfire configure`, the `firebase_options.dart` file will be automatically updated with your project details.

## 🔐 Security Rules Setup

### Firestore Security Rules (if using Firestore)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Authentication Rules
Ensure your Firebase Authentication rules are configured to allow:
- Email/password sign-up and sign-in
- Phone number verification

## 📊 Test Your Setup

### Test Email Authentication
1. Use the "Login with Email (Firebase)" button
2. Try creating a new account
3. Try logging in with existing credentials

### Test Phone Authentication
1. Use the "Login with Phone (Firebase)" button
2. Enter a valid phone number with country code (+91XXXXXXXXXX for India)
3. Verify the OTP sent to your phone

## 🚨 Common Issues & Solutions

### Issue: Firebase App Not Initialized
**Solution**: Ensure Firebase.initializeApp() is called before any Firebase operations

### Issue: Phone Auth Not Working
**Solutions**:
- Check if phone authentication is enabled in Firebase Console
- Ensure phone number format includes country code (+91 for India)
- Verify reCAPTCHA is configured for web

### Issue: Email Auth Not Working
**Solutions**:
- Check if email/password authentication is enabled
- Verify email format is valid
- Check Firebase Console for any email verification requirements

### Issue: Missing google-services.json (Android)
**Solution**: Download from Firebase Console → Project Settings → Android app

### Issue: Missing GoogleService-Info.plist (iOS)
**Solution**: Download from Firebase Console → Project Settings → iOS app

## 📋 Required Information Checklist

Before proceeding, ensure you have:

- [ ] Firebase project created
- [ ] Email/Password authentication enabled
- [ ] Phone authentication enabled
- [ ] Platform-specific configurations (Android/iOS/Web)
- [ ] Firebase CLI installed and logged in
- [ ] FlutterFire CLI installed
- [ ] `flutterfire configure` command executed

## 🎯 Next Steps

1. **Run Firebase Configuration**:
   ```bash
   flutterfire configure
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Test Authentication**:
   - Run the app
   - Use the new Firebase login buttons
   - Test both email and phone authentication

4. **Deploy to Production**:
   - Update authorized domains for web
   - Configure production reCAPTCHA keys
   - Set up proper security rules

## 🔍 Verification Commands

To verify your setup:

```bash
# Check Firebase CLI installation
firebase --version

# Check FlutterFire CLI installation
flutterfire --version

# List Firebase projects
firebase projects:list

# Test Firebase connection
firebase apps:list
```

## 📞 Support

If you encounter issues:
1. Check Firebase Console logs
2. Verify all authentication methods are enabled
3. Ensure proper phone number format (+countryCodeNumber)
4. Check platform-specific configuration files

For additional help, refer to:
- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/auth/overview)