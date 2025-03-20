import 'package:fertilizer_calculator/core/assets/assets.gen.dart';
import 'package:fertilizer_calculator/presentation/calculator/pages/fertilizer_page.dart';
import 'package:fertilizer_calculator/presentation/calculator/pages/recipe_page.dart';
import 'package:fertilizer_calculator/presentation/history/pages/history_page.dart';
import 'package:fertilizer_calculator/presentation/home/widgets/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:fertilizer_calculator/core/extensions/build_context_ext.dart';

class MenuCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CardWidget(
                title: 'Program Pemupukan',
                onTap: () => context.push(const RecipePage()),
                image: Image.asset(
                  Assets.images.plant.path,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: CardWidget(
                title: 'Pupuk unsur hara',
                onTap: () => context.push(const FertilizerPage()),
                image: Image.asset(
                  Assets.images.puh.path,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20), // Spasi responsif
        Row(
          children: [
            Expanded(
              // Padding responsif
              child: CardWidget(
                title: 'History',
                onTap: () => context.push(const HistoryPage()),
                image: Image.asset(
                  Assets.images.history.path,
                ),
              ),
            ),
            const SizedBox(width: 20), // Spasi responsif
            Expanded(
              child: CardWidget(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Coming Soon"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                title: 'YouTube',
                image: Image.asset("assets/images/yt-vector.png"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
