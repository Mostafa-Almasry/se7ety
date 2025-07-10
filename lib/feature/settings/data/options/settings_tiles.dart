import 'package:flutter/material.dart';
import 'package:se7ety/core/services/local_storage.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/feature/settings/data/model/settings_model.dart';
import 'package:se7ety/feature/settings/presentation/page/profile_settings.dart';
import 'package:se7ety/feature/settings/presentation/widgets/settings_tile_widget.dart';

class SettingsTiles extends StatelessWidget {
  const SettingsTiles({super.key, required this.setting, this.userData});
  final String setting;
  final Map<String, dynamic>? userData;

  @override
  Widget build(BuildContext context) {
    final List<SettingsModel> settingsTiles = [
      SettingsModel(
        title: 'إعدادات الحساب',
        icon: Icons.person,
        view: ProfileSettingsView(),
      ),
      SettingsModel(
        title: 'كلمة السر',
        icon: Icons.security,
        view: Placeholder(),
      ),
      SettingsModel(
        title: 'إعدادات الاشعارات',
        icon: Icons.notifications_on_sharp,
        view: Placeholder(),
      ),
      SettingsModel(
        title: 'الخصوصية',
        icon: Icons.privacy_tip,
        view: Placeholder(),
      ),
      SettingsModel(
        title: 'المساعدة والدعم',
        icon: Icons.question_mark,
        view: Placeholder(),
      ),
      SettingsModel(
        title: 'دعوة صديق',
        icon: Icons.person_add_alt_1,
        view: Placeholder(),
      ),
    ];
    final List<SettingsModel> profileSettingsTiles = [
      SettingsModel(
        view: Placeholder(),
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            'الاسم',
            style: getTitleStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        trailing: Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            AppLocalStorage.getData(key: AppLocalStorage.userName),
            style: getBodyStyle(fontWeight: FontWeight.normal),
          ),
        ),
        onTap: () {
          // showDialog(
          //   context: context,
          //   builder: (context) {
          //     // final controller = TextEditingController(text: value);
          //   },
          // );
        },
      ),
    ];
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          if (setting == 'allSettings')
            ...settingsTiles.map((option) => SettingsTileWidget(model: option)),
          if (setting == 'profileSettings')
            ...profileSettingsTiles.map(
              (option) => SettingsTileWidget(model: option),
            ),
        ],
      ),
    );
  }
}
