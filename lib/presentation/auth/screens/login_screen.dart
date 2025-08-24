import 'package:fertilizer_calculator_mobile_v2/core/constants/colors.dart';
import 'package:fertilizer_calculator_mobile_v2/core/navigations/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validator.dart';
import '../providers/auth_provider.dart';
import '../widgets/text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isEmailLogin = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid =
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty;

    if (_isFormValid != isValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  Future<void> _handleEmailSignIn(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isEmailLogin = true);

    try {
      final success = await authProvider.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        _showSuccessSnackBar('Successfully signed in!');
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      debugPrint('Login error: $e');
    } finally {
      if (mounted) {
        setState(() => _isEmailLogin = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn(AuthProvider authProvider) async {
    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      _showSuccessSnackBar('Successfully signed in with Google!');
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _handleForgotPasswordNavigation() async {
    AppNavigator.toForgotPassword();
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

  String? _validatePassword(String? value) {
    return AuthValidators.validatePassword(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Stack(
            children: [
              // Main Content
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        // Logo
                        Image.asset("assets/images/logo.png", height: 100),
                        const SizedBox(height: 30),
                        // Welcome Text
                        Text(
                          'Welcome Back!',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Please enter your account here",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 30),
                        // Error Message Display
                        if (authProvider.hasError) ...[
                          _buildErrorContainer(authProvider),
                          const SizedBox(height: 20),
                        ],
                        // Email Field
                        CustomTextFormFild(
                          hint: "Email",
                          controller: _emailController,
                          prefixIcon: IconlyBroken.message,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 20),
                        // Password Field
                        CustomTextFormFild(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          hint: "Password",
                          prefixIcon: IconlyBroken.lock,
                          suffixIcon:
                              _isPasswordVisible
                                  ? IconlyBroken.hide
                                  : IconlyBroken.show,
                          onTapSuffixIcon:
                              () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible,
                              ),
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 20),
                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed:
                                authProvider.isAuthenticating
                                    ? null
                                    : () => _handleForgotPasswordNavigation(),
                            child: Text(
                              "Forgot password?",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : AppColors.lightText,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                (!_isFormValid || authProvider.isAuthenticating)
                                    ? null
                                    : () => _handleEmailSignIn(authProvider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isFormValid && !authProvider.isAuthenticating
                                      ? const Color(0xFF10B981)
                                      : Colors.grey.shade300,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child:
                                (authProvider.isAuthenticating && _isEmailLogin)
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                "Or continue with",
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: AppColors.secondaryText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Google Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed:
                                authProvider.isAuthenticating
                                    ? null
                                    : () => _handleGoogleSignIn(authProvider),
                            icon:
                                (authProvider.isAuthenticating &&
                                        !_isEmailLogin)
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.grey,
                                      ),
                                    )
                                    : Image.network(
                                      'https://developers.google.com/identity/images/g-logo.png',
                                      height: 20,
                                      width: 20,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.login,
                                                color: Colors.grey,
                                              ),
                                    ),
                            label: Text(
                              (authProvider.isAuthenticating && !_isEmailLogin)
                                  ? 'Signing in...'
                                  : 'Sign in with Google',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : AppColors.darkText,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 1,
                              shadowColor: Colors.grey.shade200,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Sign Up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: AppColors.lightText,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                AppNavigator.toRegister();
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Sign Up',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),

              // 👈 KUNCI: Gunakan shouldShowOverlay instead of isLoading
              if (authProvider.shouldShowOverlay)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(40),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Authenticating',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Verifying your credentials...',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
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
                  'Sign In Failed',
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
            onPressed:
                authProvider.clearError, // 👈 Ini sekarang akan berfungsi
            icon: Icon(Icons.close, color: AppColors.danger),
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}
