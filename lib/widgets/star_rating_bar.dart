import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StarRatingBar extends StatelessWidget {
  final double rating; // 0.0 to 5.0
  final double starSize;
  final ValueChanged<double>? onRatingChanged;
  final bool isInteractive;

  const StarRatingBar({
    super.key,
    required this.rating,
    this.starSize = 20,
    this.onRatingChanged,
    this.isInteractive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        IconData iconData;
        if (rating >= starValue) {
          iconData = Icons.star_rounded;
        } else if (rating >= starValue - 0.5) {
          iconData = Icons.star_half_rounded;
        } else {
          iconData = Icons.star_outline_rounded;
        }

        final color = rating >= starValue - 0.5
            ? AppColors.amberRating
            : AppColors.textMuted.withOpacity(0.5);

        if (isInteractive && onRatingChanged != null) {
          return GestureDetector(
            onTap: () => onRatingChanged!(starValue),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Icon(iconData, size: starSize, color: color),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: Icon(iconData, size: starSize, color: color),
        );
      }),
    );
  }
}
