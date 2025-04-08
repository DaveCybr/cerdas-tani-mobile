import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? _user;
  Map<String, dynamic>? _userData;

  UserProvider() {
    _user = _auth.currentUser;
    if (_user != null) {
      _loadUserData();
    }
  }

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  String get name => _userData?['name'] ?? _user?.displayName ?? "User";
  String get avatar => _userData?['avatar'] ?? _user?.photoURL ?? "";
  String get email => _user?.email ?? "";

  Future<void> _loadUserData() async {
    if (_user != null) {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _userData = doc.data();
        notifyListeners();
      }
    }
  }

  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      // Simpan data user ke Firestore
      await _firestore.collection('users').doc(_user!.uid).set({
        "name": _user?.displayName,
        "email": _user?.email,
        "avatar": _user?.photoURL,
      }, SetOptions(merge: true));

      await _loadUserData();
      notifyListeners();
      return _user;
    } catch (e) {
      debugPrint("Error Google Sign-In: $e");
      return null;
    }
  }

  Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Signup ke Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;

      // Simpan data awal user ke Firestore
      await _firestore.collection('users').doc(_user!.uid).set({
        'email': email,
        'name': 'User',
        'photoUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      notifyListeners();
      return _user;
    } catch (e) {
      debugPrint("Error Sign Up: $e");
      rethrow; // biar error-nya bisa ditangani di UI
    }
  }

  Future<void> updateProfile({
    required String name,
    Uint8List? newAvatarBytes,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    String avatarUrl = avatar;

    if (newAvatarBytes != null) {
      try {
        final ref = _storage.ref().child('avatars/$uid.jpg');

        // Upload data ke Firebase Storage
        final uploadTask = await ref.putData(
          newAvatarBytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );

        // Pastikan file sudah berhasil di-upload sebelum ambil URL
        avatarUrl = await ref.getDownloadURL();
      } catch (e) {
        debugPrint("Upload avatar failed: $e");
        rethrow;
      }
    }

    // Update ke Firestore
    await _firestore.collection('users').doc(uid).update({
      'name': name,
      'avatar': avatarUrl,
      'photoUrl': avatarUrl,
    });

    // Update local state dan notify
    _userData ??= {};
    _userData!['name'] = name;
    _userData!['avatar'] = avatarUrl;
    _userData!['photoUrl'] = avatarUrl;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _user = null;
    _userData = null;
    notifyListeners();
  }
}
