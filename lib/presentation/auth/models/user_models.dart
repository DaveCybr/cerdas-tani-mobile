// lib/core/models/auth_result.dart
import 'package:flutter/foundation.dart';
import '../errors/auth_exceptions.dart';

/// Generic result wrapper for authentication operations
@immutable
sealed class AuthResult<T> {
  const AuthResult();

  const factory AuthResult.success(T data) = AuthSuccess<T>;
  const factory AuthResult.failure(AuthException error) = AuthFailure<T>;

  bool get isSuccess => this is AuthSuccess<T>;
  bool get isFailure => this is AuthFailure<T>;

  T? get data => switch (this) {
    AuthSuccess<T> success => success.data,
    AuthFailure<T> _ => null,
  };

  AuthException? get error => switch (this) {
    AuthSuccess<T> _ => null,
    AuthFailure<T> failure => failure.error,
  };

  /// Fold pattern for handling both success and failure cases
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AuthException error) onFailure,
  }) {
    return switch (this) {
      AuthSuccess<T> success => onSuccess(success.data),
      AuthFailure<T> failure => onFailure(failure.error),
    };
  }

  /// Map the success value to a new type
  AuthResult<R> map<R>(R Function(T data) mapper) {
    return switch (this) {
      AuthSuccess<T> success => AuthResult.success(mapper(success.data)),
      AuthFailure<T> failure => AuthResult.failure(failure.error),
    };
  }

  /// FlatMap for chaining operations
  AuthResult<R> flatMap<R>(AuthResult<R> Function(T data) mapper) {
    return switch (this) {
      AuthSuccess<T> success => mapper(success.data),
      AuthFailure<T> failure => AuthResult.failure(failure.error),
    };
  }
}

final class AuthSuccess<T> extends AuthResult<T> {
  final T data;

  const AuthSuccess(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSuccess<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'AuthSuccess(data: $data)';
}

final class AuthFailure<T> extends AuthResult<T> {
  final AuthException error;

  const AuthFailure(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthFailure<T> &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'AuthFailure(error: $error)';
}
