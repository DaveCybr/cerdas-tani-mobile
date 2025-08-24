// widgets/custom_bottom_navigation.dart
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class CustomBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;
  final Widget? centerWidget;

  const CustomBottomNavigation({
    Key? key,
    this.currentIndex = 0,
    required this.onTap,
    required this.items,
    this.centerWidget,
  }) : super(key: key);

  @override
  State<CustomBottomNavigation> createState() => _CustomBottomNavigationState();
}

class _CustomBottomNavigationState extends State<CustomBottomNavigation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 30),
      // color: Colors.transparent,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            offset: const Offset(0, -1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _buildNavItems(),
      ),
    );
  }

  List<Widget> _buildNavItems() {
    List<Widget> navItems = [];

    for (int i = 0; i < widget.items.length; i++) {
      // Add center widget if needed
      if (i == widget.items.length ~/ 2 && widget.centerWidget != null) {
        navItems.add(widget.centerWidget!);
      }

      navItems.add(Expanded(child: _buildNavItem(widget.items[i], i)));
    }

    return navItems;
  }

  Widget _buildNavItem(BottomNavItem item, int index) {
    final bool isActive = widget.currentIndex == index;

    return GestureDetector(
      onTap: () {
        // Add haptic feedback
        // HapticFeedback.lightImpact();

        // Trigger animation
        _animationController.forward().then((_) {
          _animationController.reverse();
        });

        widget.onTap(index);
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale:
                isActive && _animationController.isAnimating
                    ? _scaleAnimation.value
                    : 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with background
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: isActive ? 56 : 40,
                    height: isActive ? 32 : 28,
                    decoration: BoxDecoration(
                      color:
                          isActive
                              ? AppColors.primary.withOpacity(0.15)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 300),
                        scale: isActive ? 1.1 : 1.0,
                        child: Icon(
                          item.icon,
                          color:
                              isActive
                                  ? AppColors.primary
                                  : AppColors.lightText.withOpacity(0.6),
                          size: isActive ? 24 : 22,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Label with animation
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: isActive ? 11 : 10,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color:
                          isActive
                              ? AppColors.primary
                              : AppColors.lightText.withOpacity(0.6),
                    ),
                    child: Text(item.label, textAlign: TextAlign.center),
                  ),

                  // Active indicator dot
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(top: 2),
                    width: isActive ? 4 : 0,
                    height: isActive ? 4 : 0,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;

  BottomNavItem({required this.icon, required this.label});
}

// Enhanced version with badge support
class EnhancedBottomNavItem extends BottomNavItem {
  final int? badgeCount;
  final Color? badgeColor;

  EnhancedBottomNavItem({
    required IconData icon,
    required String label,
    this.badgeCount,
    this.badgeColor,
  }) : super(icon: icon, label: label);
}
