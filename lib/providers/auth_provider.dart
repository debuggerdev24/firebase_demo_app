import 'package:firebase_test_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationProvider with ChangeNotifier {
  AuthenticationProvider({required this.authService});

  final FirebaseAuthService authService;
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  void changeLosing(bool newValue) {
    _isLoading = newValue;
    notifyListeners();
  }

  void changeCurrentUser(User? newUser) {
    _currentUser = newUser;
    notifyListeners();
  }

  /// Sign up with email and password
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      changeLosing(true);
      _currentUser = await authService.signUpWithEmail(email, password);
    } catch (e) {
      rethrow;
    } finally {
      changeLosing(false);
    }
  }

  /// Sign up with phone number
  Future<void> signUpWithPhone(
      String phoneNumber, Function(String) codeSentCallback) async {
    try {
      changeLosing(true);
      await authService.signUpWithPhone(phoneNumber, codeSentCallback);
    } catch (e) {
      rethrow;
    } finally {
      changeLosing(false);
    }
  }

  /// Validate OTP for phone authentication
  Future<void> validateOtp(String verificationId, String otp) async {
    try {
      changeLosing(true);
      _currentUser = await authService.validateOtp(verificationId, otp);
    } catch (e) {
      rethrow;
    } finally {
      changeLosing(false);
    }
  }

  /// Login with email and password
  Future<void> loginWithEmail(String email, String password) async {
    try {
      changeLosing(true);
      _currentUser = await authService.loginWithEmail(email, password);
    } catch (e) {
      rethrow;
    } finally {
      changeLosing(false);
    }
  }

  /// Login with phone and OTP
  Future<void> loginWithPhone(
      String phoneNumber, Function(String) codeSentCallback, String otp) async {
    try {
      changeLosing(true);
      _currentUser =
          await authService.loginWithPhone(phoneNumber, codeSentCallback, otp);
    } catch (e) {
      rethrow;
    } finally {
      changeLosing(false);
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      changeLosing(true);
      await FirebaseAuth.instance.signOut();
      _currentUser = null;
    } catch (e) {
      rethrow;
    } finally {
      changeLosing(false);
    }
  }
}
