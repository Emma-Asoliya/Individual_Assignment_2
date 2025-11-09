// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email verification
  Future<String?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      // Create user in Firebase Auth
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      
      if (user != null) {
        // Update display name
        await user.updateDisplayName('$firstName $lastName');
        
        // Create user document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'firstName': firstName,
          'lastName': '$firstName $lastName',
          'email': email,
          'createdAt': Timestamp.now(),
          'emailVerified': false,
        });

        // Send email verification
        await user.sendEmailVerification();

        return null; // Success
      }
      
      return 'Failed to create user';
    } on FirebaseAuthException catch (e) {
      return _getAuthErrorMessage(e);
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  // Sign in with email verification check
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      
      if (user != null) {
        // Check if email is verified
        if (!user.emailVerified) {
          await _auth.signOut(); // Sign out if not verified
          return 'Please verify your email before logging in. Check your inbox for the verification link.';
        }
        
        // Update last login time
        await _firestore.collection('users').doc(user.uid).update({
          'lastLoginAt': Timestamp.now(),
          'emailVerified': true, // Update verification status
        });
        
        return null; // Success
      }
      
      return 'Login failed';
    } on FirebaseAuthException catch (e) {
      return _getAuthErrorMessage(e);
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  // Resend email verification
  Future<String?> resendVerificationEmail() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        return null;
      }
      return 'No user logged in';
    } catch (e) {
      return 'Failed to send verification email: $e';
    }
  }

  // Check if user is verified and logged in
  Future<bool> isUserVerified() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      // Reload user to get latest email verification status
      await user.reload();
      final User? refreshedUser = _auth.currentUser;
      return refreshedUser?.emailVerified ?? false;
    }
    return false;
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}