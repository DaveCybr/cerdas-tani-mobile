import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/profile_component.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Reload user data saat screen dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.reloadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (!authProvider.isAuthenticated) {
            return const Center(
              child: Text(
                'User not authenticated',
                style: TextStyle(color: AppColors.lightText, fontSize: 16),
              ),
            );
          }

          final user = authProvider.user;
          if (user == null) {
            return const Center(
              child: Text(
                'No user data available',
                style: TextStyle(color: AppColors.lightText, fontSize: 16),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(user),
                const SizedBox(height: 30),

                // Profile Information Cards
                _buildProfileInfoSection(user),

                const SizedBox(height: 30),

                // Action Buttons
                _buildActionSection(context, authProvider),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          ProfileAvatar(
            photoURL: user.photoURL,
            displayName: user.displayName ?? user.email ?? 'User',
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            user.displayName ?? 'No Name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email ?? 'No Email',
            style: const TextStyle(fontSize: 16, color: AppColors.lightText),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: user.emailVerified ? AppColors.primary : AppColors.danger,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.emailVerified ? 'Verified' : 'Not Verified',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoSection(user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 16),
        ProfileInfoCard(
          icon: Icons.email_outlined,
          title: 'Email',
          value: user.email ?? 'Not provided',
          subtitle: user.emailVerified ? 'Verified' : 'Not verified',
          subtitleColor:
              user.emailVerified ? AppColors.primary : AppColors.danger,
        ),
        const SizedBox(height: 12),
        ProfileInfoCard(
          icon: Icons.person_outline,
          title: 'Display Name',
          value: user.displayName ?? 'Not set',
        ),
        const SizedBox(height: 12),
        // ProfileInfoCard(
        //   icon: Icons.fingerprint,
        //   title: 'User ID',
        //   value: user.uid ?? 'Unknown',
        //   isMonospace: true,
        // ),
      ],
    );
  }

  Widget _buildActionSection(BuildContext context, AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 16),
        // ProfileActionButton(
        //   icon: Icons.refresh,
        //   title: 'Reload Profile',
        //   subtitle: 'Refresh your profile data',
        //   onTap: () => _reloadProfile(authProvider),
        //   iconColor: AppColors.primary,
        // ),
        // const SizedBox(height: 8),
        // ProfileActionButton(
        //   icon: Icons.lock_outline,
        //   title: 'Change Password',
        //   subtitle: 'Update your account password',
        //   onTap: () => _showChangePasswordDialog(context, authProvider),
        //   iconColor: AppColors.secondary,
        // ),
        // const SizedBox(height: 8),
        ProfileActionButton(
          icon: Icons.logout,
          title: 'Sign Out',
          subtitle: 'Sign out from your account',
          onTap: () => _signOut(context, authProvider),
          iconColor: AppColors.danger,
        ),
        const SizedBox(height: 8),
        // q
      ],
    );
  }

  void _reloadProfile(AuthProvider authProvider) async {
    final success = await authProvider.reloadUser();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Profile reloaded' : 'Failed to reload profile',
          ),
          backgroundColor: success ? AppColors.primary : AppColors.danger,
        ),
      );
    }
  }

  void _signOut(BuildContext context, AuthProvider authProvider) async {
    final confirmed = await _showConfirmDialog(
      context,
      'Sign Out',
      'Are you sure you want to sign out?',
    );

    if (confirmed == true) {
      await authProvider.signOut();
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    final displayNameController = TextEditingController(
      text: user?.displayName ?? '',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Profile'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final success = await authProvider.updateProfile(
                    displayName: displayNameController.text.trim(),
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Profile updated'
                              : 'Failed to update profile',
                        ),
                        backgroundColor:
                            success ? AppColors.primary : AppColors.danger,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showChangePasswordDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Change Password'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: currentPasswordController,
                        obscureText: obscureCurrentPassword,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed:
                                () => setState(() {
                                  obscureCurrentPassword =
                                      !obscureCurrentPassword;
                                }),
                            icon: Icon(
                              obscureCurrentPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: newPasswordController,
                        obscureText: obscureNewPassword,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed:
                                () => setState(() {
                                  obscureNewPassword = !obscureNewPassword;
                                }),
                            icon: Icon(
                              obscureNewPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final success = await authProvider.changePassword(
                          currentPassword: currentPasswordController.text,
                          newPassword: newPasswordController.text,
                        );

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Password changed successfully'
                                    : 'Failed to change password',
                              ),
                              backgroundColor:
                                  success
                                      ? AppColors.primary
                                      : AppColors.danger,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Change'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final confirmed = await _showConfirmDialog(
      context,
      'Delete Account',
      'This action cannot be undone. All your data will be permanently deleted.',
      confirmText: 'DELETE',
      isDangerous: true,
    );

    if (confirmed == true) {
      final success = await authProvider.deleteAccount();
      if (mounted) {
        if (success) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete account'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context,
    String title,
    String message, {
    String confirmText = 'Confirm',
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDangerous ? AppColors.danger : AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(confirmText),
              ),
            ],
          ),
    );
  }
}
