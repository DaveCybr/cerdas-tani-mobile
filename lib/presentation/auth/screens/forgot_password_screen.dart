// lib/presentation/auth/screens/forgot_password_screen.dart

import 'dart:async';
import 'package:fertilizer_calculator_mobile_v2/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validator.dart';
import '../providers/auth_provider.dart';
import '../widgets/text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isFormValid = false;
  bool _isLoading = false;
  bool _emailSent = false;
  int _resendCountdown = 0;
  Timer? _countdownTimer;
  String? _lastSentEmail;

  static const int _resendCooldownSeconds = 60;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);

    // ✅ CLEAR ERROR SAAT MASUK HALAMAN INI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearError();
    });
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateForm);
    _emailController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _emailController.text.trim().isNotEmpty;

    if (_isFormValid != isValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  void _startResendCountdown() {
    setState(() {
      _resendCountdown = _resendCooldownSeconds;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCountdown--;
      });

      if (_resendCountdown <= 0) {
        timer.cancel();
      }
    });
  }

  Future<void> _handleSendResetEmail(
    AuthProvider authProvider, {
    bool isResend = false,
  }) async {
    setState(() => _isLoading = true);
    authProvider.clearError();

    if (!_formKey.currentState!.validate()) {
      setState(() => _isLoading = false);
      return;
    }

    final email = _emailController.text.trim();

    try {
      final success = await authProvider.sendPasswordResetEmail(email: email);

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          setState(() {
            _emailSent = true;
            _lastSentEmail = email;
          });

          _startResendCountdown();

          _showSuccessSnackBar(
            isResend
                ? 'Reset email sent again! Check your inbox.'
                : 'Password reset email sent! Check your inbox.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleResendEmail(AuthProvider authProvider) async {
    if (_resendCountdown > 0 || _isLoading) return;
    await _handleSendResetEmail(authProvider, isResend: true);
  }

  void _handleBackToLogin() {
    // ✅ CLEAR ERROR SEBELUM NAVIGASI KEMBALI
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();
    Navigator.pop(context);
  }

  void _handleTryDifferentEmail() {
    setState(() {
      _emailSent = false;
      _lastSentEmail = null;
      _emailController.clear();
    });
    _countdownTimer?.cancel();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String? _validateEmail(String? value) {
    return AuthValidators.validateEmail(value);
  }

  String _formatCountdown(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: _isLoading ? null : _handleBackToLogin,
          icon: Icon(
            IconlyBroken.arrow_left_2,
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? (_isLoading ? Colors.grey : Colors.white)
                    : (_isLoading ? Colors.grey : AppColors.darkText),
          ),
        ),
        title: Text(
          'Forgot Password',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.darkText,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),

                        // Illustration/Icon
                        Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _emailSent
                                  ? IconlyBroken.tick_square
                                  : IconlyBroken.message,
                              size: 60,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Title and Description
                        Center(
                          child: Column(
                            children: [
                              Text(
                                _emailSent
                                    ? 'Check Your Email'
                                    : 'Forgot Password?',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineLarge?.copyWith(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _emailSent
                                    ? "We've sent a password reset link to\n$_lastSentEmail"
                                    : "Don't worry! It happens. Please enter the email address associated with your account.",
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(height: 1.5),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Error Message Display - ✅ HANYA TAMPIL JIKA ADA ERROR DI HALAMAN INI
                        if (authProvider.hasError) ...[
                          _buildErrorContainer(authProvider),
                          const SizedBox(height: 20),
                        ],

                        // Success Message Display (when email sent)
                        if (_emailSent) ...[
                          _buildSuccessContainer(),
                          const SizedBox(height: 20),
                          _buildEmailInstructions(),
                          const SizedBox(height: 30),
                        ],

                        // Email Field (hide if email is sent successfully)
                        if (!_emailSent) ...[
                          CustomTextFormFild(
                            hint: "Enter your email address",
                            controller: _emailController,
                            prefixIcon: IconlyBroken.message,
                            validator: _validateEmail,
                            enabled: !_isLoading,
                          ),
                          const SizedBox(height: 30),
                        ],

                        // Send Reset Email Button or Resend Button
                        if (!_emailSent) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () =>
                                          _handleSendResetEmail(authProvider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                disabledBackgroundColor: const Color(
                                  0xFF10B981,
                                ).withOpacity(0.6),
                              ),
                              child:
                                  _isLoading
                                      ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Sending...',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )
                                      : Text(
                                        'Send Reset Link',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ),
                        ] else ...[
                          // Resend Email Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  (_resendCountdown > 0 || _isLoading)
                                      ? null
                                      : () => _handleResendEmail(authProvider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _resendCountdown > 0
                                        ? Colors.grey.shade300
                                        : const Color(0xFF10B981),
                                foregroundColor:
                                    _resendCountdown > 0
                                        ? Colors.grey.shade600
                                        : Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child:
                                  _isLoading
                                      ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Resending...',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )
                                      : Text(
                                        _resendCountdown > 0
                                            ? 'Resend in ${_formatCountdown(_resendCountdown)}'
                                            : 'Resend Email',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // Try Different Email Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              onPressed:
                                  _isLoading ? null : _handleTryDifferentEmail,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                side: BorderSide(
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white.withOpacity(0.3)
                                          : Colors.grey.shade300,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                disabledForegroundColor: Colors.grey,
                              ),
                              child: Text(
                                'Try Different Email',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      _isLoading
                                          ? Colors.grey
                                          : Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : AppColors.darkText,
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Back to Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _handleBackToLogin,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              side: BorderSide(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white.withOpacity(0.3)
                                        : Colors.grey.shade300,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              disabledForegroundColor: Colors.grey,
                            ),
                            child: Text(
                              'Back to Login',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color:
                                    _isLoading
                                        ? Colors.grey
                                        : Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : AppColors.darkText,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),

              // Full screen overlay loading
              if (authProvider.shouldShowOverlay)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _emailSent
                                ? 'Resending Email'
                                : 'Sending Reset Email',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please wait...',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorContainer(AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reset Failed',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  authProvider.error?.message ?? 'An error occurred',
                  style: TextStyle(color: Colors.red.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: authProvider.clearError,
            icon: Icon(Icons.close, color: AppColors.danger),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email Sent Successfully',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Check your email for the password reset link.',
                  style: TextStyle(color: Colors.green.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade700
                  : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                IconlyBroken.info_square,
                size: 20,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'Next Steps',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '1. Check your email inbox (and spam folder)\n'
            '2. Click the reset link in the email\n'
            '3. Enter your new password\n'
            '4. Return to the app and sign in',
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.5,
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Didn't receive the email? Check your spam folder or use the resend button above.",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white60
                      : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
