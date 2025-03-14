import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:flutter/material.dart';

class TableStriped extends StatelessWidget {
  final Map<String, dynamic> nutrients;

  const TableStriped({super.key, required this.nutrients});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(50),
        1: FixedColumnWidth(70),
      },
      children: nutrients.entries.map((entry) {
        return _buildTableRow(context, entry.key, entry.value.toString());
      }).toList(),
    );
  }

  TableRow _buildTableRow(BuildContext context, String title, String value) {
    final isOddRow = nutrients.keys.toList().indexOf(title) % 2 == 0;

    return TableRow(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? (isOddRow ? const Color(0xff252635) : const Color(0xff1e1d2d))
            : (isOddRow ? Colors.grey[200] : Colors.white),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            title.isNotEmpty
                ? title[0].toUpperCase() + title.substring(1).toLowerCase()
                : title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(value),
        ),
      ],
    );
  }
}
