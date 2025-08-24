// lib/core/models/user_profile.dart
import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;
  final String? phoneNumber;
  final bool isAnonymous;
  final DateTime? creationTime;
  final DateTime? lastSignInTime;
  final List<ProviderInfo> providerData;

  const UserProfile({
    this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.emailVerified = false,
    this.phoneNumber,
    this.isAnonymous = false,
    this.creationTime,
    this.lastSignInTime,
    this.providerData = const [],
  });

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    bool? emailVerified,
    String? phoneNumber,
    bool? isAnonymous,
    DateTime? creationTime,
    DateTime? lastSignInTime,
    List<ProviderInfo>? providerData,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      creationTime: creationTime ?? this.creationTime,
      lastSignInTime: lastSignInTime ?? this.lastSignInTime,
      providerData: providerData ?? this.providerData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'emailVerified': emailVerified,
      'phoneNumber': phoneNumber,
      'isAnonymous': isAnonymous,
      'creationTime': creationTime?.toIso8601String(),
      'lastSignInTime': lastSignInTime?.toIso8601String(),
      'providerData': providerData.map((e) => e.toJson()).toList(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String?,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      phoneNumber: json['phoneNumber'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      creationTime:
          json['creationTime'] != null
              ? DateTime.parse(json['creationTime'] as String)
              : null,
      lastSignInTime:
          json['lastSignInTime'] != null
              ? DateTime.parse(json['lastSignInTime'] as String)
              : null,
      providerData:
          (json['providerData'] as List<dynamic>?)
              ?.map((e) => ProviderInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          displayName == other.displayName &&
          photoURL == other.photoURL &&
          emailVerified == other.emailVerified &&
          phoneNumber == other.phoneNumber &&
          isAnonymous == other.isAnonymous &&
          creationTime == other.creationTime &&
          lastSignInTime == other.lastSignInTime &&
          listEquals(providerData, other.providerData);

  @override
  int get hashCode => Object.hash(
    uid,
    email,
    displayName,
    photoURL,
    emailVerified,
    phoneNumber,
    isAnonymous,
    creationTime,
    lastSignInTime,
    Object.hashAll(providerData),
  );

  @override
  String toString() {
    return 'UserProfile(uid: $uid, email: $email, displayName: $displayName, '
        'photoURL: $photoURL, emailVerified: $emailVerified, '
        'phoneNumber: $phoneNumber, isAnonymous: $isAnonymous, '
        'creationTime: $creationTime, lastSignInTime: $lastSignInTime, '
        'providerData: $providerData)';
  }
}

@immutable
class ProviderInfo {
  final String providerId;
  final String? uid;
  final String? displayName;
  final String? email;
  final String? photoURL;

  const ProviderInfo({
    required this.providerId,
    this.uid,
    this.displayName,
    this.email,
    this.photoURL,
  });

  ProviderInfo copyWith({
    String? providerId,
    String? uid,
    String? displayName,
    String? email,
    String? photoURL,
  }) {
    return ProviderInfo(
      providerId: providerId ?? this.providerId,
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
    };
  }

  factory ProviderInfo.fromJson(Map<String, dynamic> json) {
    return ProviderInfo(
      providerId: json['providerId'] as String,
      uid: json['uid'] as String?,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      photoURL: json['photoURL'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderInfo &&
          runtimeType == other.runtimeType &&
          providerId == other.providerId &&
          uid == other.uid &&
          displayName == other.displayName &&
          email == other.email &&
          photoURL == other.photoURL;

  @override
  int get hashCode =>
      Object.hash(providerId, uid, displayName, email, photoURL);

  @override
  String toString() {
    return 'ProviderInfo(providerId: $providerId, uid: $uid, '
        'displayName: $displayName, email: $email, photoURL: $photoURL)';
  }
}
