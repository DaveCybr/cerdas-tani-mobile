import 'package:fertilizer_calculator/core/components/space.dart';
import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:flutter/material.dart';

class HistoryCard extends StatelessWidget {
  final VoidCallback action;
  final String name;
  final String liter;
  final String konsentrasi;

  const HistoryCard({
    super.key,
    required this.action,
    required this.name,
    required this.liter,
    required this.konsentrasi,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            action();
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.card
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Nama resep : ",
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SpaceHeight(3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$liter Liter',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.white)),
                        child: Text(
                          'Akurasi $konsentrasi%',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SpaceHeight(3),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       'Biaya: Rp. ${totalPrice.toStringAsFixed(0)}',
                  //     ),
                  //     Text(
                  //       'Berat: ${totalWeight.toStringAsFixed(0)} grams',
                  //     )
                  //   ],
                  // ),
                  const Divider(),
                  Row(
                    children: [
                      const Spacer(),
                      const Text(
                        'Lihat Riwayat',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        Icons.arrow_right,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : AppColors.card,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SpaceHeight(15)
      ],
    );
  }
}
