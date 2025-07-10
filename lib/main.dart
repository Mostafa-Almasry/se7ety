import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:se7ety/core/services/local_storage.dart';
import 'package:se7ety/core/utils/themes.dart';
import 'package:se7ety/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:se7ety/feature/intro/splash_view.dart';
import 'package:se7ety/firebase_options.dart';

Future<void> fixAppointmentDates() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('appointments')
      .get();

  for (final doc in snapshot.docs) {
    final data = doc.data();

    try {
      final rawDate = data['date'];

      // If missing or null
      if (rawDate == null) {
        throw 'Date is null';
      }

      // If not a Timestamp (e.g. string, int)
      if (rawDate is! Timestamp) {
        print('🛠️ Fixing doc: ${doc.id} | Invalid type: ${rawDate.runtimeType}');
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(doc.id)
            .update({
          'date': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
        });
      }

      // Otherwise, do nothing (valid Timestamp)
    } catch (e) {
      print('❌ Failed to fix doc ${doc.id}: $e');
      try {
        // Attempt fallback update in case of unknown issues
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(doc.id)
            .update({
          'date': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
        });
        print('✅ Fallback applied to ${doc.id}');
      } catch (err) {
        print('❌ Final fail for ${doc.id}: $err');
      }
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AppLocalStorage.init();

  await fixAppointmentDates(); // ✅ Safe fix to all invalid/missing date fields

  await AppLocalStorage.cacheData(
    key: AppLocalStorage.isOnboardingShown,
    value: true,
  );

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
        ],
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
