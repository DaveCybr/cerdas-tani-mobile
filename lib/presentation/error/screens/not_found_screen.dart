// shared/widgets/error_page.dart
import 'package:flutter/material.dart';
import '../../../core/navigations/app_navigator.dart';

class ErrorPage extends StatelessWidget {
  final String? routeName;
  final String? errorMessage;
  final String? errorCode;

  const ErrorPage({Key? key, this.routeName, this.errorMessage, this.errorCode})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Oops!'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.red.shade600,
        leading:
            AppNavigator.canPop()
                ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: () => AppNavigator.pop(),
                )
                : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Error Icon with Animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(60),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.shade100,
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.error_outline_rounded,
                              size: 64,
                              color: Colors.red.shade400,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Error Title
                    const Text(
                      'Page Not Found',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Error Description
                    Text(
                      errorMessage ??
                          'The page you\'re looking for doesn\'t exist or has been moved.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Debug Info (only in debug mode)
                    if (routeName != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.bug_report_outlined,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Debug Info',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Route: $routeName',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontFamily: 'monospace',
                              ),
                            ),
                            if (errorCode != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Error Code: $errorCode',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // Action Buttons
              Column(
                children: [
                  // Primary Action - Go to Home
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => AppNavigator.toHome(),
                      icon: const Icon(Icons.home_rounded, size: 20),
                      label: const Text(
                        'Go to Home',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Secondary Actions Row
                  Row(
                    children: [
                      // Go Back Button (if can pop)
                      if (AppNavigator.canPop()) ...[
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () => AppNavigator.pop(),
                              icon: const Icon(Icons.arrow_back, size: 18),
                              label: const Text('Go Back'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],

                      // Refresh Button
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Try to reload current route or go back to previous
                              if (AppNavigator.canPop()) {
                                AppNavigator.pop();
                              } else {
                                AppNavigator.toHome();
                              }
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Retry'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF10B981),
                              side: const BorderSide(color: Color(0xFF10B981)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Help Text
                  Text(
                    'Need help? Contact support or try refreshing the page.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// // Variant untuk berbagai jenis error
// class NetworkErrorPage extends ErrorPage {
//   const NetworkErrorPage({Key? key})
//     : super(
//         key: key,
//         errorMessage:
//             'No internet connection. Please check your network and try again.',
//         errorCode: 'NETWORK_ERROR',
//       );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         title: const Text('Connection Error'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         foregroundColor: Colors.orange.shade600,
//         leading:
//             AppNavigator.canPop()
//                 ? IconButton(
//                   icon: const Icon(Icons.arrow_back_ios_rounded),
//                   onPressed: () => AppNavigator.pop(),
//                 )
//                 : null,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             children: [
//               Expanded(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Network Error Icon
//                     Container(
//                       width: 120,
//                       height: 120,
//                       decoration: BoxDecoration(
//                         color: Colors.orange.shade50,
//                         borderRadius: BorderRadius.circular(60),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.orange.shade100,
//                             blurRadius: 20,
//                             offset: const Offset(0, 10),
//                           ),
//                         ],
//                       ),
//                       child: Icon(
//                         Icons.wifi_off_rounded,
//                         size: 64,
//                         color: Colors.orange.shade400,
//                       ),
//                     ),

//                     const SizedBox(height: 32),

//                     const Text(
//                       'No Connection',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF2D3748),
//                       ),
//                     ),

//                     const SizedBox(height: 12),

//                     Text(
//                       'Please check your internet connection and try again.',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey.shade600,
//                         height: 1.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Retry Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     // Implement retry logic here
//                     if (AppNavigator.canPop()) {
//                       AppNavigator.pop();
//                     } else {
//                       AppNavigator.toHome();
//                     }
//                   },
//                   icon: const Icon(Icons.refresh_rounded, size: 20),
//                   label: const Text(
//                     'Try Again',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange.shade400,
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ServerErrorPage extends ErrorPage {
//   const ServerErrorPage({Key? key})
//     : super(
//         key: key,
//         errorMessage:
//             'Something went wrong on our end. Please try again later.',
//         errorCode: 'SERVER_ERROR_500',
//       );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         title: const Text('Server Error'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         foregroundColor: Colors.red.shade600,
//         leading:
//             AppNavigator.canPop()
//                 ? IconButton(
//                   icon: const Icon(Icons.arrow_back_ios_rounded),
//                   onPressed: () => AppNavigator.pop(),
//                 )
//                 : null,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             children: [
//               Expanded(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Server Error Icon
//                     Container(
//                       width: 120,
//                       height: 120,
//                       decoration: BoxDecoration(
//                         color: Colors.red.shade50,
//                         borderRadius: BorderRadius.circular(60),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.red.shade100,
//                             blurRadius: 20,
//                             offset: const Offset(0, 10),
//                           ),
//                         ],
//                       ),
//                       child: Icon(
//                         Icons.cloud_off_rounded,
//                         size: 64,
//                         color: Colors.red.shade400,
//                       ),
//                     ),

//                     const SizedBox(height: 32),

//                     const Text(
//                       'Server Error',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF2D3748),
//                       ),
//                     ),

//                     const SizedBox(height: 12),

//                     Text(
//                       'We\'re experiencing some technical difficulties. Please try again in a few minutes.',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey.shade600,
//                         height: 1.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Actions
//               Column(
//                 children: [
//                   SizedBox(
//                     width: double.infinity,
//                     height: 56,
//                     child: ElevatedButton.icon(
//                       onPressed: () => AppNavigator.toHome(),
//                       icon: const Icon(Icons.home_rounded, size: 20),
//                       label: const Text(
//                         'Go to Home',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF10B981),
//                         foregroundColor: Colors.white,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   if (AppNavigator.canPop())
//                     TextButton(
//                       onPressed: () => AppNavigator.pop(),
//                       child: const Text('Go Back'),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Maintenance Page
// class MaintenancePage extends StatelessWidget {
//   const MaintenancePage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Maintenance Icon
//               Container(
//                 width: 120,
//                 height: 120,
//                 decoration: BoxDecoration(
//                   color: Colors.amber.shade50,
//                   borderRadius: BorderRadius.circular(60),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.amber.shade100,
//                       blurRadius: 20,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: Icon(
//                   Icons.build_rounded,
//                   size: 64,
//                   color: Colors.amber.shade600,
//                 ),
//               ),

//               const SizedBox(height: 32),

//               const Text(
//                 'Under Maintenance',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2D3748),
//                 ),
//               ),

//               const SizedBox(height: 12),

//               Text(
//                 'We\'re currently performing scheduled maintenance to improve your experience. Please check back soon.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey.shade600,
//                   height: 1.5,
//                 ),
//               ),

//               const SizedBox(height: 40),

//               // Estimated Time
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.amber.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.amber.shade200),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.schedule_rounded,
//                       color: Colors.amber.shade600,
//                       size: 20,
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       'Estimated completion: 2 hours',
//                       style: TextStyle(
//                         color: Colors.amber.shade800,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
