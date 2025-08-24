// lib/core/utils/validators.dart
/// Validation utility class for authentication
class AuthValidators {
  AuthValidators._();

  /// Email validation regex pattern
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validate email address
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }

    final trimmedEmail = email.trim();

    if (!_emailRegex.hasMatch(trimmedEmail)) {
      return 'Format email tidak valid';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    if (password.length < 6) {
      return 'Password minimal 6 karakter';
    }

    // Additional password strength validation (optional)
    if (!_hasValidPasswordStrength(password)) {
      return 'Password harus mengandung huruf dan angka';
    }

    return null;
  }

  /// Validate password confirmation
  static String? validateConfirmPassword(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }

    if (password != confirmPassword) {
      return 'Password tidak sama';
    }

    return null;
  }

  /// Validate display name
  static String? validateDisplayName(String? displayName) {
    if (displayName == null || displayName.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }

    final trimmedName = displayName.trim();

    if (trimmedName.length < 2) {
      return 'Nama minimal 2 karakter';
    }

    if (trimmedName.length > 50) {
      return 'Nama maksimal 50 karakter';
    }

    // Check for invalid characters
    if (!_hasValidNameCharacters(trimmedName)) {
      return 'Nama hanya boleh mengandung huruf, angka, dan spasi';
    }

    return null;
  }

  /// Validate phone number (Indonesian format)
  static String? validatePhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      return null; // Phone number is optional
    }

    final trimmedPhone = phoneNumber.trim().replaceAll(RegExp(r'[^\d+]'), '');

    // Indonesian phone number patterns
    final indonesianPhoneRegex = RegExp(r'^(\+62|62|0)[0-9]{8,13}$');

    if (!indonesianPhoneRegex.hasMatch(trimmedPhone)) {
      return 'Format nomor telepon tidak valid';
    }

    return null;
  }

  /// Check if password has minimum strength requirements
  static bool _hasValidPasswordStrength(String password) {
    // At least one letter and one number
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);

    return hasLetter && hasNumber;
  }

  /// Check if name contains only valid characters
  static bool _hasValidNameCharacters(String name) {
    // Allow letters, numbers, spaces, hyphens, and apostrophes
    final validNameRegex = RegExp(r"^[a-zA-Z0-9\s\-'\.]+$");
    return validNameRegex.hasMatch(name);
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(
    String? value,
    int minLength,
    String fieldName,
  ) {
    if (value == null) return null;

    if (value.length < minLength) {
      return '$fieldName minimal $minLength karakter';
    }
    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(
    String? value,
    int maxLength,
    String fieldName,
  ) {
    if (value == null) return null;

    if (value.length > maxLength) {
      return '$fieldName maksimal $maxLength karakter';
    }
    return null;
  }

  /// Combine multiple validators
  static String? combineValidators(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  /// Validate URL format
  static String? validateUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return null; // URL is optional
    }

    try {
      final uri = Uri.parse(url.trim());
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return 'Format URL tidak valid';
      }
      return null;
    } catch (e) {
      return 'Format URL tidak valid';
    }
  }

  /// Check if string contains only alphanumeric characters
  static bool isAlphanumeric(String value) {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value);
  }

  /// Check if string is a valid Indonesian postal code
  static String? validatePostalCode(String? postalCode) {
    if (postalCode == null || postalCode.trim().isEmpty) {
      return null; // Postal code is optional
    }

    final trimmedCode = postalCode.trim();
    final postalCodeRegex = RegExp(r'^\d{5}$');

    if (!postalCodeRegex.hasMatch(trimmedCode)) {
      return 'Kode pos harus 5 digit angka';
    }

    return null;
  }

  /// Sanitize input string
  static String sanitizeInput(String? input) {
    if (input == null) return '';
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Check if password is commonly used (basic check)
  static bool isCommonPassword(String password) {
    final commonPasswords = [
      '123456',
      'password',
      '123456789',
      '12345678',
      'qwerty',
      'abc123',
      'password123',
      'admin',
    ];

    return commonPasswords.contains(password.toLowerCase());
  }

  /// Advanced password validation with detailed feedback
  static Map<String, bool> getPasswordStrengthDetails(String password) {
    return {
      'hasMinLength': password.length >= 6,
      'hasMaxLength': password.length <= 128,
      'hasLowercase': RegExp(r'[a-z]').hasMatch(password),
      'hasUppercase': RegExp(r'[A-Z]').hasMatch(password),
      'hasNumber': RegExp(r'\d').hasMatch(password),
      'hasSpecialChar': RegExp(r'[!@#\$&*~]').hasMatch(password),
      'isNotCommon': !isCommonPassword(password),
    };
  }

  /// Calculate password strength score (0-100)
  static int calculatePasswordStrength(String password) {
    final details = getPasswordStrengthDetails(password);
    int score = 0;

    if (details['hasMinLength']!) score += 20;
    if (details['hasLowercase']!) score += 15;
    if (details['hasUppercase']!) score += 15;
    if (details['hasNumber']!) score += 15;
    if (details['hasSpecialChar']!) score += 20;
    if (details['isNotCommon']!) score += 15;

    return score;
  }

  /// Get password strength label
  static String getPasswordStrengthLabel(int score) {
    if (score < 30) return 'Sangat Lemah';
    if (score < 50) return 'Lemah';
    if (score < 70) return 'Sedang';
    if (score < 90) return 'Kuat';
    return 'Sangat Kuat';
  }
}
