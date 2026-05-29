import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String label;

  const CategoryChip({super.key, required this.label});

  Color _tint(Color color) => Color.fromRGBO(color.red, color.green, color.blue, 0.14);

  Color get _backgroundColor {
    switch (label) {
      case 'Event':
        return _tint(AppColors.secondaryBlue);
      case 'Emergency':
        return _tint(AppColors.error);
      case 'Health':
        return _tint(AppColors.primaryGreen);
      default:
        return _tint(AppColors.primaryGreen);
    }
  }

  Color get _textColor {
    switch (label) {
      case 'Event':
        return AppColors.secondaryBlue;
      case 'Emergency':
        return AppColors.error;
      case 'Health':
        return AppColors.primaryGreen;
      default:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
