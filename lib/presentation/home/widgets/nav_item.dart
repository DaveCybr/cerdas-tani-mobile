import 'package:fertilizer_calculator/core/components/space.dart';
import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.iconPath,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            colorFilter: ColorFilter.mode(
              isActive
                  ? Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppColors.card
                  : AppColors.disabled,
              BlendMode.srcIn,
            ),
          ),
          const SpaceHeight(4.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive
                  ? Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppColors.card
                  : AppColors.disabled,
            ),
          ),
        ],
      ),
    );
  }
}
