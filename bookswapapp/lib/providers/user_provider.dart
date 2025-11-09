import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UserProvider() {
    _checkCurrentUser();
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  void _checkCurrentUser() {
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _error = null;

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _user = FirebaseAuth.instance.currentUser;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signup(String email, String password, String name) async {
    try {
      _setLoading(true);
      _error = null;

      UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      
      // Update user profile with name
      await credential.user!.updateDisplayName(name);
      _user = credential.user;
      
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error signing out: $e';
      notifyListeners();
    }
  }

  // Email verification methods
  Future<void> sendEmailVerification() async {
    if (_user != null && !_user!.emailVerified) {
      await _user!.sendEmailVerification();
    }
  }

  Future<void> reloadUser() async {
    if (_user != null) {
      await _user!.reload();
      _user = FirebaseAuth.instance.currentUser;
      notifyListeners();
    }
  }

  bool get isEmailVerified => _user?.emailVerified ?? false;

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _setLoading(loading);
  }

  void setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // User info getters
  String? get userId => _user?.uid;
  String? get userEmail => _user?.email;
  String? get displayName => _user?.displayName;
  String? get photoUrl => _user?.photoURL;
}