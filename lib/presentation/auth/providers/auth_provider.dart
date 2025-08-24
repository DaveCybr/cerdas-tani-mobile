// presentation/auth/providers/auth_provider.dart - FIXED VERSION
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../core/utils/validator.dart';
import '../errors/auth_exceptions.dart';
import '../models/user_models.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final IAuthService _authService;
  StreamSubscription<User?>? _authStateSubscription;

  User? _user;
  AuthStatus _status = AuthStatus.initial;
  AuthException? _error;
  bool _isReloading = false;

  // Loading states
  bool _isAuthenticating = false;
  bool _shouldShowOverlay = false;

  // Getters
  User? get user => _user;
  AuthStatus get status => _status;
  AuthException? get error => _error;

  // SIMPLIFIED: Only check if user is authenticated (no email verification)
  bool get isAuthenticated {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final isAuth =
        _status == AuthStatus.authenticated &&
        _user != null &&
        firebaseUser != null;
    debugPrint(
      'isAuthenticated: $isAuth (status: $_status, user: ${_user?.email})',
    );
    return isAuth;
  }

  bool get isUnauthenticated => _status == AuthStatus.unauthenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticating => _isAuthenticating;
  bool get shouldShowOverlay => _shouldShowOverlay;
  bool get hasError => _error != null;

  String? get email => _user?.email;
  String? get displayName => _user?.displayName;
  String? get photoURL => _user?.photoURL;
  String? get uid => _user?.uid;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  AuthProvider({IAuthService? authService})
    : _authService = authService ?? AuthService() {
    _initialize();
  }

  void _initialize() {
    _user = _authService.currentUser;
    _determineAuthStatus();

    _authStateSubscription = _authService.authStateChanges.listen(
      _onAuthStateChanged,
    );
  }

  void _determineAuthStatus() {
    if (_user == null) {
      _status = AuthStatus.unauthenticated;
    } else {
      // Authenticate user if they exist, regardless of email verification
      _status = AuthStatus.authenticated;
    }
  }

  void _onAuthStateChanged(User? user) {
    if (_isReloading) return;

    debugPrint('Auth state changed: ${user?.email ?? 'null'}');

    _user = user;
    _determineAuthStatus();
    _clearError();

    if (!_isAuthenticating) {
      notifyListeners();
    }
  }

  void _setOverlayState(bool show) {
    if (_shouldShowOverlay != show) {
      _shouldShowOverlay = show;
      notifyListeners();
    }
  }

  Future<bool> _executeAuthOperation<T>(
    Future<AuthResult<T>> Function() operation,
  ) async {
    _clearError();
    _setAuthenticating(true);

    try {
      final result = await operation();

      return result.fold(
        onSuccess: (_) {
          _setAuthenticating(false);
          return true;
        },
        onFailure: (error) {
          _setAuthenticating(false);
          _setError(error);
          return false;
        },
      );
    } catch (e) {
      _setAuthenticating(false);
      _setError(AuthException.unknown(e.toString()));
      return false;
    }
  }

  void _setError(AuthException error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      if (!_isAuthenticating) {
        notifyListeners();
      }
    }
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // Method untuk check initial auth state
  Future<void> checkInitialAuthState() async {
    debugPrint('Checking initial auth state...');
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final currentUser = FirebaseAuth.instance.currentUser;
      debugPrint('Current Firebase user: ${currentUser?.email ?? 'null'}');

      if (currentUser != null) {
        _user = currentUser;
        _status = AuthStatus.authenticated;
        debugPrint('Initial auth state: authenticated');
      } else {
        _user = null;
        _status = AuthStatus.unauthenticated;
        debugPrint('Initial auth state: unauthenticated');
      }
    } catch (e) {
      debugPrint('Error checking initial auth state: $e');
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  void _setAuthenticating(bool value) {
    if (_isAuthenticating != value) {
      _isAuthenticating = value;
      _setOverlayState(_isAuthenticating);
      debugPrint('Authentication status changed: $value');
    }
  }

  /// Register with email and password
  Future<bool> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final emailError = AuthValidators.validateEmail(email);
    if (emailError != null) {
      _setError(AuthException.invalidEmail(emailError));
      return false;
    }

    final passwordError = AuthValidators.validatePassword(password);
    if (passwordError != null) {
      _setError(AuthException.weakPassword(passwordError));
      return false;
    }

    if (displayName != null) {
      final displayNameError = AuthValidators.validateDisplayName(displayName);
      if (displayNameError != null) {
        _setError(AuthException.invalidDisplayName(displayNameError));
        return false;
      }
    }

    return _executeAuthOperation(() async {
      final result = await _authService.createUserWithEmailAndPassword(
        email,
        password,
      );

      if (result.isSuccess) {
        // Update display name if provided
        if (displayName != null) {
          await _authService.updateUserProfile(
            UserProfile(displayName: displayName),
          );
        }

        debugPrint('Registration successful');
      }

      return result;
    });
  }

  /// Sign in with email and password
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final emailError = AuthValidators.validateEmail(email);
    if (emailError != null) {
      _setError(AuthException.invalidEmail(emailError));
      return false;
    }

    final passwordError = AuthValidators.validatePassword(password);
    if (passwordError != null) {
      _setError(AuthException.weakPassword(passwordError));
      return false;
    }

    return _executeAuthOperation(() async {
      final result = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (result.isSuccess) {
        debugPrint('Sign in successful');
      }

      return result;
    });
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    return _executeAuthOperation(() => _authService.signInWithGoogle());
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail({required String email}) async {
    final emailError = AuthValidators.validateEmail(email);
    if (emailError != null) {
      _setError(AuthException.invalidEmail(emailError));
      return false;
    }

    return _executeAuthOperation(
      () => _authService.sendPasswordResetEmail(email),
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _executeAuthOperation(() => _authService.signOut());
  }

  /// Delete account
  Future<bool> deleteAccount() async {
    return _executeAuthOperation(() => _authService.deleteAccount());
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final currentPasswordError = AuthValidators.validatePassword(
      currentPassword,
    );
    if (currentPasswordError != null) {
      _setError(AuthException.weakPassword(currentPasswordError));
      return false;
    }

    final newPasswordError = AuthValidators.validatePassword(newPassword);
    if (newPasswordError != null) {
      _setError(AuthException.weakPassword(newPasswordError));
      return false;
    }

    return _executeAuthOperation(
      () => _authService.changePassword(currentPassword, newPassword),
    );
  }

  /// Update user profile
  Future<bool> updateProfile({String? displayName, String? photoURL}) async {
    if (displayName != null) {
      final displayNameError = AuthValidators.validateDisplayName(displayName);
      if (displayNameError != null) {
        _setError(AuthException.invalidDisplayName(displayNameError));
        return false;
      }
    }

    return _executeAuthOperation(
      () => _authService.updateUserProfile(
        UserProfile(displayName: displayName, photoURL: photoURL),
      ),
    );
  }

  /// Reload user data
  Future<bool> reloadUser() async {
    if (_isReloading) return false;

    _isReloading = true;
    _clearError();

    try {
      final result = await _authService.reloadUser();

      return result.fold(
        onSuccess: (_) {
          final currentUser = _authService.currentUser;
          _user = currentUser;
          _determineAuthStatus();

          _isReloading = false;
          notifyListeners();
          return true;
        },
        onFailure: (error) {
          _setError(error);
          _isReloading = false;
          return false;
        },
      );
    } catch (e) {
      _setError(AuthException.unknown(e.toString()));
      _isReloading = false;
      return false;
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
