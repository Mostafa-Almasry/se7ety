import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:se7ety/core/enum/profile_fields_enum.dart';
import 'package:se7ety/core/enum/user_type_enum.dart';
import 'package:se7ety/core/services/local_storage.dart';
import 'package:se7ety/core/services/user_services.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial());

  String name = '';
  String phone = '';
  String phone2 = '';
  String address = '';
  String age = '';
  String bio = '';

  Future<void> updateField({
    required ProfileFieldsEnum field,
    required String newValue,
    required UserType userType,
  }) async {
    emit(SettingsLoadingState());
    try {
      await updateLocalUserDetails(
        field: field,
        newValue: newValue,
        userType: userType,
      );
      await fetchUser(
          userType: userType, emitLoading: false); // Avoid loading UI again
      emit(FetchUserSuccessState(
        name: name,
        age: age,
        phoneNumber: phone,
        bio: bio,
        address: address,
      ));
      emit(SettingsSuccessState(field: field, newValue: newValue));
    } catch (e, stack) {
      log(' updateField failed: $e\n$stack', name: 'SettingsCubit');
      emit(SettingsErrorState(e.toString()));
    }
  }

  Future<void> fetchUser(
      {required UserType userType, bool emitLoading = true}) async {
    Map<String, dynamic> data;
    if (emitLoading) emit(FetchUserLoadingState());
    final uid = await AppLocalStorage.getData(key: AppLocalStorage.uid) ?? '';
    try {
      if (userType == UserType.patient) {
        final snapshot = await FirebaseFirestore.instance
            .collection('patients')
            .doc(uid)
            .get();
        data = snapshot.data() ?? {};
      } else {
        final snapshot = await FirebaseFirestore.instance
            .collection('doctors')
            .doc(uid)
            .get();
        data = snapshot.data() ?? {};
      }

      dynamic rawAge = data['age'];
      if (rawAge != null) {
        age = rawAge.toString(); // Convert numbers to string
      } else {
        age = '';
      }

      if (age.isEmpty) {
        age = await AppLocalStorage.getData(key: AppLocalStorage.userAge) ?? '';
      }
      name = data['name'] ?? '';
      phone = userType == UserType.patient
          ? data['phone'] ?? ''
          : data['phone1'] ?? '';
      address = data['address'] ?? '';
      phone2 = data['phone2'];
      bio = data['bio'] ?? '';

      phone = phone.isNotEmpty
          ? phone
          : await AppLocalStorage.getData(key: AppLocalStorage.userPhone) ?? '';
      address = address.isNotEmpty
          ? address
          : await AppLocalStorage.getData(key: AppLocalStorage.userAddress) ??
              '';
      age = age.isNotEmpty
          ? age
          : await AppLocalStorage.getData(key: AppLocalStorage.userAge) ?? '';
      bio = bio.isNotEmpty
          ? bio
          : await AppLocalStorage.getData(key: AppLocalStorage.userBio) ?? '';

      emit(FetchUserSuccessState(
        name: name,
        age: age,
        phoneNumber: phone,
        bio: bio,
        address: address,
      ));
    } catch (e) {
      emit(FetchUserErrorState(e.toString()));
    }
  }
}
