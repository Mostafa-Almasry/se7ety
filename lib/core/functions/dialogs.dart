import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:se7ety/core/constants/assets_manager.dart';
import 'package:se7ety/core/services/image_helper.dart' as image_helper;
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/core/widgets/custom_button.dart';

showErrorDialog(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.red,
      content: Center(
        child: Text(text, style: getSmallStyle(color: AppColors.white)),
      ),
    ),
  );
}

showSuccessDialog(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.blue,
      content: Center(
        child: Text(text, style: getSmallStyle(color: AppColors.white)),
      ),
    ),
  );
}

showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Lottie.asset(AssetsManager.loading, width: 250)],
      );
    },
  );
}

showPfpBottomSheet(BuildContext context, Function(File) onImageSelected) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isDismissible: true,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
              text: 'Upload From Camera',
              width: double.infinity,
              onPressed: () async {
                final navigator = Navigator.of(context);
                File? imageFile = await image_helper.pickImage(fromCamera: true);
                if (imageFile != null) {
                  onImageSelected(imageFile);
                }
                navigator.pop();
              },
            ),
            const SizedBox(height: 15),
            CustomButton(
              text: 'Upload From Gallery',
              width: double.infinity,
              onPressed: () async {
                final navigator = Navigator.of(context);
                File? imageFile = await image_helper.pickImage(
                  fromCamera: false,
                );
                if (imageFile != null) {
                  onImageSelected(imageFile);
                }
                navigator.pop();
              },
            ),
            const Gap(5),
          ],
        ),
      );
    },
  );
}
