// lib/core/errors/auth_exceptions.dart - Cleaned up version
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' as flutter_services;

/// Custom authentication exception class
@immutable
sealed class AuthException implements Exception {
  final String message;
  final String code;

  const AuthException(this.message, this.code);

  // Specific exception types
  const factory AuthException.userNotFound(String message) =
      UserNotFoundException;
  const factory AuthException.wrongPassword(String message) =
      WrongPasswordException;
  const factory AuthException.emailAlreadyInUse(String message) =
      EmailAlreadyInUseException;
  const factory AuthException.weakPassword(String message) =
      WeakPasswordException;
  const factory AuthException.invalidEmail(String message) =
      InvalidEmailException;
  const factory AuthException.userDisabled(String message) =
      UserDisabledException;
  const factory AuthException.tooManyRequests(String message) =
      TooManyRequestsException;
  const factory AuthException.operationNotAllowed(String message) =
      OperationNotAllowedException;
  const factory AuthException.requiresRecentLogin(String message) =
      RequiresRecentLoginException;
  const factory AuthException.invalidCredential(String message) =
      InvalidCredentialException;
  const factory AuthException.networkRequestFailed(String message) =
      NetworkRequestFailedException;
  const factory AuthException.cancelled(String message) = CancelledException;
  const factory AuthException.platform(String message) = AuthPlatformException;
  const factory AuthException.unknown(String message) = UnknownException;
  const factory AuthException.invalidDisplayName(String message) =
      InvalidDisplayNameException;
  const factory AuthException.invalidOperation(String message) =
      InvalidOperationException;
  const factory AuthException.invalidVerificationCode(String message) =
      InvalidVerificationCodeException;

  /// Create AuthException from FirebaseAuthException
  factory AuthException.fromFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthException.userNotFound('Email tidak terdaftar');
      case 'wrong-password':
        return const AuthException.wrongPassword('Password salah');
      case 'email-already-in-use':
        return const AuthException.emailAlreadyInUse('Email sudah digunakan');
      case 'weak-password':
        return const AuthException.weakPassword(
          'Password terlalu lemah. Minimal 6 karakter.',
        );
      case 'invalid-email':
        return const AuthException.invalidEmail('Format email tidak valid');
      case 'user-disabled':
        return const AuthException.userDisabled('Akun telah dinonaktifkan');
      case 'too-many-requests':
        return const AuthException.tooManyRequests(
          'Terlalu banyak percobaan, coba lagi nanti',
        );
      case 'operation-not-allowed':
        return const AuthException.operationNotAllowed(
          'Operasi tidak diizinkan',
        );
      case 'requires-recent-login':
        return const AuthException.requiresRecentLogin(
          'Silakan login ulang untuk melakukan operasi ini',
        );
      case 'invalid-credential':
        return const AuthException.invalidCredential('Kredensial tidak valid');
      case 'network-request-failed':
        return const AuthException.networkRequestFailed(
          'Tidak ada koneksi internet',
        );
      case 'account-exists-with-different-credential':
        return const AuthException.invalidCredential(
          'Akun sudah ada dengan metode login yang berbeda',
        );
      case 'invalid-verification-code':
        return const AuthException.invalidVerificationCode(
          'Kode verifikasi tidak valid',
        );
      case 'invalid-verification-id':
        return const AuthException.invalidCredential(
          'ID verifikasi tidak valid',
        );
      case 'credential-already-in-use':
        return const AuthException.invalidCredential(
          'Kredensial sudah digunakan akun lain',
        );
      case 'provider-already-linked':
        return const AuthException.invalidOperation(
          'Provider sudah terhubung dengan akun ini',
        );
      case 'no-such-provider':
        return const AuthException.invalidOperation('Provider tidak ditemukan');
      case 'invalid-user-token':
        return const AuthException.invalidCredential('Token user tidak valid');
      case 'expired-action-code':
        return const AuthException.invalidCredential(
          'Kode aksi telah kedaluwarsa',
        );
      case 'invalid-action-code':
        return const AuthException.invalidCredential('Kode aksi tidak valid');
      case 'user-token-expired':
        return const AuthException.invalidCredential(
          'Token user telah kedaluwarsa',
        );
      case 'missing-email':
        return const AuthException.invalidEmail('Email tidak boleh kosong');
      case 'missing-password':
        return const AuthException.weakPassword('Password tidak boleh kosong');
      case 'email-not-verified':
        return const AuthException.invalidOperation('Email belum diverifikasi');
      default:
        return AuthException.unknown(
          e.message ?? 'Terjadi kesalahan tidak dikenal',
        );
    }
  }

  /// Create AuthException from PlatformException
  factory AuthException.fromPlatformException(
    flutter_services.PlatformException e,
  ) {
    switch (e.code) {
      case 'ERROR_EMAIL_ALREADY_IN_USE':
        return const AuthException.emailAlreadyInUse('Email sudah digunakan');
      case 'ERROR_WEAK_PASSWORD':
        return const AuthException.weakPassword('Password terlalu lemah');
      case 'ERROR_INVALID_EMAIL':
        return const AuthException.invalidEmail('Format email tidak valid');
      case 'ERROR_USER_NOT_FOUND':
        return const AuthException.userNotFound('Email tidak terdaftar');
      case 'ERROR_WRONG_PASSWORD':
        return const AuthException.wrongPassword('Password salah');
      case 'ERROR_USER_DISABLED':
        return const AuthException.userDisabled('Akun telah dinonaktifkan');
      case 'ERROR_TOO_MANY_REQUESTS':
        return const AuthException.tooManyRequests(
          'Terlalu banyak percobaan, coba lagi nanti',
        );
      case 'ERROR_OPERATION_NOT_ALLOWED':
        return const AuthException.operationNotAllowed(
          'Operasi tidak diizinkan',
        );
      case 'ERROR_REQUIRES_RECENT_LOGIN':
        return const AuthException.requiresRecentLogin(
          'Silakan login ulang untuk melakukan operasi ini',
        );
      case 'ERROR_INVALID_CREDENTIAL':
        return const AuthException.invalidCredential('Kredensial tidak valid');
      case 'ERROR_NETWORK_REQUEST_FAILED':
        return const AuthException.networkRequestFailed(
          'Tidak ada koneksi internet',
        );
      case 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL':
        return const AuthException.invalidCredential(
          'Akun sudah ada dengan metode login yang berbeda',
        );
      case 'ERROR_INVALID_VERIFICATION_CODE':
        return const AuthException.invalidVerificationCode(
          'Kode verifikasi tidak valid',
        );
      case 'ERROR_INVALID_VERIFICATION_ID':
        return const AuthException.invalidCredential(
          'ID verifikasi tidak valid',
        );
      case 'ERROR_CREDENTIAL_ALREADY_IN_USE':
        return const AuthException.invalidCredential(
          'Kredensial sudah digunakan akun lain',
        );
      case 'sign_in_canceled':
        return const AuthException.cancelled('Proses login dibatalkan');
      case 'network_error':
        return const AuthException.networkRequestFailed(
          'Tidak ada koneksi internet',
        );
      default:
        return AuthException.platform(
          e.message ?? 'Terjadi kesalahan platform: ${e.code}',
        );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthException &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => Object.hash(message, code);

  @override
  String toString() => 'AuthException(message: $message, code: $code)';
}

// Specific exception implementations
final class UserNotFoundException extends AuthException {
  const UserNotFoundException(String message)
    : super(message, 'user-not-found');
}

final class WrongPasswordException extends AuthException {
  const WrongPasswordException(String message)
    : super(message, 'wrong-password');
}

final class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException(String message)
    : super(message, 'email-already-in-use');
}

