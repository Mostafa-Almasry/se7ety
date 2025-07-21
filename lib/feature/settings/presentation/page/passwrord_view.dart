import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:se7ety/core/enum/user_type_enum.dart';
import 'package:se7ety/core/functions/dialogs.dart';
import 'package:se7ety/core/functions/navigation.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/core/widgets/custom_button.dart';
import 'package:se7ety/core/widgets/custom_text_form_field.dart';
import 'package:se7ety/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:se7ety/feature/auth/presentation/bloc/auth_event.dart';
import 'package:se7ety/feature/auth/presentation/bloc/auth_state.dart';
import 'package:se7ety/feature/patient/patient_nav_bar.dart';

class PasswordView extends StatefulWidget {
  const PasswordView({super.key, required this.userType});
  final UserType userType;

  @override
  State<PasswordView> createState() => _PasswordViewState();
}

class _PasswordViewState extends State<PasswordView> {
  final GlobalKey<FormState> _changePasswordKey = GlobalKey<FormState>();
  TextEditingController currentPasswordController = TextEditingController();
  bool correctPassword = false;

  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: const EdgeInsets.only(right: 10),
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('كلمة المرور'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is CheckPasswordLoadingState) {
            showLoadingDialog(context);
          } else if (state is CheckPasswordErrorState) {
            // Navigator.pop(context);
            showErrorDialog(context, state.message);
          } else if (state is CheckPasswordConfirmedState) {
            // Navigator.pop(context);
            setState(() {
              correctPassword = true;
            });
            showSuccessDialog(context, 'كلمة المرور صحيحة');
          }
        },
        child: Form(
          key: _changePasswordKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Gap(20),
                  Text(
                    'تغيير كلمة المرور ',
                    style: getTitleStyle(fontSize: 20),
                  ),
                  const Gap(55),

                  // Current Password
                  Row(
                    children: [
                      Text(
                        'كلمة المرور الحالية',
                        style: getBodyStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  const Gap(8),
                  CustomTextFormField(
                    controller: currentPasswordController,
                    textAlign: TextAlign.end,
                    hintText: '********',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: const Icon(Icons.visibility),
                    isPassword: true,
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'من فضلك ادخل كلمة المرور الحالية';
                      }
                      return null;
                    },
                  ),

                  // New password
                  if (correctPassword)
                    Column(
                      children: [
                        const Gap(20),
                        const Divider(),
                        const Gap(20),
                        Row(
                          children: [
                            Text(
                              'كلمة المرور الجديدة',
                              style: getBodyStyle(
                                color: AppColors.black,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const Gap(10),
                        CustomTextFormField(
                          controller: newPasswordController,
                          textAlign: TextAlign.end,
                          hintText: '********',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: const Icon(Icons.visibility),
                          isPassword: true,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'من فضلك ادخل كلمة المرور الجديدة';
                            }
                            return null;
                          },
                        ),

                        const Gap(20),

                        // New password confirmation
                        Row(
                          children: [
                            Text(
                              'تأكيد كلمة المرور الجديدة',
                              style: getBodyStyle(
                                color: AppColors.black,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const Gap(10),
                        CustomTextFormField(
                          controller: confirmNewPasswordController,
                          textAlign: TextAlign.end,
                          hintText: '********',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: const Icon(Icons.visibility),
                          isPassword: true,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'من فضلك اعد ادخال ادخل كلمة المرور الجديدة';
                            }
                            return null;
                          },
                        ),
                        const Gap(20),
                      ],
                    ),
                  const Gap(20),
                  CustomButton(
                      text: correctPassword ? 'تغيير كلمة المرور' : 'تحقق',
                      onPressed: () async {
                        if (correctPassword) {
                          final currentPassword =
                              currentPasswordController.text.trim();
                          final newPassword = newPasswordController.text.trim();
                          final confirmNewPassword =
                              confirmNewPasswordController.text.trim();
                          if (newPassword.isEmpty ||
                              confirmNewPassword.isEmpty) {
                            showErrorDialog(context,
                                'من فضلك أدخل كلمة المرور الجديدة وأكدها');
                            return;
                          }

                          if (newPassword != confirmNewPassword) {
                            showErrorDialog(
                                context, 'كلمتا المرور غير متطابقتين');
                            return;
                          }

                          if (newPassword == currentPassword) {
                            showErrorDialog(context,
                                'لا يمكنك استخدام نفس كلمة المرور الحالية. الرجاء إدخال كلمة مرور جديدة مختلفة.');
                            return;
                          }

                          try {
                            await FirebaseAuth.instance.currentUser!
                                .updatePassword(newPassword);
                            showSuccessDialog(
                                context, 'تم تغيير كلمة المرور بنجاح');
                            pushReplacement(
                                context,
                                const PatientNavBar(
                                  page: 3,
                                ));
                          } catch (e) {
                            showErrorDialog(context, e.toString());
                          }
                        } else {
                          if (_changePasswordKey.currentState!.validate()) {
                            if (newPasswordController.text !=
                                confirmNewPasswordController.text) {
                              return;
                            }
                            context.read<AuthBloc>().add(
                                ReauthenticateUserEvent(
                                    context: context,
                                    currentPassword:
                                        currentPasswordController.text));
                          }
                        }
                      })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
