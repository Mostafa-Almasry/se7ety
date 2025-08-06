import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:se7ety/core/enum/profile_fields_enum.dart';
import 'package:se7ety/core/enum/user_type_enum.dart';
import 'package:se7ety/core/services/local_storage.dart';

Future<void> updateLocalUserDetails({
  required ProfileFieldsEnum field,
  required String newValue,
  required UserType userType,
}) async {
  // Determine Firestore field name based on user type
  String fieldText;
  switch (field) {
    case ProfileFieldsEnum.name:
      fieldText = 'name';
      break;
    case ProfileFieldsEnum.address:
      fieldText = 'address';
      break;
    case ProfileFieldsEnum.phone:
      // DOCTORS use 'phone1', PATIENTS use 'phone'
      fieldText = userType == UserType.doctor ? 'phone1' : 'phone';
      break;
    case ProfileFieldsEnum.phone2:  // Add this new case
      fieldText = 'phone2';
      break;
    case ProfileFieldsEnum.bio:
      fieldText = 'bio';
      break;
    case ProfileFieldsEnum.age:
      fieldText = 'age';
      break;
    default:
      fieldText = 'name';
  }

  final col = userType == UserType.patient ? 'patients' : 'doctors';

  final uid = AppLocalStorage.getData(key: AppLocalStorage.uid);
  if (uid == null || uid is! String) {
    throw Exception('No UID in local storage');
  }

  // Update Firestore
  await FirebaseFirestore.instance
      .collection(col)
      .doc(uid)
      .update({fieldText: newValue});

  // Update local cache (SharedPreferences)
  final storageKey = {
    ProfileFieldsEnum.name: AppLocalStorage.userName,
    ProfileFieldsEnum.address: AppLocalStorage.userAddress,
    ProfileFieldsEnum.phone: AppLocalStorage.userPhone,
    ProfileFieldsEnum.phone2: AppLocalStorage.userPhone2,
    ProfileFieldsEnum.age: AppLocalStorage.userAge,
    ProfileFieldsEnum.bio: AppLocalStorage.userBio,
  }[field];

  if (storageKey != null) {
    await AppLocalStorage.cacheData(key: storageKey, value: newValue);
  }
}