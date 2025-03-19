import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final String title;
  final Image image;
  final VoidCallback onTap; // Tambahkan parameter onTap

  CardWidget({required this.title, required this.image, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
              color: const Color(0xFF1FCC79).withOpacity(1), width: 1.0),
          color: const Color.fromARGB(255, 236, 248, 242),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 3,
              offset: Offset(1, 2),
            ),
          ],
        ),
        height: screenHeight * 0.24,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: screenWidth * 0.042,
                  ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment
                    .bottomRight, // Mengatur posisi gambar ke bawah kanan
                child: image,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
