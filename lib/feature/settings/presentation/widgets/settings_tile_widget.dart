import 'package:flutter/material.dart';
import 'package:se7ety/core/functions/navigation.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/feature/settings/data/model/settings_model.dart';

class SettingsTileWidget extends StatelessWidget {
  const SettingsTileWidget({super.key, required this.model});
  final SettingsModel model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 13, 0, 0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        onTap: () {
          if (model.onTap != null) {
            model.onTap!();
          } else if (model.view != null) {
            push(context, model.view!);
          }
        },
        leading: Padding(
          padding: const EdgeInsets.all(2),
          child:
              model.leading ?? (model.icon != null ? Icon(model.icon) : null),
        ),
        title: Text((model.title ?? '').toString(), style: getBodyStyle()),
        tileColor: AppColors.accentColor,
        trailing:
            model.trailing ?? const Icon(Icons.arrow_forward_ios_outlined),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
