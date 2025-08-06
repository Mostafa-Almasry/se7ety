import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:se7ety/core/constants/assets_manager.dart';
import 'package:se7ety/core/enum/profile_fields_enum.dart';
import 'package:se7ety/core/enum/user_type_enum.dart';
import 'package:se7ety/core/services/image_helper.dart' as image_helper;
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/core/widgets/custom_button.dart';
import 'package:se7ety/core/widgets/custom_text_form_field.dart';
import 'package:se7ety/feature/settings/presentation/cubit/settings_cubit.dart';

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

showEditSettingsDialog({
  required BuildContext context,
  required BuildContext blocContext,
  required UserType userType,
  required ProfileFieldsEnum field,
  required TextEditingController fieldcontroller,
}) {
  final TextEditingController fieldController = fieldcontroller;
  String arabicfield = '';
  if (field == ProfileFieldsEnum.name) {
    arabicfield = 'الاسم';
  } else if (field == ProfileFieldsEnum.address) {
    arabicfield = 'العنوان';
  } else if (field == ProfileFieldsEnum.bio) {
    arabicfield = 'الوصف';
  } else if (field == ProfileFieldsEnum.phone) {
    arabicfield = 'رقم الهاتف';
  } else if (field == ProfileFieldsEnum.age) {
    arabicfield = 'العمر';
  }

  showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
            title: Text('تعديل $arabicfield'),
            content: CustomTextFormField(
              controller: fieldController,
              hintText: 'ادخل $arabicfield الجديد',
              autoFocus: true,
              inputFormatters: field == ProfileFieldsEnum.name
                  ? [LengthLimitingTextInputFormatter(20)]
                  : [LengthLimitingTextInputFormatter(40)],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: AppColors.redColor,
                ),
                onPressed: () => Navigator.pop(context),
                child:
                    Text('الغاء', style: getBodyStyle(color: AppColors.white)),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: AppColors.color1,
                ),
                onPressed: () async {
                  final newValue = fieldController.text.trim();
                  try {
                    if (newValue.isNotEmpty) {
                      showLoadingDialog(context);
                      await BlocProvider.of<SettingsCubit>(blocContext)
                          .updateField(
                        field: field,
                        newValue: newValue,
                        userType: userType,
                      );
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    showErrorDialog(context, '$e');
                  }
                },
                child: Text('حفظ', style: getBodyStyle(color: AppColors.white)),
              ),
            ],
          ));
}

showPfpBottomSheet(BuildContext context, Function(File) onImageSelected) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isDismissible: true,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اختر صورة الملف الشخصي:',
              style: getBodyStyle(),
            ),
            const Gap(15),
            CustomButton(
              text: 'من الكاميرا 📷',
              width: double.infinity,
              onPressed: () async {
                final navigator = Navigator.of(context);
                File? imageFile =
                    await image_helper.pickImage(fromCamera: true);
                if (imageFile != null) {
                  onImageSelected(imageFile);
                }
                navigator.pop();
              },
            ),
            const SizedBox(height: 15),
            CustomButton(
              text: 'من المعرض 🖼️',
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
