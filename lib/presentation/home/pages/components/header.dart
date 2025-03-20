import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Header extends StatefulWidget {
  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  late Stream<String> _dateStream;

  @override
  void initState() {
    super.initState();
    _dateStream = Stream.periodic(Duration(seconds: 1), (_) {
      return _getFormattedDate();
    });
  }

  // Fungsi untuk mendapatkan format tanggal yang diinginkan
  String _getFormattedDate() {
    final now = DateTime.now();
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Pengguna';

    return Stack(
      children: [
        // Background utama
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF1FCC79),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
          ),
        ),

        // Gambar di belakang (semi transparan)
        Positioned(
          right: 5,
          top: 18,
          child: Opacity(
            opacity: 0.4,
            child: Image.asset(
              'assets/images/logo.png', // Sesuaikan dengan path gambar Anda
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
          ),
        ),

        // Header (agar tetap di atas)
        Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 50, bottom: 70),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bagian kiri: Salam dan Nama Pengguna
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome,',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              // Tanggal dalam format "Hari, Tanggal Bulan Tahun"
              StreamBuilder<String>(
                stream: _dateStream,
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? 'Memuat...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
