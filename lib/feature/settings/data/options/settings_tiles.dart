import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se7ety/core/enum/profile_fields_enum.dart';
import 'package:se7ety/core/enum/user_type_enum.dart';
import 'package:se7ety/core/functions/dialogs.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/feature/auth/data/model/doctor_model.dart';
import 'package:se7ety/feature/settings/data/model/settings_model.dart';
import 'package:se7ety/feature/settings/presentation/cubit/settings_cubit.dart';
import 'package:se7ety/feature/settings/presentation/page/passwrord_view.dart';
import 'package:se7ety/feature/settings/presentation/page/profile_settings.dart';
import 'package:se7ety/feature/settings/presentation/widgets/settings_tile_widget.dart';

class SettingsTiles extends StatefulWidget {
  const SettingsTiles({
    super.key,
    required this.setting,
    this.userData,
    required this.userType,
    required this.doctorModel,
  });

  final String setting;
  final UserType userType;
  final Map<String, dynamic>? userData;
  final DoctorModel? doctorModel;

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
          showSuccessDialog(context, 'تم تغيير البيانات بنجاح');
        } else if (state is SettingsErrorState) {
          Navigator.pop(context);
          showErrorDialog(context, 'حدث خطأ في تغير البيانات');
        }
      },
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final cubit = context.read<SettingsCubit>();
          final name = cubit.name;
          final phone = widget.userType == UserType.patient
              ? cubit.phone
              : widget.doctorModel?.phone1 ?? '--';
          final address = widget.userType == UserType.patient
              ? cubit.address
              : widget.doctorModel?.address ?? '--';
          final bio = widget.userType == UserType.patient
              ? cubit.bio
              : widget.doctorModel?.bio ?? '--';
          final age = widget.userType == UserType.patient
              ? cubit.age.isNotEmpty
                  ? cubit.age
                  : 'Not set'
              : '';

          final List<SettingsModel> settingsTiles = [
            SettingsModel(
              title: 'إعدادات الحساب',
              icon: Icons.person,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileSettingsView(
                      userType: widget.userType,
                      doctorModel: widget.doctorModel,
                    ),
                  ),
                );
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
              userData: name,
              context: context,
              isBio: false,
            ),
            profilesettingstile(
              field: ProfileFieldsEnum.phone,
              title: 'رقم الهاتف',
              userData: phone,
              context: context,
              isBio: false,
            ),
            profilesettingstile(
              field: ProfileFieldsEnum.address,
              title: widget.userType == UserType.doctor ? 'العنوان' : 'المدينة',
              userData: address,
              context: context,
              isBio: true,
            ),
            if (widget.userType == UserType.patient)
              profilesettingstile(
                field: ProfileFieldsEnum.age,
                title: 'العمر',
                userData: age,
                context: context,
                isBio: false,
              ),
            if (widget.userType == UserType.doctor)
              profilesettingstile(
                field: ProfileFieldsEnum.bio,
                title: 'نبذة تعريفية',
                userData: bio,
                context: context,
                isBio: true,
              ),
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

  SettingsModel profilesettingstile({
    required ProfileFieldsEnum field,
    required String title,
    required String userData,
    required BuildContext context,
    required bool isBio,
  }) {
    final displayBio =
        userData.length > 10 ? '${userData.substring(0, 10)}...' : userData;

    return SettingsModel(
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          title,
          style: getBodyStyle(),
        ),
      ),
      trailing: Padding(
        padding: const EdgeInsets.all(10),
        child: isBio
            ? ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                  displayBio,
                  style: getBodyStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              )
            : Text(
                userData,
                style: getBodyStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
      onTap: () async {
        final dataController = TextEditingController(text: userData);
        await showEditSettingsDialog(
          blocContext: context,
          context: context,
          userType: widget.userType,
          field: field,
          fieldcontroller: dataController,
        );
      },
    );
  }
}
