import 'package:flutter/material.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/widgets/bottom_navigation_button.dart';
import 'package:se7ety/feature/settings/data/options/settings_tiles.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: EdgeInsets.only(right: 10),
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('الاعدادات'),
      ),
      body: Column(children: [SettingsTiles(setting: 'allSettings')]),
      bottomNavigationBar: BottomNavigationButton(
        text: "تسجيل الخروج",
        onPressed: () {},
        color: AppColors.redColor,
      ),
    );
  }
}
