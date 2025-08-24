import 'package:flutter/widgets.dart';

import '../../../../core/constants/colors.dart';

class FeatureItem {
  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  FeatureItem({
    required this.title,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.onTap,
  });
}
