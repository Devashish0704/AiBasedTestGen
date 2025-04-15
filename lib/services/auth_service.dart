import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        "729200849890-b1emfuuie32oju83ue3t0kvti83ea542.apps.googleusercontent.com", // 👈 Add your Web Client ID
    scopes: ['email'],
  );

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Start Google Sign-In process
      print("Starting Google Sign-In process...");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("Google Sign-In canceled by user.");
        return null; // User canceled sign-in
      }
      print("Google Sign-In successful. User: ${googleUser.email}");

      // Obtain authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print("Obtained Google authentication details.");

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print("Created Firebase credential.");

      // Sign in the user with Firebase
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      print("Firebase sign-in successful. User UID: ${user?.uid}");

      print("Returned type: ${user.runtimeType}");

      if (user != null) {
        // Check if the user exists in the 'users' collection
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // Add a new document for the user
          await _firestore.collection('users').doc(user.uid).set({
            'auth_provider': 'google',
            'email': user.email ?? '',
            'name': user.displayName ?? '', // Add the user's name
            'created_at': FieldValue.serverTimestamp(),
            'profile_pic' : user.photoURL ?? ''
          });
          print('New user added to the users collection.');
        } else {
          print('User already exists in the users collection.');
        }
      }

      return user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  /// 🔹 Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  /// 🔹 Get currently signed-in user
  User? get currentUser => _auth.currentUser;
}
