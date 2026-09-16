import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../infrastructure/datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<AuthResult> login(String email, String password) async {
    debugPrint('Firebase Login: $email');
    
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final fbUser = userCredential.user!;
    final userDoc = await _firestore.collection('users').doc(fbUser.uid).get();
    final userData = userDoc.data() ?? {};

    final result = AuthResult(
      id: fbUser.uid.hashCode,
      username: userData['firstName'] ?? 'User',
      email: fbUser.email ?? '',
      firstName: userData['firstName'] ?? 'Foydalanuvchi',
      lastName: '',
      gender: '',
      image: userData['imagePath'] ?? '',
      accessToken: await fbUser.getIdToken() ?? '',
      refreshToken: fbUser.refreshToken ?? '',
      phone: userData['phone'],
      currency: userData['currency'],
    );

    await localDataSource.saveAccessToken(result.accessToken);
    
    return result;
  }

  @override
  Future<void> register(User user) async {
    debugPrint('Firebase Register: ${user.email}');
    
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: user.email.trim(),
      password: user.password.trim(),
    );

    String? imageUrl;
    if (user.imagePath != null && File(user.imagePath!).existsSync()) {
      imageUrl = await _uploadImage(userCredential.user!.uid, user.imagePath!);
    }

    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'uid': userCredential.user!.uid,
      'firstName': user.firstName,
      'email': user.email,
      'phone': user.phone,
      'currency': user.currency,
      'imagePath': imageUrl ?? user.imagePath,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateUser(User user) async {
    final currentUid = _firebaseAuth.currentUser?.uid;
    if (currentUid != null) {
      String? imageUrl = user.imagePath;
      
      // Agar rasm lokal fayl bo'lsa, uni Firebase Storage'ga yuklaymiz
      if (user.imagePath != null && !user.imagePath!.startsWith('http')) {
        imageUrl = await _uploadImage(currentUid, user.imagePath!);
      }

      await _firestore.collection('users').doc(currentUid).update({
        'firstName': user.firstName,
        'email': user.email,
        'phone': user.phone,
        'currency': user.currency,
        'imagePath': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<String> _uploadImage(String uid, String path) async {
    final ref = _storage.ref().child('user_images').child('$uid.jpg');
    final uploadTask = await ref.putFile(File(path));
    return await uploadTask.ref.getDownloadURL();
  }

  @override
  Future<void> resetPassword(String email, String newPassword) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _firebaseAuth.currentUser;
    if (user != null && user.email != null) {
      fb_auth.AuthCredential credential = fb_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await localDataSource.clearTokens();
  }

  @override
  Future<String?> refreshToken(String refreshToken) async {
    final user = _firebaseAuth.currentUser;
    return await user?.getIdToken(true);
  }

  @override
  Future<AuthResult> getAuthenticatedUser() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser != null) {
      final userDoc = await _firestore.collection('users').doc(fbUser.uid).get();
      final userData = userDoc.data() ?? {};

      return AuthResult(
        id: fbUser.uid.hashCode,
        username: userData['firstName'] ?? 'User',
        email: fbUser.email ?? '',
        firstName: userData['firstName'] ?? '',
        lastName: '',
        gender: '',
        image: userData['imagePath'] ?? '',
        accessToken: await fbUser.getIdToken() ?? '',
        refreshToken: fbUser.refreshToken ?? '',
        phone: userData['phone'],
        currency: userData['currency'],
      );
    }
    throw Exception('Foydalanuvchi tizimga kirmagan');
  }
}
