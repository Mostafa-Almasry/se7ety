import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:se7ety/core/services/local_storage.dart';
import 'package:se7ety/core/utils/themes.dart';
import 'package:se7ety/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:se7ety/feature/intro/splash_view.dart';
import 'package:se7ety/feature/settings/presentation/cubit/settings_cubit.dart';
import 'package:se7ety/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AppLocalStorage.init();

  await AppLocalStorage.cacheData(
    key: AppLocalStorage.isOnboardingShown,
    value: true,
  );

  // await updateUserDetails(
  //     field: ProfileFieldsEnum.age, newValue: '25', userType: UserType.patient);
  // await updateUserDetails(
  //     field: ProfileFieldsEnum.address,
  //     newValue: 'القاهرة',
  //     userType: UserType.patient);
  // await updateUserDetails(
  //     field: ProfileFieldsEnum.phone,
  //     newValue: '01144070077',
  //     userType: UserType.patient);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(),
        ),
        BlocProvider(
          create: (context) => SettingsCubit(),
        ),
      ],
      child: SafeArea(
        top: false,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme,
          locale: const Locale('ar'),
          supportedLocales: const [
            Locale('ar'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: const SplashView(),
        ),
      ),
    );
  }
}
