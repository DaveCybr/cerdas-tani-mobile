import 'dart:io';
import 'dart:typed_data';
import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/presentation/user/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:fertilizer_calculator/presentation/auth/provider/user_provider.dart';

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
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showEditProfileDialog(context, userProvider),
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
          IconButton(
            onPressed: () => _showEditProfileDialog(context, userProvider),
            icon: const Icon(Icons.edit, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<File?> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  void _showEditProfileDialog(BuildContext context, UserProvider userProvider) {
    TextEditingController nameController =
        TextEditingController(text: userProvider.name);

    String avatarUrl = userProvider.avatar;
    File? _imageFile;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: const EdgeInsets.all(20),
            title: const Text(
              "Edit Profile",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (avatarUrl.isNotEmpty
                                  ? NetworkImage(avatarUrl)
                                  : const AssetImage(
                                      "assets/default_avatar.png"))
                              as ImageProvider,
                    ),
                    // Positioned(
                    //   bottom: 0,
                    //   right: 0,
                    //   child: GestureDetector(
                    //     onTap: () async {
                    //       File? picked = await _pickImage();
                    //       if (picked != null) {
                    //         setState(() {
                    //           _imageFile = picked;
                    //           avatarUrl = picked.path;
                    //         });
                    //       }
                    //     },
                    //     child: Container(
                    //       padding: const EdgeInsets.all(4),
                    //       decoration: BoxDecoration(
                    //         shape: BoxShape.circle,
                    //         color: Colors.white,
                    //         border: Border.all(color: Colors.grey.shade300),
                    //       ),
                    //       child: const Icon(Icons.camera_alt, size: 16),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  style: const TextStyle(
                    color: Colors
                        .black87, // ganti abu-abu jadi hitam (atau warna lain sesuai tema kamu)
                  ),
                  controller: nameController,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    labelText: "Nama Anda",
                    labelStyle: TextStyle(color: Colors.grey[800]),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black87),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text("Batal", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Tampilkan loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    Uint8List? newAvatarBytes;

                    if (_imageFile != null) {
                      newAvatarBytes = await _imageFile!.readAsBytes();
                    }

                    await userProvider.updateProfile(
                      name: nameController.text,
                      newAvatarBytes: newAvatarBytes,
                    );

                    Navigator.pop(context); // Tutup loading
                    Navigator.pop(context); // Tutup dialog edit profile
                  } catch (e) {
                    Navigator.pop(context); // Tutup loading
                    print('Gagal menyimpan profil: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menyimpan profil: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child:
                    const Text("Simpan", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
}
