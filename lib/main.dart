import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:se7ety/core/services/local_storage.dart';
import 'package:se7ety/core/utils/themes.dart';
import 'package:se7ety/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:se7ety/feature/intro/splash_view.dart';
import 'package:se7ety/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AppLocalStorage.init();

  await AppLocalStorage.cacheData(
    key: AppLocalStorage.isOnboardingShown,
    value: true,
  ); // Manually setting the isOnboardingShown to true for debugging.

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppThemes.lightTheme,
        locale: const Locale('ar'),
        supportedLocales: const [
          Locale('ar'),
        ], // Add more supported languages if availabe,
        // Switch between langs using locale with Cubit.
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: SplashView(),
      ),
    );
  }
}
// Accounts:
  // patients: 
    // Mostafa Elta3ban
    // mostafa@marad.com
    // 12345678
  // Doctors: 
    // Dr.kazem
    // kazem@saher.com
    // 11111111
    // studied at mscks university (gam3a kbera awy bardo)
    // el share3 elle wara elle wara elle ware elle wrakom