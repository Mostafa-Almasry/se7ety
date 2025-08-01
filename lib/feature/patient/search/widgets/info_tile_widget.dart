import 'package:flutter/material.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';

class TileWidget extends StatelessWidget {
  const TileWidget(
      {super.key,
      required this.icon,
      required this.text,
      this.showActionIcon = false});

  final IconData icon;
  final String text;
  final bool showActionIcon;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 32,
            width: 32,
            color: AppColors.color1,
            child: Icon(icon, size: 20, color: AppColors.white),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: getBodyStyle(fontWeight: FontWeight.normal, fontSize: 18),
          ),
        ),
        if (showActionIcon) // Only show if true
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
      ],
    );
  }
}
