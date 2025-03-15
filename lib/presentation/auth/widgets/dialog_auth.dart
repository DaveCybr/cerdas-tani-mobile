import 'package:flutter/material.dart';

void showCustomDialog({
  required BuildContext context,
  required bool isSuccess,
  required String message,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji sukses atau gagal
              Text(
                isSuccess ? "✅" : "⚠️",
                style: const TextStyle(fontSize: 60),
              ),
              const SizedBox(height: 10),

              // Judul
              Text(
                isSuccess ? "Success" : "Failed",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 10),

              // Pesan
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Tombol Konfirmasi
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? Colors.green : Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Tutup dialog
                    onConfirm(); // Jalankan aksi setelah konfirmasi
                  },
                  child: Text(
                    isSuccess ? "OK" : "Try Again",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
