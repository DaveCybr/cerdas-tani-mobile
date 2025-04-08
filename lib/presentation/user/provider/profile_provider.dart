import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  String _name = "";
  String _email = "";
  String _avatar = "";

  String get name => _name;
  String get email => _email;
  String get avatar => _avatar;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  // Call this after login
  Future<void> loadUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final doc = await _firestore.collection('users').doc(uid).get();
      _name = doc['name'];
      _email = doc['email'];
      _avatar = doc['avatar'];
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String name,
    Uint8List? newAvatarBytes,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    String avatarUrl = _avatar;

    if (newAvatarBytes != null) {
      final ref = _storage.ref().child('avatars/$uid.jpg');
      await ref.putData(
          newAvatarBytes, SettableMetadata(contentType: 'image/jpeg'));
      avatarUrl = await ref.getDownloadURL();
    }

    await _firestore.collection('users').doc(uid).update({
      'name': name,
      'avatar': avatarUrl,
    });

    _name = name;
    _avatar = avatarUrl;
    notifyListeners();
  }
}
