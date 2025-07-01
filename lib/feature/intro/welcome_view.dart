import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:se7ety/core/constants/assets_manager.dart';
import 'package:se7ety/core/enum/user_type_enum.dart';
import 'package:se7ety/core/functions/navigation.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/feature/auth/presentation/pages/login_view.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(AssetsManager.welcomeBg),
          PositionedDirectional(
            top: 100,
            start: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('اهلا بيك', style: getTitleStyle(fontSize: 28)),
                const Gap(5),
                Text(
                  'سجل واحجز عند دكتورك وانت في البيت',
                  style: getBodyStyle(),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 80,
            right: 25,
            left: 25,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.color1.withOpacity(.5),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey.withOpacity(.3),
                    blurRadius: 15,
                    offset: const Offset(5, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'سجل دلوقتي كــ',
                    style: getBodyStyle(fontSize: 18, color: AppColors.white),
                  ),
                  const Gap(40),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          push(context, LoginView(userType: UserType.doctor));
                        },
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppColors.accentColor.withOpacity(.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              'دكتور',
                              style: getTitleStyle(color: AppColors.black),
                            ),
                          ),
                        ),
                      ),
                      const Gap(15),
                      GestureDetector(
                        onTap: () {
                          push(context, LoginView(userType: UserType.patient));
                        },
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppColors.accentColor.withOpacity(.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              'مريض',
                              style: getTitleStyle(color: AppColors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
