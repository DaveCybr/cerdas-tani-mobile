// import 'package:flutter/material.dart';
// import 'package:fertilizer_calculator/core/constans/colors.dart';

// class CompositionCard extends StatelessWidget {
//   final String title;
//   final Colors color;
//   const CompositionCard({
//     super.key,
//     required this.title,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {},
//       child: Container(
//         width: 60, // Lebar lingkaran
//         height: 60, // Tinggi lingkaran
//         decoration: const BoxDecoration(
//           shape: BoxShape.circle, // Membuat bentuk lingkaran
//           color: AppColors.card,
//           border: Border.fromBorderSide(
//             BorderSide(width: 4, color: color),
//           ),
//         ),
//         child: const Center(
//           child: Text(
//             'Resep', // Teks di dalam lingkaran
//             style: TextStyle(
//               color: Colors.white, // Warna teks
//               fontSize: 15, // Ukuran font
//               fontWeight: FontWeight.bold, // Ketebalan font
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
