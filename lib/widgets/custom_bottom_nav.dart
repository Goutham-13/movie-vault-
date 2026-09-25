import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../core/constants/app_colors.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: CupertinoIcons.house_fill, label: 'Home'),
      _NavItem(icon: CupertinoIcons.compass_fill, label: 'Discover'),
      _NavItem(icon: CupertinoIcons.folder_fill, label: 'Collection'),
      _NavItem(icon: CupertinoIcons.clock_fill, label: 'History'),
      _NavItem(icon: CupertinoIcons.ellipsis_circle_fill, label: 'More'),
    ];

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      height: 68,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardElevated.withOpacity(0.85),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: AppColors.glassBorder,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = currentIndex == index;

                return GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryAccent.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      border: isSelected
                          ? Border.all(color: AppColors.primaryAccent.withOpacity(0.4))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected
                              ? AppColors.primaryAccent
                              : AppColors.textMuted,
                          size: 22,
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Text(
                            item.label,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem({required this.icon, required this.label});
}
