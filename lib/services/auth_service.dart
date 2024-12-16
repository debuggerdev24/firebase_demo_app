import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign up with email and password
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error in signUpWithEmail: $e');
      throw e;
    }
  }

  /// Sign up with phone
  Future<void> signUpWithPhone(
      String phoneNumber, Function(String) codeSentCallback) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Error in signUpWithPhone: ${e.message}');
          throw e;
        },
        codeSent: (String verificationId, int? resendToken) {
          codeSentCallback(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      print('Error in signUpWithPhone: $e');
      throw e;
    }
  }

  /// Validate OTP for phone authentication
  Future<User?> validateOtp(String verificationId, String otp) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Error in validateOtp: $e');
      throw e;
    }
  }

  /// Login with email and password
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error in loginWithEmail: $e');
      throw e;
    }
  }

  /// Login with phone and OTP
  Future<User?> loginWithPhone(
      String phoneNumber, Function(String) codeSentCallback, String otp) async {
    try {
      String verificationId = '';
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // final userCredential = await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Error in loginWithPhone: ${e.message}');
          throw e;
        },
        codeSent: (String verificationIdReceived, int? resendToken) {
          verificationId = verificationIdReceived;
          codeSentCallback(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );

      // Wait for OTP and sign in
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Error in loginWithPhone: $e');
      throw e;
    }
  }
}
