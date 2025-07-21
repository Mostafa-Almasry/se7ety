import 'package:flutter/material.dart';
import 'package:se7ety/core/constants/assets_manager.dart';
import 'package:se7ety/core/functions/navigation.dart';
import 'package:se7ety/core/services/local_storage.dart';
import 'package:se7ety/feature/auth/presentation/pages/doc_registration_view.dart';
import 'package:se7ety/feature/intro/onboarding/onboarding_view.dart';
import 'package:se7ety/feature/intro/welcome_view.dart';
import 'package:se7ety/feature/patient/patient_nav_bar.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();

    _navigateFromSplash();
  }

  Future<void> _navigateFromSplash() async {
    await Future.delayed(const Duration(seconds: 2));
    final isLoggedIn = await AppLocalStorage.getData(key: AppLocalStorage.uid);
    final isOnboardingShown =
        await AppLocalStorage.getData(key: AppLocalStorage.isOnboardingShown) ??
            false;
    final userType = await AppLocalStorage.getData(
      key: AppLocalStorage.userType,
    );
    final userImage = await AppLocalStorage.getData(
      key: AppLocalStorage.imageUrl,
    );
    final userAddress = await AppLocalStorage.getData(
      key: AppLocalStorage.userAddress,
    );
    print(
      'DEBUG: isLoggedIn=$isLoggedIn, userType=$userType, isOnboardingShown=$isOnboardingShown, userImage=$userImage, userAddress =$userAddress',
    );
    if (!mounted) {
      return;
    } // to make sure not to cause errors if the user navigates while in the delay of the async funtion

    // // Forcing logout for debugging
    // // if the widget is no longer mounted..
    // await AppLocalStorage.removeData(key: AppLocalStorage.uid);
    // Future.delayed(const Duration(milliseconds: 2000));

    if (isLoggedIn != null) {
      if (userType == 'doctor') {
        pushReplacement(context, const DocRegistrationView());
      } else {
        pushReplacement(
            context,
            const PatientNavBar(
              page: 0,
            ));
      }
    } else {
      if (isOnboardingShown) {
        pushReplacement(context, const WelcomeView());
      } else {
        pushReplacement(context, const OnboardingView());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Image.asset(AssetsManager.logoPng, width: 250)],
        ),
      ),
    );
  }
}
