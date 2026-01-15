import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = true;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null && _userModel != null;

  // Role-based getters
  bool get isAdmin => _userModel?.role == UserRole.admin;
  bool get isIdolMaker => _userModel?.role == UserRole.idolMaker;
  bool get isUser => _userModel?.role == UserRole.user;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _authService.authStateChanges.listen((User? user) async {
      _firebaseUser = user;
      if (user != null) {
        // Load user model from Firestore
        _userModel = await _authService.getUserProfile(user.uid);
        if (_userModel != null) {
          // Update last login
          await _authService.updateLastLogin(user.uid);
        }
      } else {
        _userModel = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> signInWithPhoneAndPassword(String phoneNumber, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _authService.signInWithPhoneAndPassword(phoneNumber, password);
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<bool> signUpWithPhoneAndPassword(String phoneNumber, String password, {String? name, String? email}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _authService.signUpWithPhoneAndPassword(phoneNumber, password, name: name, email: email);
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> updateUserProfile({String? name, String? email}) async {
    if (_firebaseUser != null) {
      await _authService.updateUserProfile(_firebaseUser!.uid, name: name, email: email);
      // Reload user model
      _userModel = await _authService.getUserProfile(_firebaseUser!.uid);
      notifyListeners();
    }
  }

  AuthService get authService => _authService;
}
