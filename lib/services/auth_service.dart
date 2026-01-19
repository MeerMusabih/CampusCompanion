import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';
import '../models/user_model.dart';
import '../core/constants.dart';
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<User?> get user {
    return _auth.authStateChanges();
  }
  Future<UserCredential?> register(String email, String password, UserModel userData) async {
    try {
      debugPrint('📝 AuthService: Attempting registration for email: $email');
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      
      final uid = userCredential.user!.uid;
      debugPrint('✅ AuthService: Registration successful for user: $uid');

      // 2. Save user data to Firestore
      final userToSave = UserModel(
        uid: uid,
        email: email,
        name: userData.name,
        role: userData.role,
        department: userData.department,
        registrationNumber: userData.registrationNumber,
        semester: userData.semester,
        status: userData.status,
        profilePic: userData.profilePic,
      );

      await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .set(userToSave.toMap());

      debugPrint('✅ AuthService: Firestore user data saved successfully');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ AuthService: Registration failed - Code: ${e.code}, Message: ${e.message}');
      throw e.message ?? "An error occurred during registration";
    } catch (e) {
      debugPrint('❌ AuthService: Unexpected error during registration: $e');
      throw "An unexpected error occurred: $e";
    }
  }
  Future<UserCredential?> login(String email, String password) async {
    try {
      debugPrint('🔐 AuthService: Attempting login for email: $email');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ AuthService: Login successful for user: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ AuthService: Login failed - Code: ${e.code}, Message: ${e.message}');
      throw e.message ?? "An error occurred during login";
    } catch (e) {
      debugPrint('❌ AuthService: Unexpected error during login: $e');
      throw "An unexpected error occurred: $e";
    }
  }
  Future<void> logout() async {
    await _auth.signOut();
  }
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Failed to send reset email";
    }
  }
  String? get currentUserId => _auth.currentUser?.uid;

  Future<String> createUserByAdmin({
    required String email,
    required String password,
    required UserModel userData,
  }) async {
    FirebaseApp? secondaryApp;
    try {
      debugPrint('📝 AuthService: Ensuring secondary app for user creation');
      try {
        secondaryApp = Firebase.app('SecondaryApp');
      } catch (e) {
        secondaryApp = await Firebase.initializeApp(
          name: 'SecondaryApp',
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      UserCredential userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      debugPrint('✅ AuthService: Auth user created successfully: $uid');

      // 2. Save user data to Firestore
      final userToSave = UserModel(
        uid: uid,
        email: userData.email,
        name: userData.name,
        role: userData.role,
        department: userData.department,
        registrationNumber: userData.registrationNumber,
        semester: userData.semester,
        status: userData.status,
        profilePic: userData.profilePic,
      );

      await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .set(userToSave.toMap());

      debugPrint('✅ AuthService: Firestore user data saved successfully');
      return uid;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ AuthService: Creation failed - ${e.message}');
      throw e.message ?? "Failed to create user";
    } catch (e) {
      debugPrint('❌ AuthService: Unexpected error: $e');
      throw "Unexpected error creating user";
    } finally {
      if (secondaryApp != null) {
        await secondaryApp.delete();
        debugPrint('🧹 AuthService: Secondary app deleted');
      }
    }
  }
}
