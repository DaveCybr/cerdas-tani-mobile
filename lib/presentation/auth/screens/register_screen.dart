// lib/screens/auth/register_screen.dart - Updated version
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/navigations/app_navigator.dart';
import '../../../core/utils/validator.dart';
import '../providers/auth_provider.dart';
import '../widgets/text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isFormValid = false;
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    _initializeListeners();
  }

  void _initializeListeners() {
    _fullNameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _fullNameController.removeListener(_validateForm);
    _emailController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
    _confirmPasswordController.removeListener(_validateForm);
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  void _validateForm() {
    final isValid =
        _fullNameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty &&
        _confirmPasswordController.text.trim().isNotEmpty &&
        _termsAccepted;

    if (_isFormValid != isValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  // Updated: Registration handler now logs in immediately
  Future<void> _handleEmailRegistration(AuthProvider authProvider) async {
    if (!_termsAccepted) {
      AppNavigator.showSnackBar(
        message: 'Please accept the Terms of Service and Privacy Policy',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      debugPrint('Starting registration process...');
      debugPrint('Email: ${_emailController.text.trim()}');

      // Registration now automatically logs in the user
      final success = await authProvider.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _fullNameController.text.trim(),
      );

      if (success && mounted) {
        final authStatus = authProvider.status;

        if (authStatus == AuthStatus.authenticated) {
          AppNavigator.showSnackBar(
            message: 'Account created successfully! Welcome!',
            backgroundColor: const Color(0xFF10B981),
          );

          // Navigate directly to home
          await AppNavigator.handleSuccessfulRegistration(
            email: _emailController.text.trim(),
          );
        }
      } else {
        debugPrint('Registration failed');
        if (authProvider.hasError) {
          debugPrint('Error: ${authProvider.error?.message}');
          // Error will be displayed in the UI automatically
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Registration error caught in UI: ${e.runtimeType} - $e');
      debugPrint('Stack trace: $stackTrace');

      AppNavigator.showSnackBar(
        message: 'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _handleGoogleSignUp(AuthProvider authProvider) async {
    try {
      final success = await authProvider.signInWithGoogle();

      if (success && mounted) {
        AppNavigator.showSnackBar(
          message: 'Successfully signed up with Google!',
          backgroundColor: const Color(0xFF10B981),
        );

        // Google accounts are pre-verified, navigate to home
        await AppNavigator.handleSuccessfulLogin(
          isEmailVerified: true,
          email: authProvider.email,
        );
      }
    } catch (e) {
      debugPrint('Google sign up error: $e');
      AppNavigator.showSnackBar(
        message: 'Google sign up failed. Please try again.',
        backgroundColor: Colors.red,
      );
    }
  }

  // Validation methods remain the same
  String? _validateFullName(String? value) {
    return AuthValidators.validateDisplayName(value);
  }

  String? _validateEmail(String? value) {
    return AuthValidators.validateEmail(value);
  }

  String? _validatePassword(String? value) {
    return AuthValidators.validatePassword(value);
  }

  String? _validateConfirmPassword(String? value) {
    return AuthValidators.validateConfirmPassword(
      _passwordController.text,
      value,
    );
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
                        const SizedBox(height: 40),

                        // Welcome Text
                        Text(
                          'Create Account',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineLarge?.copyWith(fontSize: 30),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please fill in the form to continue',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 40),

                        // Error Message Display
                        if (authProvider.hasError) ...[
                          _buildErrorContainer(authProvider),
                          const SizedBox(height: 20),
                        ],

                        // Form Fields
                        _buildFormFields(),

                        const SizedBox(height: 20),

                        // Password Strength Indicator
                        if (_passwordController.text.isNotEmpty)
                          _buildPasswordStrengthIndicator(),

                        const SizedBox(height: 20),

                        // Terms and Conditions Checkbox
                        _buildTermsCheckbox(),

                        const SizedBox(height: 20),

                        // Sign Up Button
                        _buildSignUpButton(authProvider),

                        const SizedBox(height: 30),

                        // Divider
                        _buildDivider(),

                        const SizedBox(height: 30),

                        // Google Sign Up Button
                        _buildGoogleSignUpButton(authProvider),

                        const SizedBox(height: 40),

                        // Sign In Link
                        _buildSignInLink(),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),

              // Overlay Loading
              if (authProvider.shouldShowOverlay)
                _buildOverlayLoading(authProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Full Name Field
        CustomTextFormFild(
          hint: "Full Name",
          controller: _fullNameController,
          prefixIcon: IconlyBroken.profile,
          validator: _validateFullName,
        ),
        const SizedBox(height: 20),

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
              _isPasswordVisible ? IconlyBroken.hide : IconlyBroken.show,
          onTapSuffixIcon:
              () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          validator: _validatePassword,
        ),
        const SizedBox(height: 20),

        // Confirm Password Field
        CustomTextFormFild(
          hint: "Confirm Password",
          obscureText: !_isConfirmPasswordVisible,
          controller: _confirmPasswordController,
          prefixIcon: IconlyBroken.lock,
          suffixIcon:
              _isConfirmPasswordVisible ? IconlyBroken.hide : IconlyBroken.show,
          onTapSuffixIcon:
              () => setState(
                () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
              ),
          validator: _validateConfirmPassword,
        ),
      ],
    );
  }

  Widget _buildSignUpButton(AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed:
            (!_isFormValid || authProvider.isAuthenticating)
                ? null
                : () => _handleEmailRegistration(authProvider),
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
            authProvider.isAuthenticating
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
      ),
    );
  }

  Widget _buildGoogleSignUpButton(AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed:
            authProvider.isAuthenticating
                ? null
                : () => _handleGoogleSignUp(authProvider),
        icon:
            authProvider.isAuthenticating
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
                          const Icon(Icons.login, color: Colors.grey),
                ),
        label: Text(
          authProvider.isAuthenticating
              ? 'Signing up...'
              : 'Sign up with Google',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.darkText),
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
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or continue with',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.lightText),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.lightText),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Sign In',
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Updated: Simplified overlay loading message
  Widget _buildOverlayLoading(AuthProvider authProvider) {
    return Positioned.fill(
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
                  'Creating Account',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Setting up your account...',
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
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registration Failed',
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
            icon: Icon(Icons.close, color: Colors.red.shade600),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController.text;
    final score = AuthValidators.calculatePasswordStrength(password);
    final label = AuthValidators.getPasswordStrengthLabel(score);

    Color strengthColor;
    if (score < 30) {
      strengthColor = Colors.red;
    } else if (score < 50) {
      strengthColor = Colors.orange;
    } else if (score < 70) {
      strengthColor = Colors.yellow.shade700;
    } else if (score < 90) {
      strengthColor = Colors.lightGreen;
    } else {
      strengthColor = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password Strength',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: strengthColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: score / 100,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _termsAccepted,
            onChanged: (value) {
              setState(() {
                _termsAccepted = value ?? false;
                _validateForm();
              });
            },
            activeColor: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _termsAccepted = !_termsAccepted;
                _validateForm();
              });
            },
            child: RichText(
              text: TextSpan(
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.lightText),
                children: [
                  const TextSpan(
                    text: 'By creating an account, you agree to our ',
                  ),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
