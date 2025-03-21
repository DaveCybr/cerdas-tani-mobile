import 'package:fertilizer_calculator/core/components/space.dart';
import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/core/extensions/build_context_ext.dart';
import 'package:fertilizer_calculator/presentation/auth/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background melengkung di atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Stack(
              children: [
                // Gambar Semi Transparan
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: Opacity(
                      opacity: 0.6,
                      child: Image.asset(
                        'assets/images/padi.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // Gradient Warna
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary
                            .withOpacity(0.5), // Warna lebih terang di atas
                        AppColors.primary, // Warna utama di bawah
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Konten utama
          Column(
            children: [
              const SizedBox(height: 180), // Jarak dari atas

              // Gambar profil bulat di tengah
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4), // Jarak dari border
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white, // Background putih
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage('assets/images/farmer.png'),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Nama pengguna
              const Text(
                "Nama Pengguna",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 50), // Jarak sebelum opsi menu

              // Container untuk opsi menu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Opsi Ganti Password
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Coming Soon"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        height: 80,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 236, 248, 242),
                          border: Border.all(
                              color: Color(0xFF1FCC79).withOpacity(1),
                              width: 1.0),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF1FCC79).withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_2_outlined,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Profil",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20), // Jarak antara tombol
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Coming Soon"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        height: 80,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 236, 248, 242),
                          border: Border.all(
                              color: Color(0xFF1FCC79).withOpacity(1),
                              width: 1.0),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF1FCC79).withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Ganti Password",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    // Opsi Keluar
                    InkWell(
                      onTap: () async {
                        await GetStorage().erase();
                        context.pushReplacement(const LoginPage());
                      },
                      child: Container(
                        height: 80,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(
                              30, 255, 0, 0) // Merah dengan opacity 150/255
                          ,
                          border: Border.all(
                              color: Colors.red.withOpacity(1), width: 1.0),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_outlined,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Keluar",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                  height: 30), // Jarak bawah agar tidak mepet ke ujung layar
            ],
          ),
        ],
      ),
    );
  }
}
