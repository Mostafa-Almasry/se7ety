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
import 'package:se7ety/feature/auth/presentation/pages/login_view.dart';
import 'package:se7ety/feature/patient/patient_nav_bar.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key, required this.userType});
  final UserType userType;

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final GlobalKey<FormState> _registerKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
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
        listener: (context, state) async {
          if (state is AuthLoadingState) {
            showLoadingDialog(context);
          } else if (state is AuthErrorState) {
            Navigator.pop(context);
            showErrorDialog(context, state.message);
          } else if (state is AuthSuccessState) {
            await showSuccessDialog(context, 'تم انشاء حسابك بنجاح');
            if (widget.userType == UserType.doctor) {
              pushAndRemoveUntil(context, const DocRegistrationView());
            } else {
              // change to patient view.
              pushAndRemoveUntil(context, const PatientNavBar(page: 0,));
            }
          }
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Form(
                key: _registerKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Gap(20),
                    Image.asset(AssetsManager.logoPng, height: 200),
                    const Gap(30),
                    Text(
                      'سجل حساب جديد كـ "${handleUserType()}"',
                      style: getBodyStyle(color: AppColors.color1),
                    ),
                    const Gap(40),
                    CustomTextFormField(
                      controller: _nameController,
                      textAlign: TextAlign.end,

                      prefixIcon: const Icon(Icons.person),
                      hintText: 'الاسم',
                    ),
                    const Gap(20),
                    CustomTextFormField(
                      hintText: 'Mostafa@example.com',
                      textAlign: TextAlign.end,
                      controller: _emailController,
                      prefixIcon: const Icon(Icons.email),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const Gap(20),
                    CustomTextFormField(
                      controller: _passwordController,
                      hintText: '********',
                      textAlign: TextAlign.end,

                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: const Icon(Icons.visibility),
                      isPassword: true,
                      keyboardType: TextInputType.visiblePassword,
                    ),

                    const Gap(25),
                    CustomButton(
                      text: 'تسجيل حساب',
                      onPressed: () {
                        if (_registerKey.currentState!.validate()) {
                          // If all fields are validated and validator returns true(valid), Do Register logic..
                          context.read<AuthBloc>().add(
                            RegisterEvent(
                              name: _nameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                              userType: widget.userType,
                            ),
                          );
                        }
                      },
                      radius: 25,
                    ),
                    const Gap(30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'لديك حساب؟',
                          style: getSmallStyle(fontWeight: FontWeight.w500),
                        ),
                        TextButton(
                          onPressed: () {
                            pushReplacement(
                              context,
                              LoginView(userType: widget.userType),
                            );
                          },
                          child: Text(
                            'سجل دخول',
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
