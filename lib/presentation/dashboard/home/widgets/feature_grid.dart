// widgets/feature_grid.dart
import 'package:flutter/material.dart';
import 'feature_card.dart';
import 'feature_item.dart';

class FeatureGrid extends StatelessWidget {
  final List<FeatureItem> features;

  const FeatureGrid({Key? key, required this.features}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true, // Penting: agar grid tidak scroll sendiri
      physics:
          const NeverScrollableScrollPhysics(), // Nonaktifkan scroll pada grid
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.1,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return FeatureCard(
          title: feature.title,
          icon: feature.icon,
          iconColor: feature.iconColor,
          onTap: feature.onTap,
        );
      },
    );
  }
}
