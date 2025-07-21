import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se7ety/core/enum/user_type_enum.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/widgets/bottom_navigation_button.dart';
import 'package:se7ety/feature/patient/patient_nav_bar.dart';
import 'package:se7ety/feature/settings/data/options/settings_tiles.dart';
import 'package:se7ety/feature/settings/presentation/cubit/settings_cubit.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.userType});
  final UserType userType;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: const EdgeInsets.only(right: 10),
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (_) => const PatientNavBar(
                      page: 3,
                    )),
            (route) => false,
          ),
        ),
        title: const Text('الاعدادات'),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          // Provide the SettingsCubit to all children
          BlocProvider(
            create: (_) {
              final cubit = SettingsCubit();
              cubit.fetchUser();
              return cubit;
            },
            child: SettingsTiles(
              setting: 'allSettings',
              userType: userType,
            ),
          ),
        ]),
      ),
      bottomNavigationBar: BottomNavigationButton(
        text: "تسجيل الخروج",
        onPressed: () {},
        color: AppColors.redColor,
      ),
    );
  }
}
