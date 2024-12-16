import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_test_app/services/firestore_service.dart';
import 'package:flutter/material.dart';

class ProfileProvider with ChangeNotifier {
  final FirestoreService firestoreService;

  ProfileProvider({
    required this.firestoreService,
  });

  /// Stream for listening to user profile changes
  Stream<DocumentSnapshot<Map<String, dynamic>>> userProfileStream(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  Future<void> addProfile(
    String uid,
  ) async {
    await firestoreService.addUser(
      uid: uid,
      firstName: "",
      lastName: "",
      dob: DateTime(0),
      currentLocation: "",
    );
  }

  /// Update user profile
  Future<void> updateProfile({
    required String firstName,
    required String uid,
    required String lastName,
    required String dob,
    required String currentLocation,
  }) async {
    try {
      await firestoreService.updateUser(
        uid: uid,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'dob': dob,
          'currentLocation': currentLocation,
        },
      );
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
