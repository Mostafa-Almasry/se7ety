import 'package:flutter/material.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';

class PhoneTile extends StatelessWidget {
  const PhoneTile({super.key, required this.number});
  final int number;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          color: AppColors.iconBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(number.toString(), style: getBodyStyle()),
            const Icon(Icons.phone),
          ],
        ),
      ),
    );
  }
}
