 import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInWithGoogle() async {
  try {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null; // User canceled the picker

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
    
  } catch (e) {
    print("Error during Google Sign-In: $e");
    return null; 
  }
}

  // Future<void> signOut() async {
  //   await _auth.signOut();
  // }

  // Modify this in your auth_service.dart
Future<void> signOut() async {
  try {
    // 1. Sign out from Google (this forces the account picker next time)
    await GoogleSignIn().signOut();
    
    // 2. Sign out from Firebase
    await _auth.signOut();
  } catch (e) {
    print("Error during logout: $e");
  }
}
}
