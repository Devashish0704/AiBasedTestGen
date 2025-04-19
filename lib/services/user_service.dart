import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_generator/Data/quiz_settings.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔹 Fetch user details by user ID
  Future<Map<String, dynamic>?> getUserDetails() async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) return null; // No user logged in

      // Fetch user document from Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        print("User data fetched: ${userDoc.data()}");
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print('User document does not exist.');
        return null;
      }
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }

  /// 🔹 Update user details in Firestore
  Future<void> updateUserDetails(Map<String, dynamic> updatedData) async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore.collection('users').doc(userId).update(updatedData);
      print("User details updated successfully.");
    } catch (e) {
      print("Error updating user details: $e");
    }
  }
}
