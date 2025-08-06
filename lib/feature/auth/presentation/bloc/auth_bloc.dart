import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se7ety/core/enum/profile_fields_enum.dart';
import 'package:se7ety/core/enum/user_type_enum.dart';
import 'package:se7ety/core/functions/dialogs.dart';
import 'package:se7ety/core/services/local_storage.dart';
import 'package:se7ety/core/services/user_services.dart';
import 'package:se7ety/feature/auth/presentation/bloc/auth_event.dart';
import 'package:se7ety/feature/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitialState()) {
    on<AuthEvent>((event, emit) async {
      if (event is RegisterEvent) {
        await register(event, emit);
      } else if (event is LoginEvent) {
        await login(event, emit);
      } else if (event is DocRegistrationEvent) {
        await docRegistration(
          event,
          emit,
          event.imageUrl,
          event.specialisation,
          event.startTime,
          event.endTime,
          event.address,
          event.phone1,
          event.phone2,
          event.bio,
          event.context,
        );
      } else if (event is PatientProfileUpdateEvent) {
        await patientProfileUpdate(
          event,
          emit,
          event.imageUrl,
          event.address,
          event.phone,
          event.name,
          event.age,
          event.context,
        );
      } else if (event is ReauthenticateUserEvent) {
        await reauthenticateUser(event, event.currentPassword, emit);
      }
    });
  }

  Future<void> register(RegisterEvent event, Emitter<AuthState> emit) async {
    log('🧪 userType received during register: ${event.userType}');

    emit(AuthLoadingState());
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      final user = credential.user;

      await user?.updateDisplayName(event.name); // Ensure this completes
      log('🔄 Auth displayName set to: ${user?.displayName}'); // Verify
      if (user == null) {
        emit(AuthErrorState('حدث خطأ أثناء إنشاء الحساب'));
        return;
      }

      await user.updateDisplayName(event.name);
      final uid = user.uid;
      log('✅ Created user with UID: $uid');

      if (event.userType == UserType.patient) {
        await FirebaseFirestore.instance.collection("patients").doc(uid).set({
          'uid': uid,
          'name': event.name,
          'email': event.email,
          'age': '',
          'image': '',
        }, SetOptions(merge: true));
      } else {
        log('📝 Saving doctor data: uid=$uid, name="${event.name}"');
        await FirebaseFirestore.instance.collection("doctors").doc(uid).set({
          'uid': uid,
          'name': event.name,
          'email': event.email,
          'image': '',
          'specialisation': '',
          'bio': '',
          'openHour': '',
          'closeHour': '',
          'address': '',
          'phone1': '',
          'phone2': '',
          'rating': 0,
        }, SetOptions(merge: true));
      }

      await AppLocalStorage.cacheData(key: AppLocalStorage.uid, value: uid);
      await AppLocalStorage.cacheData(
          key: AppLocalStorage.userType, value: event.userType.name);

      await AppLocalStorage.cacheData(
          key: AppLocalStorage.userName, value: event.name);
      log('🗃️ Cached userName = ${event.name}');
      await saveFcmToken(uid, event.userType);
      final docCheck = await FirebaseFirestore.instance
          .collection(
              event.userType == UserType.patient ? "patients" : "doctors")
          .doc(uid)
          .get();

      log('🆕 Initial Firestore doc: ${docCheck.data()}');
      emit(AuthSuccessState(userType: event.userType));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(AuthErrorState('كلمة المرور ضعيفة'));
      } else if (e.code == 'email-already-in-use') {
        emit(AuthErrorState('البريد الالكتروني مستخدم بالفعل'));
      } else {
        emit(AuthErrorState('حدث خطأ ما'));
      }
    } catch (e) {
      log('Unexpected error: $e');
      emit(AuthErrorState('حدث خطأ غير متوقع'));
    }
  }

  Future<void> login(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      final uid = credential.user?.uid;
      if (uid == null) {
        emit(AuthErrorState('حدث خطأ ما'));
        return;
      }

      // Try finding user in patients
      final patientDoc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(uid)
          .get();

      UserType userType;
      String userName = '';

      await FirebaseAuth.instance.currentUser
          ?.reload(); // Force refresh auth data
      final updatedUser = FirebaseAuth.instance.currentUser;
      userName = updatedUser?.displayName ?? userName; // Prefer auth name

      log('🔑 Logged in user: ${updatedUser?.displayName}');

      if (patientDoc.exists) {
        userType = UserType.patient;
        userName = patientDoc.data()?['name'] ?? '';
      } else {
        // If not in patients, try doctors
        final doctorDoc = await FirebaseFirestore.instance
            .collection('doctors')
            .doc(uid)
            .get();

        if (doctorDoc.exists) {
          userType = UserType.doctor;
          userName = doctorDoc.data()?['name'] ?? '';
        } else {
          emit(AuthErrorState('لم يتم العثور على المستخدم في قاعدة البيانات'));
          return;
        }
      }

      await AppLocalStorage.cacheData(key: AppLocalStorage.uid, value: uid);
      await AppLocalStorage.cacheData(
          key: AppLocalStorage.userType, value: userType.name);
      await AppLocalStorage.cacheData(
          key: AppLocalStorage.userName, value: userName);

      await saveFcmToken(uid, userType);

      emit(AuthSuccessState(userType: userType));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(AuthErrorState('لم يتم العثور علي مستخدم بهذا الايميل'));
      } else if (e.code == 'wrong-password') {
        emit(AuthErrorState('كلمة المرور غير صحيحة'));
      } else {
        emit(AuthErrorState('حدث خطأ ما'));
      }
    } catch (e) {
      log('$e');
      emit(AuthErrorState('حدث خطأ غير متوقع'));
    }
  }

  Future<void> docRegistration(
    DocRegistrationEvent event,
    Emitter<AuthState> emit,
    String imageUrl,
    String specialisation,
    String startTime,
    String endTime,
    String address,
    String phone1,
    String phone2,
    String bio,
    BuildContext context,
  ) async {
    emit(AuthLoadingState());
    final uid = AppLocalStorage.getData(key: AppLocalStorage.uid);
    if (uid == null) {
      showErrorDialog(context, 'User ID not found');
      return;
    }

    try {
      // Get name from Firebase Auth (most reliable source)
      final currentUser = FirebaseAuth.instance.currentUser;
      String name = currentUser?.displayName ?? '';

      if (name.isEmpty) {
        // Fallback to local storage if needed
        name = AppLocalStorage.getData(key: AppLocalStorage.userName) ?? '';
      }

      log('🔄 Updating doctor with name: "$name"');

      await FirebaseFirestore.instance.collection('doctors').doc(uid).set({
        'uid': uid,
        'name': name, // CRITICAL: ADD NAME HERE
        'image': imageUrl,
        'specialisation': specialisation,
        'openHour': startTime,
        'closeHour': endTime,
        'address': address,
        'phone1': phone1,
        'phone2': phone2,
        'bio': bio,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      log('🔥 DOCTOR DATA SENT: ${{
        'uid': uid,
        'name': name,
        // 'email': email,
        'image': imageUrl,
        'specialisation': specialisation,
        'openHour': startTime,
        'closeHour': endTime,
        'address': address,
        'phone1': phone1,
        'phone2': phone2,
        'bio': bio,
        'createdAt': 'ServerTimestamp',
        'rating': 0,
      }}');

      // VERIFY: Add this debug check
      final doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(uid)
          .get(const GetOptions(source: Source.server));

      log('✅ Doctor document after update: ${doc.data()}');

      // FIXED: Use correct enum values and remove redundant updates
      updateLocalUserDetails(
        field: ProfileFieldsEnum.bio,
        newValue: bio,
        userType: UserType.doctor,
      );
      updateLocalUserDetails(
        field: ProfileFieldsEnum.phone, // Will save to 'phone1' for doctors
        newValue: phone1,
        userType: UserType.doctor,
      );
      updateLocalUserDetails(
        field: ProfileFieldsEnum.phone2, // NEW: Properly save phone2
        newValue: phone2,
        userType: UserType.doctor,
      );
      updateLocalUserDetails(
        field: ProfileFieldsEnum.address,
        newValue: address,
        userType: UserType.doctor,
      );

      AppLocalStorage.cacheData(
          key: AppLocalStorage.isSignupComplete, value: true);
      emit(AuthSuccessState(userType: UserType.doctor));
      log('✅ Emitted AuthSuccessState after doc registration');
    } catch (e, stack) {
      // Add stack trace
      log('🔥 DOC REGISTRATION ERROR', error: e, stackTrace: stack);
      showErrorDialog(context, 'حدث خطأ أثناء الحفظ: $e');
    }
  }

  Future<void> patientProfileUpdate(
    PatientProfileUpdateEvent event,
    Emitter<AuthState> emit,
    String? imageUrl,
    String? address,
    String? phone,
    String? name,
    String? age,
    BuildContext context,
  ) async {
    emit(AuthLoadingState());
    final uid = AppLocalStorage.getData(key: AppLocalStorage.uid);
    if (uid == null) {
      showErrorDialog(context, 'لم يتم العثور على هوية المستخدم');
      emit(AuthErrorState('لم يتم العثور على هوية المستخدم'));
      return;
    }
    try {
      final updateData = <String, dynamic>{};

      if (imageUrl != null) updateData['image'] = imageUrl;
      if (age != null) updateData['age'] = age;
      if (address != null) updateData['address'] = address;
      if (phone != null) updateData['phone'] = phone;
      if (name != null) updateData['name'] = name;

      // Perform a single Firestore update
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(uid)
          .update(updateData);

      // Update all relevant local storage values at once
      await Future.wait<void>([
        if (imageUrl != null)
          AppLocalStorage.cacheData(
              key: AppLocalStorage.imageUrl, value: imageUrl),
        if (name != null)
          AppLocalStorage.cacheData(key: AppLocalStorage.userName, value: name),
        if (address != null)
          AppLocalStorage.cacheData(
              key: AppLocalStorage.userAddress, value: address),
        if (phone != null)
          AppLocalStorage.cacheData(
              key: AppLocalStorage.userPhone, value: phone),
      ]);
      // Add this to update UI immediately
      emit(ProfileUpdateSuccessState(
          imageUrl: imageUrl, name: name, address: address, phone: phone));
    } catch (e, stack) {
      log('Patient profile update error: $e', stackTrace: stack);
      showErrorDialog(context, 'حدث خطأ أثناء الحفظ: ${e.toString()}');
      emit(AuthErrorState('حدث خطأ أثناء الحفظ'));
    }
  }

  Future<bool> reauthenticateUser(ReauthenticateUserEvent event,
      String currentPassword, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoadingState());
      final user = FirebaseAuth.instance.currentUser;

      if (user == null || user.email == null) {
        throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'لا يوجد مستخدم مسجّل الدخول حالياً');
      }

      final credential = EmailAuthProvider.credential(
          email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(credential);
      emit(CheckPasswordConfirmedState());
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        emit(CheckPasswordErrorState(message: 'wrong-password'));
        return false; // the password is wrong!
      } else {
        emit(CheckPasswordErrorState(message: 'كلمة المرور غير صحيحة'));
        rethrow; // any other error
      }
    }
  }

  Future<void> saveFcmToken(String uid, UserType userType) async {
    final token = await FirebaseMessaging.instance.getToken();
    final collection = userType == UserType.doctor ? 'doctors' : 'patients';
    if (token != null) {
      FirebaseFirestore.instance
          .collection(collection)
          .doc(uid)
          .update({'FcmToken': token});
    }
  }
}
