import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se7ety/core/enum/profile_fields_enum.dart';
import 'package:se7ety/core/enum/user_type_enum.dart';
import 'package:se7ety/core/functions/dialogs.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/feature/settings/data/model/settings_model.dart';
import 'package:se7ety/feature/settings/presentation/cubit/settings_cubit.dart';
import 'package:se7ety/feature/settings/presentation/page/passwrord_view.dart';
import 'package:se7ety/feature/settings/presentation/page/profile_settings.dart';
import 'package:se7ety/feature/settings/presentation/widgets/settings_tile_widget.dart';

class SettingsTiles extends StatefulWidget {
  const SettingsTiles(
      {super.key,
      required this.setting,
      this.userData,
      required this.userType});
  final String setting;
  final UserType userType;
  final Map<String, dynamic>? userData;

  @override
  State<SettingsTiles> createState() => _SettingsTilesState();
}

class _SettingsTilesState extends State<SettingsTiles> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLoadingState) {
          showLoadingDialog(context);
        } else if (state is SettingsSuccessState) {
          Navigator.pop(context);
        } else if (state is SettingsErrorState) {
          showErrorDialog(context, 'حدث خطأ في تغير البيانات');
        }
      },
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          String userName = '--';
          String phoneNumber = '--';
          String address = '--';
          String bio = '--';
          String age = '--';
          if (state is FetchUserSuccessState) {
            userName = state.name;
            phoneNumber = state.phoneNumber;
            address = state.address;
            bio = state.bio;
            age = state.age;
          }
          final List<SettingsModel> settingsTiles = [
            SettingsModel(
              title: 'إعدادات الحساب',
              icon: Icons.person,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProfileSettingsView(userType: widget.userType),
                  ),
                );
                // Refresh name after returning from profile settings
                context.read<SettingsCubit>().fetchUser();
              },
            ),
            SettingsModel(
              title: 'كلمة المرور',
              icon: Icons.security,
              view: PasswordView(
                userType: widget.userType,
              ),
            ),
            SettingsModel(
              title: 'إعدادات الاشعارات',
              icon: Icons.notifications_on_sharp,
              view: const Placeholder(),
            ),
            SettingsModel(
              title: 'الخصوصية',
              icon: Icons.privacy_tip,
              view: const Placeholder(),
            ),
            SettingsModel(
              title: 'المساعدة والدعم',
              icon: Icons.question_mark,
              view: const Placeholder(),
            ),
            SettingsModel(
              title: 'دعوة صديق',
              icon: Icons.person_add_alt_1,
              view: const Placeholder(),
            ),
          ];
          final List<SettingsModel> profileSettingsTiles = [
            profilesettingstile(
                field: ProfileFieldsEnum.name,
                title: 'الاسم',
                userData: userName,
                context: context),
            profilesettingstile(
                field: ProfileFieldsEnum.phone,
                title: 'رقم الهاتف',
                userData: phoneNumber,
                context: context),
            profilesettingstile(
                field: ProfileFieldsEnum.address,
                title: 'المدينة',
                userData: address,
                context: context),
            profilesettingstile(
                field: ProfileFieldsEnum.age,
                title: 'العمر',
                userData: age,
                context: context),
            if (widget.userType == UserType.doctor)
              profilesettingstile(
                  field: ProfileFieldsEnum.bio,
                  title: 'نبذة تعريفية',
                  userData: bio,
                  context: context)
          ];
          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                if (widget.setting == 'allSettings')
                  ...settingsTiles
                      .map((option) => SettingsTileWidget(model: option)),
                if (widget.setting == 'profileSettings')
                  ...profileSettingsTiles
                      .map((option) => SettingsTileWidget(model: option)),
              ],
            ),
          );
        },
      ),
    );
  }

  SettingsModel profilesettingstile(
      {required ProfileFieldsEnum field,
      required String title,
      required String userData,
      required BuildContext context}) {
    return SettingsModel(
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          title,
          style: getTitleStyle(
            color: AppColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      trailing: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          userData,
          style: getBodyStyle(fontWeight: FontWeight.normal),
        ),
      ),
      onTap: () async {
        final data = userData;
        final TextEditingController dataController =
            TextEditingController(text: data);
        await showEditSettingsDialog(
          blocContext: context,
          context: context,
          userType: widget.userType,
          field: field,
          fieldcontroller: dataController,
        );
        // After dialog closes, update via Cubit
        context.read<SettingsCubit>().fetchUser();
      },
    );
  }
}
