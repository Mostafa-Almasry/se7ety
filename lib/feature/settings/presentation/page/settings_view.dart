import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se7ety/core/enum/user_type_enum.dart';
import 'package:se7ety/core/functions/navigation.dart';
import 'package:se7ety/core/services/local_storage.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/widgets/bottom_navigation_button.dart';
import 'package:se7ety/feature/auth/data/model/doctor_model.dart';
import 'package:se7ety/feature/intro/welcome_view.dart';
import 'package:se7ety/feature/settings/data/options/settings_tiles.dart';
import 'package:se7ety/feature/settings/presentation/cubit/settings_cubit.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.userType, this.doctorModel});
  final UserType userType;
  final DoctorModel? doctorModel;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Always signal that settings might have changed when popping
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            padding: const EdgeInsets.only(right: 10),
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              // Return `true` to indicate an update when navigating back
              Navigator.pop(context, true);
            },
          ),
          title: const Text('الاعدادات'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Provide the SettingsCubit to all children
              BlocProvider(
                create: (_) {
                  final cubit = SettingsCubit();
                  cubit.fetchUser(userType: userType);
                  return cubit;
                },
                child: SettingsTiles(
                  setting: 'allSettings',
                  userType: userType,
                  doctorModel: doctorModel,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationButton(
          text: "تسجيل الخروج",
          onPressed: () async {
            await AppLocalStorage.removeData(key: AppLocalStorage.uid);
            pushReplacement(context, const WelcomeView());
          },
          color: AppColors.redColor,
        ),
      ),
    );
  }
}
