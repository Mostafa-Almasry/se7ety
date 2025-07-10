import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final void Function()? onPressed;
  final String? ok;
  final String? no;
  const CustomAlertDialog({
    super.key,
    required this.title,
    this.onPressed,
    this.ok,
    this.no,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.accentColor,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accentColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(title, style: getTitleStyle(color: AppColors.black)),
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (ok != null)
                    ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.color2,
                      ),
                      child: Text(
                        ok ?? '',
                        style: getBodyStyle(color: AppColors.black),
                      ),
                    ),
                ],
              ),
              if (no != null)
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.color2,
                  ),
                  child: Text(
                    'No!',
                    style: getBodyStyle(color: AppColors.black),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
