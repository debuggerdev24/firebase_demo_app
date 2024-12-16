import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Adds a new user to the "users" collection.
  ///
  /// [uid] - The unique ID of the user (e.g., Firebase Auth UID).
  /// [firstName] - The first name of the user.
  /// [lastName] - The last name of the user.
  /// [dob] - The date of birth of the user.
  /// [currentLocation] - The current location of the user.
  Future<void> addUser({
    required String uid,
    required String firstName,
    required String lastName,
    required DateTime dob,
    required String currentLocation,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'dob': dob.toIso8601String(),
        'currentLocation': currentLocation,
      });
    } catch (e) {
      throw Exception('Failed to add user: $e');
    }
  }

  /// Updates an existing user in the "users" collection.
  ///
  /// [uid] - The unique ID of the user (e.g., Firebase Auth UID).
  /// [data] - A map of fields to update and their new values.
  Future<void> updateUser({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }
}
