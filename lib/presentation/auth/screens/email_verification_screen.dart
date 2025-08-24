// // lib/screens/auth/email_verification_screen.dart
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:iconly/iconly.dart';
// import 'package:provider/provider.dart';
// import '../../../core/constants/colors.dart';
// import '../../../core/navigations/app_navigator.dart';
// import '../providers/auth_provider.dart';

// class EmailVerificationScreen extends StatefulWidget {
//   final String email;

//   const EmailVerificationScreen({Key? key, required this.email})
//     : super(key: key);

//   @override
//   State<EmailVerificationScreen> createState() =>
//       _EmailVerificationScreenState();
// }

// class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
//   Timer? _checkTimer;
//   bool _isChecking = false;
//   bool _isResending = false;
//   int _resendCooldown = 0;
//   Timer? _cooldownTimer;

//   @override
//   void initState() {
//     super.initState();
//     _startPeriodicCheck();
//   }

//   @override
//   void dispose() {
//     _checkTimer?.cancel();
//     _cooldownTimer?.cancel();
//     super.dispose();
//   }

//   void _startPeriodicCheck() {
//     _checkTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
//       _checkEmailVerification();
//     });
//   }

//   Future<void> _checkEmailVerification() async {
//     if (_isChecking) return;

//     setState(() => _isChecking = true);

//     try {
//       final authProvider = context.read<AuthProvider>();
//       final isVerified = await authProvider.checkEmailVerificationStatus();

//       if (isVerified && mounted) {
//         _checkTimer?.cancel();

//         AppNavigator.showSnackBar(
//           message: 'Email verified successfully! Welcome!',
//           backgroundColor: const Color(0xFF10B981),
//         );

//         // Navigate to main app
//         await AppNavigator.handleSuccessfulLogin(
//           isEmailVerified: true,
//           email: widget.email,
//         );
//       }
//     } catch (e) {
//       debugPrint('Error checking email verification: $e');
//     } finally {
//       if (mounted) {
//         setState(() => _isChecking = false);
//       }
//     }
//   }

//   Future<void> _resendVerificationEmail() async {
//     if (_resendCooldown > 0) return;

//     setState(() => _isResending = true);

//     try {
//       final authProvider = context.read<AuthProvider>();
//       final success = await authProvider.resendEmailVerification();

//       if (success) {
//         AppNavigator.showSnackBar(
//           message: 'Verification email sent! Please check your inbox.',
//           backgroundColor: const Color(0xFF10B981),
//         );

//         // Start cooldown
//         _startResendCooldown();
//       } else {
//         AppNavigator.showSnackBar(
//           message: authProvider.error?.message ?? 'Failed to send email',
//           backgroundColor: Colors.red,
//         );
//       }
//     } catch (e) {
//       AppNavigator.showSnackBar(
//         message: 'Error sending email: $e',
//         backgroundColor: Colors.red,
//       );
//     } finally {
//       setState(() => _isResending = false);
//     }
//   }

//   void _startResendCooldown() {
//     setState(() => _resendCooldown = 60);

//     _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() => _resendCooldown--);

//       if (_resendCooldown <= 0) {
//         timer.cancel();
//       }
//     });
//   }

//   Future<void> _signOut() async {
//     final authProvider = context.read<AuthProvider>();
//     await authProvider.signOut();

//     if (mounted) {
//       Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             children: [
//               const SizedBox(height: 60),

//               // Email Icon
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF10B981).withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   IconlyBroken.message,
//                   size: 50,
//                   color: Color(0xFF10B981),
//                 ),
//               ),

//               const SizedBox(height: 32),

//               // Title
//               Text(
//                 'Check Your Email',
//                 style: GoogleFonts.poppins(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.darkText,
//                 ),
//                 textAlign: TextAlign.center,
//               ),

//               const SizedBox(height: 16),

//               // Description
//               RichText(
//                 textAlign: TextAlign.center,
//                 text: TextSpan(
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     color: AppColors.lightText,
//                     height: 1.5,
//                   ),
//                   children: [
//                     const TextSpan(text: 'We sent a verification link to\n'),
//                     TextSpan(
//                       text: widget.email,
//                       style: GoogleFonts.poppins(
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.darkText,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 32),

//               // Status Indicator
//               if (_isChecking)
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF10B981).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       color: const Color(0xFF10B981).withOpacity(0.3),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: Color(0xFF10B981),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Text(
//                         'Checking verification status...',
//                         style: GoogleFonts.poppins(
//                           fontSize: 14,
//                           color: const Color(0xFF10B981),
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//               const Spacer(),

//               // Instructions
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.blue.shade200),
//                 ),
//                 child: Column(
//                   children: [
//                     Icon(
//                       IconlyBroken.info_square,
//                       color: Colors.blue.shade600,
//                       size: 24,
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       'What\'s next?',
//                       style: GoogleFonts.poppins(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.blue.shade700,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       '1. Check your email inbox\n'
//                       '2. Click the verification link\n'
//                       '3. Return to this screen\n'
//                       '4. We\'ll automatically detect verification',
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         color: Colors.blue.shade600,
//                         height: 1.4,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 32),

//               // Resend Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: OutlinedButton.icon(
//                   onPressed:
//                       _resendCooldown > 0 || _isResending
//                           ? null
//                           : _resendVerificationEmail,
//                   icon:
//                       _isResending
//                           ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Color(0xFF10B981),
//                             ),
//                           )
//                           : const Icon(IconlyBroken.send),
//                   label: Text(
//                     _resendCooldown > 0
//                         ? 'Resend in ${_resendCooldown}s'
//                         : _isResending
//                         ? 'Sending...'
//                         : 'Resend Email',
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: const Color(0xFF10B981),
//                     side: const BorderSide(color: Color(0xFF10B981)),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Sign Out Button
//               TextButton(
//                 onPressed: _signOut,
//                 child: Text(
//                   'Sign out and try again',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: AppColors.lightText,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
