// lib/core/navigation/initial_route_handler.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/auth/providers/auth_provider.dart';

class InitialRouteHandler extends StatelessWidget {
  const InitialRouteHandler({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading while determining auth state
        if (authProvider.status == AuthStatus.initial ||
            authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Determine initial route based on auth state
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!authProvider.isAuthenticated) {
            // Not authenticated - go to login
            Navigator.of(context).pushReplacementNamed('/auth/login');
          } else if (!authProvider.isEmailVerified) {
            // Authenticated but not verified - go to email verification
            Navigator.of(
              context,
            ).pushReplacementNamed('/auth/email-verification');
          } else {
            // Authenticated and verified - go to home
            Navigator.of(context).pushReplacementNamed('/home');
          }
        });

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
