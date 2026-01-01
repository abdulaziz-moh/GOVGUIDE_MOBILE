import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:govguide/auth/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  User? get user => _user;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    _user = user;
    notifyListeners();
  }

  bool get isLoggedIn => _user != null;

  // Future<void> signOut() async {
  //   await _auth.signOut();
  // }
  // Modify this in your auth_provider.dart
Future<void> signOut() async {
  // Use the logic that includes GoogleSignIn().signOut()
  await AuthService().signOut(); 
  // notifyListeners() is usually handled by the authStateChanges listener
}
}
