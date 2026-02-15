import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _user = AuthService.currentUser;
    
    // Listen to auth state changes
    AuthService.authStateChanges.listen((User? user) {
      print('🔔 Auth state change: ${user?.email}');
      _user = user;
      notifyListeners();
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final credential = await AuthService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );

      if (credential.user != null) {
        _user = credential.user;
        notifyListeners();
        return true;
      } else {
        _setError('Failed to create account');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'operation-not-allowed') {
        _setError('Email/Password authentication is not enabled in the Firebase Console. Please enable it in the Authentication > Sign-in method section.');
      } else if (e.code == 'email-already-in-use') {
        _setError('This email address is already in use by another account.');
      } else if (e.code == 'weak-password') {
        _setError('The password provided is too weak.');
      } else if (e.code == 'invalid-email') {
        _setError('The email address is badly formatted.');
      } else {
        _setError(e.message ?? 'An authentication error occurred');
      }
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final credential = await AuthService.signIn(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        _user = credential.user;
        notifyListeners();
        return true;
      } else {
        _setError('Failed to sign in');
        return false;
      }
    } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          _setError('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          _setError('Wrong password provided for that user.');
        } else if (e.code == 'email-not-verified') {
          _setError(e.message);
        } else if (e.code == 'user-disabled') {
          _setError('This user account has been disabled.');
      } else if (e.code == 'invalid-email') {
        _setError('The email address is badly formatted.');
      } else if (e.code == 'operation-not-allowed') {
        _setError('Email/Password authentication is not enabled in the Firebase Console.');
      } else {
        _setError(e.message ?? 'An authentication error occurred');
      }
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      await AuthService.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to sign out');
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);
      await AuthService.resetPassword(email);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      _setLoading(true);
      _setError(null);
      await AuthService.updatePassword(newPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String get userDisplayName {
    return _user?.displayName ?? _user?.email?.split('@').first ?? 'User';
  }

  String? get userEmail => _user?.email;
  String? get userPhoneNumber => _user?.phoneNumber;
  bool get isEmailVerified => AuthService.isEmailVerified;

  // Confirm password reset with code (Firebase)
  Future<bool> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      await AuthService.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Simplified password reset for authenticated users
  Future<bool> updatePasswordForAuthenticatedUser(String newPassword) async {
    try {
      _setLoading(true);
      _setError(null);
      print('🚀 AuthProvider: Updating password for authenticated user');
      print('Current user: ${_user?.email}');
      
      await AuthService.updatePasswordForAuthenticatedUser(newPassword);
      
      print('✅ AuthProvider: Password updated successfully');
      // Refresh user state
      _user = AuthService.currentUser;
      notifyListeners();
      
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      print('🔥 AuthProvider: ${e.runtimeType}: $e');
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}