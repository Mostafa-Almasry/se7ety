import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:se7ety/core/constants/assets_manager.dart';
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
import 'package:se7ety/feature/auth/presentation/pages/doc_registration_view.dart';
import 'package:se7ety/feature/auth/presentation/pages/register_view.dart';
import 'package:se7ety/feature/patient/patient_nav_bar.dart';

// accounts:
// abdelrahmankhaled@se7ety.com
// 12345678

class LoginView extends StatefulWidget {
  const LoginView({super.key, required this.userType});
  final UserType userType;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    String handleUserType() {
      return widget.userType == UserType.doctor ? 'دكتور' : 'مريض';
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: const BackButton(color: AppColors.color1),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoadingState) {
            showLoadingDialog(context);
          } else if (state is AuthErrorState) {
            Navigator.pop(context);
            showErrorDialog(context, state.message);
          } else if (state is AuthSuccessState) {
            Navigator.pop(context);
            showSuccessDialog(context, 'تم تسجيل الدخول بنجاح');
            if (widget.userType == UserType.doctor) {
              pushAndRemoveUntil(context, const DocRegistrationView());
            } else {
              pushAndRemoveUntil(context, const PatientNavBar());
            }
          }
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Gap(20),
                    Image.asset(AssetsManager.logoPng, height: 200),
                    const Gap(30),
                    Text(
                      'سجل الدخول الان كـ "${handleUserType()}"',
                      style: getBodyStyle(color: AppColors.color1),
                    ),
                    const Gap(40),
                    CustomTextFormField(
                      hintText: 'Mostafa@example.com',
                      textAlign: TextAlign.end,

                      controller: _emailController,
                      prefixIcon: Icon(Icons.email),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const Gap(20),
                    CustomTextFormField(
                      controller: _passwordController,
                      textAlign: TextAlign.end,
                      hintText: '********',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: Icon(Icons.visibility),
                      isPassword: true,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          'نسيت كلمة السر؟',
                          style: getSmallStyle(fontWeight: FontWeight.w400),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    const Gap(5),
                    CustomButton(
                      text: 'تسجيل الدخول',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // If all fields are valid, Do the login logic..

                          context.read<AuthBloc>().add(
                            LoginEvent(
                              email: _emailController.text,
                              password: _passwordController.text,
                              userType: widget.userType,
                            ),
                          );
                        }
                      },
                      radius: 25,
                    ),
                    // ahmed@ahmed.com
                    // 12345678
                    const Gap(30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ليس لديك حساب؟',
                          style: getSmallStyle(fontWeight: FontWeight.w500),
                        ),
                        TextButton(
                          onPressed: () {
                            pushReplacement(
                              context,
                              RegisterView(userType: widget.userType),
                            );
                          },
                          child: Text(
                            'سجل الان',
                            style: getSmallStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.color1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(65),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
