import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  User? _user;
  User? get user => _user; // Getter untuk user

  UserProvider() {
    _user = _auth.currentUser;
  }

  bool get isLoggedIn => _user != null;

  String get name => _user?.displayName ?? "User";
  String get avatar => _user?.photoURL ?? "";
  String get email => _user?.email ?? "";

  // Login Google
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
        "photoUrl": _user?.photoURL,
      }, SetOptions(merge: true));

      notifyListeners();
      return _user;
    } catch (e) {
      debugPrint("Error Google Sign-In: $e");
      return null;
    }
  }

  // **FUNGSI EDIT PROFIL**
  Future<void> updateProfile(String name) async {
    try {
      await _user?.updateDisplayName(name);
      await _firestore.collection('users').doc(_user!.uid).update({
        "name": name,
      });

      _user = _auth.currentUser;
      notifyListeners(); // UPDATE UI
    } catch (e) {
      debugPrint("Error updating profile: $e");
    }
  }

  Future<String> uploadImageToFirebase(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef
          .child("avatars/${DateTime.now().millisecondsSinceEpoch}.jpg");

      await imageRef.putFile(imageFile);
      return await imageRef.getDownloadURL(); // Dapatkan URL gambar baru
    } catch (e) {
      debugPrint("Error uploading image: $e");
      return "";
    }
  }

  Future<void> updateAvatar(String newAvatar) async {
    try {
      if (_user != null) {
        // Update photoURL di Firebase Authentication
        await _user!.updatePhotoURL(newAvatar);

        // Update Firestore
        await _firestore.collection('users').doc(_user!.uid).update({
          "photoUrl": newAvatar,
        });

        // Refresh user data
        _user = _auth.currentUser;
        notifyListeners(); // Update UI
      }
    } catch (e) {
      debugPrint("Error updating avatar: $e");
    }
  }

  // Logout
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    await _storage.erase();
    _user = null;
    notifyListeners();
  }
}
