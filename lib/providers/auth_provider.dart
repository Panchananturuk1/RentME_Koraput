import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    AuthService.authStateChanges.listen((AuthState data) {
      _user = data.session?.user;
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

      final response = await AuthService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );

      if (response.user != null) {
        _user = response.user;
        notifyListeners();
        return true;
      } else {
        _setError('Failed to create account');
        return false;
      }
    } on AuthException catch (e) {
      _setError(e.message);
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

      final response = await AuthService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _user = response.user;
        notifyListeners();
        return true;
      } else {
        _setError('Failed to sign in');
        return false;
      }
    } on AuthException catch (e) {
      _setError(e.message);
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
      _setLoading(true);
      _setError(null);

      await AuthService.signOut();
      _user = null;
      notifyListeners();
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await AuthService.resetPassword(email);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String get userDisplayName {
    if (_user?.userMetadata?['full_name'] != null) {
      return _user!.userMetadata!['full_name'];
    }
    return _user?.email?.split('@').first ?? 'User';
  }

  String? get userEmail => _user?.email;
  String? get userPhoneNumber => _user?.userMetadata?['phone_number'];
  bool get isEmailVerified => AuthService.isEmailVerified;
}