import 'package:fertilizer_calculator_mobile_v2/presentation/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';

class HomeHeader extends StatelessWidget {
  final String welcomeText;

  const HomeHeader({Key? key, this.welcomeText = 'Selamat Datang Kembali'})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final displayName = user?.displayName ?? 'Pengguna';
        final photoURL = user?.photoURL;
        final email = user?.email;

        return Row(
          children: [
            _buildProfileAvatar(context, photoURL),
            const SizedBox(width: 15),
            _buildWelcomeText(context, displayName, email),
            const SizedBox(width: 10),
            _buildActionButton(context, Icons.logout_outlined, authProvider),
          ],
        );
      },
    );
  }

  Widget _buildProfileAvatar(BuildContext context, String? photoURL) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child:
            photoURL != null && photoURL.isNotEmpty
                ? Image.network(
                  photoURL,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultAvatar();
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildDefaultAvatar();
                  },
                )
                : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.primaryLight,
      child: Image.asset("assets/images/farmer.png", fit: BoxFit.cover),
    );
  }

  Widget _buildWelcomeText(
    BuildContext context,
    String displayName,
    String? email,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Jika displayName kosong atau null, gunakan email sebagai fallback
    String finalDisplayName = displayName;
    if (displayName == 'Pengguna' && email != null) {
      // Ambil bagian sebelum @ dari email
      finalDisplayName = email.split('@').first;
      // Capitalize first letter
      if (finalDisplayName.isNotEmpty) {
        finalDisplayName =
            finalDisplayName[0].toUpperCase() + finalDisplayName.substring(1);
      }
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            welcomeText,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: screenWidth * 0.040,
              color: AppColors.lightText,
            ),
          ),
          Text(
            finalDisplayName,
            style: const TextStyle(
              color: AppColors.darkText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    AuthProvider authProvider,
  ) {
    return GestureDetector(
      onTap:
          authProvider.isAuthenticating
              ? null
              : () async {
                // Tampilkan dialog konfirmasi sebelum logout
                final shouldLogout = await _showLogoutConfirmation(context);
                if (shouldLogout == true) {
                  await authProvider.signOut();
                }
              },
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.danger),
        ),
        child: Center(
          child:
              authProvider.isAuthenticating
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.danger,
                    ),
                  )
                  : Icon(icon, color: AppColors.danger, size: 22),
        ),
      ),
    );
  }

  Future<bool?> _showLogoutConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Logout'),
            content: const Text(
              'Apakah Anda yakin ingin keluar dari aplikasi?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }
}
