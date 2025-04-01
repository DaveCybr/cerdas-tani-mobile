import 'dart:io';

import 'package:fertilizer_calculator/presentation/auth/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/presentation/auth/pages/login_page.dart';
import 'package:fertilizer_calculator/presentation/user/provider/theme_provider.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          "My Profile",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(25),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: const [
            ProfileHeader(),
            SizedBox(height: 20),
            ProfileSettings(),
            SizedBox(height: 20),
            LogoutButton(),
          ],
        ),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _pickImage(context, userProvider),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                userProvider.avatar.isNotEmpty
                    ? userProvider.avatar
                    : "https://via.placeholder.com/60",
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userProvider.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userProvider.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // ElevatedButton(
          //   onPressed: () => _showEditProfileDialog(context, userProvider),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: AppColors.primary,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(20),
          //     ),
          //   ),
          //   child: Text(
          //     "Ubah",
          //     style: Theme.of(context).textTheme.bodyMedium,
          //   ),
          // ),
        ],
      ),
    );
  }

  void _pickImage(BuildContext context, UserProvider userProvider) async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await userProvider.updateAvatar(pickedFile.path);
    }
  }

  void _showEditProfileDialog(BuildContext context, UserProvider userProvider) {
    TextEditingController nameController =
        TextEditingController(text: userProvider.name);

    String avatarUrl = userProvider.avatar; // Avatar saat ini
    File? _imageFile;

    Future<void> _pickImage() async {
      final picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        avatarUrl = _imageFile!.path; // Tampilkan gambar yang baru dipilih
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  await _pickImage();
                  (context as Element)
                      .markNeedsBuild(); // Refresh dialog setelah memilih gambar
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : const AssetImage("assets/default_avatar.png")
                          as ImageProvider,
                  child: const Align(
                    alignment: Alignment.bottomRight,
                    child:
                        Icon(Icons.camera_alt, size: 20, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Nama Anda",
                  fillColor: Colors.black,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                // Update nama
                await userProvider.updateProfile(nameController.text);

                // Update avatar jika ada gambar baru
                if (_imageFile != null) {
                  String newAvatarUrl =
                      await userProvider.uploadImageToFirebase(_imageFile!);
                  await userProvider.updateAvatar(newAvatarUrl);
                }

                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }
}

class ProfileSettings extends StatelessWidget {
  const ProfileSettings({super.key});

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.card
              : Colors.white,
          title: const Text("Tema Aplikasi"),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRadioTile(context, "Sistem"),
              _buildRadioTile(context, "Terang"),
              _buildRadioTile(context, "Gelap"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRadioTile(BuildContext context, String theme) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return RadioListTile<String>(
      title: Text(theme),
      value: theme,
      groupValue: themeProvider.themeMode,
      onChanged: (value) {
        themeProvider.setTheme(value!);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Settings',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            contentPadding: EdgeInsets.all(0),
            // trailing: Switch(
            //   // value: Provider.of<ThemeProvider>(context).isDarkMode,
            //   // onChanged: (value) {
            //   //   Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            //   // },
            // ),
          ),
          ListTile(
            leading: const Icon(
              Icons.nightlight_round,
              color: AppColors.disabled,
            ),
            title: Text(
              'Night Mode',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppColors.disabled,
                  ),
            ),
            contentPadding: EdgeInsets.all(0),
            // trailing: Switch(
            //   // value: Provider.of<ThemeProvider>(context).isDarkMode,
            //   // onChanged: (value) {
            //   //   Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            //   // },
            // ),
          ),
          Divider(color: Colors.grey[300])
        ],
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: InkWell(
        onTap: () async {
          await GetStorage().erase();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.card
                : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.logout_outlined,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
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