final class WeakPasswordException extends AuthException {
  const WeakPasswordException(String message) : super(message, 'weak-password');
}

final class InvalidEmailException extends AuthException {
  const InvalidEmailException(String message) : super(message, 'invalid-email');
}

final class UserDisabledException extends AuthException {
  const UserDisabledException(String message) : super(message, 'user-disabled');
}

final class TooManyRequestsException extends AuthException {
  const TooManyRequestsException(String message)
    : super(message, 'too-many-requests');
}

final class OperationNotAllowedException extends AuthException {
  const OperationNotAllowedException(String message)
    : super(message, 'operation-not-allowed');
}

final class RequiresRecentLoginException extends AuthException {
  const RequiresRecentLoginException(String message)
    : super(message, 'requires-recent-login');
}

final class InvalidCredentialException extends AuthException {
  const InvalidCredentialException(String message)
    : super(message, 'invalid-credential');
}

final class NetworkRequestFailedException extends AuthException {
  const NetworkRequestFailedException(String message)
    : super(message, 'network-request-failed');
}

final class CancelledException extends AuthException {
  const CancelledException(String message) : super(message, 'cancelled');
}

final class AuthPlatformException extends AuthException {
  const AuthPlatformException(String message)
    : super(message, 'platform-error');
}

final class UnknownException extends AuthException {
  const UnknownException(String message) : super(message, 'unknown');
}

final class InvalidDisplayNameException extends AuthException {
  const InvalidDisplayNameException(String message)
    : super(message, 'invalid-display-name');
}

final class InvalidOperationException extends AuthException {
  const InvalidOperationException(String message)
    : super(message, 'invalid-operation');
}

final class InvalidVerificationCodeException extends AuthException {
  const InvalidVerificationCodeException(String message)
    : super(message, 'invalid-verification-code');
}
