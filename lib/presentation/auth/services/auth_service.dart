// lib/core/services/auth_service.dart - Fixed version
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' as flutter_services;
import 'package:google_sign_in/google_sign_in.dart';

import '../errors/auth_exceptions.dart';
import '../models/user_models.dart';
import '../models/user_profile.dart';

/// Interface for authentication service
abstract class IAuthService {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<AuthResult<UserCredential>> signInWithGoogle();
  Future<AuthResult<UserCredential>> signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<AuthResult<UserCredential>> createUserWithEmailAndPassword(
    String email,
    String password,
  );
  Future<AuthResult<void>> signOut();
  Future<AuthResult<void>> sendPasswordResetEmail(String email);
  Future<AuthResult<void>> sendEmailVerification();
  Future<AuthResult<void>> updateUserProfile(UserProfile profile);
  Future<AuthResult<void>> changePassword(
    String currentPassword,
    String newPassword,
  );
  Future<AuthResult<void>> deleteAccount();
  Future<AuthResult<bool>> signInSilently();
  Future<bool> isGoogleSignInAvailable();
  Future<AuthResult<void>> reloadUser();
}

/// Concrete implementation of authentication service
class AuthService implements IAuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<AuthResult<UserCredential>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return AuthResult.failure(
          const AuthException.cancelled('User cancelled Google sign in'),
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      return AuthResult.success(userCredential);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(AuthException.fromFirebaseAuthException(e));
    } on flutter_services.PlatformException catch (e) {
      return AuthResult.failure(AuthException.fromPlatformException(e));
    } catch (e) {
      return AuthResult.failure(AuthException.unknown(e.toString()));
    }
  }

  @override
  Future<AuthResult<UserCredential>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email.trim(), password: password);

      return AuthResult.success(userCredential);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(AuthException.fromFirebaseAuthException(e));
    } on flutter_services.PlatformException catch (e) {
      return AuthResult.failure(AuthException.fromPlatformException(e));
    } catch (e) {
      return AuthResult.failure(AuthException.unknown(e.toString()));
    }
  }

  @override
  Future<AuthResult<UserCredential>> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
      return AuthResult.success(userCredential);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(AuthException.fromFirebaseAuthException(e));
    } on flutter_services.PlatformException catch (e) {
      return AuthResult.failure(AuthException.fromPlatformException(e));
    } catch (e) {
      return AuthResult.failure(AuthException.unknown(e.toString()));
    }
  }

  @override
  Future<AuthResult<void>> signOut() async {
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);

      return const AuthResult.success(null);
    } on flutter_services.PlatformException catch (e) {
      return AuthResult.failure(AuthException.fromPlatformException(e));
    } catch (e) {
      return AuthResult.failure(
        AuthException.unknown('Error during sign out: $e'),
      );
    }
  }

  @override
  Future<AuthResult<void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return const AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(AuthException.fromFirebaseAuthException(e));
    } on flutter_services.PlatformException catch (e) {
      return AuthResult.failure(AuthException.fromPlatformException(e));
    } catch (e) {
      return AuthResult.failure(AuthException.unknown(e.toString()));
    }
  }

  @override
  Future<AuthResult<void>> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return AuthResult.failure(
          const AuthException.userNotFound('No user is currently signed in'),
        );
      }

      if (user.emailVerified) {
        return AuthResult.failure(
          const AuthException.invalidOperation('Email is already verified'),
        );
      }

      await user.sendEmailVerification();
      return const AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(AuthException.fromFirebaseAuthException(e));
    } on flutter_services.PlatformException catch (e) {
      return AuthResult.failure(AuthException.fromPlatformException(e));
    } catch (e) {
      return AuthResult.failure(AuthException.unknown(e.toString()));
    }
  }

  @override
  Future<AuthResult<void>> updateUserProfile(UserProfile profile) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return AuthResult.failure(
          const AuthException.userNotFound('No user is currently signed in'),
        );
      }

      await user.updateDisplayName(profile.displayName);
      if (profile.photoURL != null) {
        await user.updatePhotoURL(profile.photoURL);
      }
      await user.reload();

      return const AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(AuthException.fromFirebaseAuthException(e));
    } on flutter_services.PlatformException catch (e) {
      return AuthResult.failure(AuthException.fromPlatformException(e));
    } catch (e) {
      return AuthResult.failure(AuthException.unknown(e.toString()));
    }
  }

  @override
  Future<AuthResult<void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        return AuthResult.failure(
          const AuthException.userNotFound('No user is currently signed in'),
        );
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      return const AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(AuthException.fromFirebaseAuthException(e));
    } on flutter_services.PlatformException catch (e) {
      return AuthResult.failure(AuthException.fromPlatformException(e));
    } catch (e) {
      return AuthResult.failure(AuthException.unknown(e.toString()));
    }
  }

  @override
  Future<AuthResult<void>> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return AuthResult.failure(
          const AuthException.userNotFound('No user is currently signed in'),
        );
      }

      // Disconnect Google account if linked
      if (user.providerData.any((info) => info.providerId == 'google.com')) {
        await _googleSignIn.disconnect();
      }

      await user.delete();
      return const AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(AuthException.fromFirebaseAuthException(e));
    } on flutter_services.PlatformException catch (e) {
      return AuthResult.failure(AuthException.fromPlatformException(e));
    } catch (e) {
      return AuthResult.failure(AuthException.unknown(e.toString()));
    }
  }

  @override
  Future<AuthResult<bool>> signInSilently() async {
    try {
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signInSilently();

      if (googleUser == null) {
        return const AuthResult.success(false);
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
      return const AuthResult.success(true);
    } on flutter_services.PlatformException catch (e) {
      return const AuthResult.success(false);
    } catch (e) {
      return const AuthResult.success(false);
    }
  }

  @override
  Future<bool> isGoogleSignInAvailable() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      return false;
    }
  }

  /// Disconnect Google account
  Future<AuthResult<void>> disconnectGoogle() async {
    try {
      await _googleSignIn.disconnect();
      await _firebaseAuth.signOut();
      return const AuthResult.success(null);
    } on flutter_services.PlatformException catch (e) {
      return AuthResult.failure(AuthException.fromPlatformException(e));
    } catch (e) {
      return AuthResult.failure(
        AuthException.unknown('Error during disconnect: $e'),
      );
    }
  }

  /// Reload current user
  @override
  Future<AuthResult<void>> reloadUser() async {
    try {
      await _firebaseAuth.currentUser?.reload();
      return const AuthResult.success(null);
    } on flutter_services.PlatformException catch (e) {
      return AuthResult.failure(AuthException.fromPlatformException(e));
    } catch (e) {
      return AuthResult.failure(
        AuthException.unknown('Error reloading user: $e'),
      );
    }
  }

  /// Get detailed user information
  UserProfile? getUserProfile() {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    return UserProfile(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      emailVerified: user.emailVerified,
      phoneNumber: user.phoneNumber,
      isAnonymous: user.isAnonymous,
      creationTime: user.metadata.creationTime,
      lastSignInTime: user.metadata.lastSignInTime,
      providerData:
          user.providerData
              .map(
                (info) => ProviderInfo(
                  providerId: info.providerId,
                  uid: info.uid,
                  displayName: info.displayName,
                  email: info.email,
                  photoURL: info.photoURL,
                ),
              )
              .toList(),
    );
  }
}
