import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:se7ety/core/enum/profile_fields_enum.dart';
import 'package:se7ety/core/enum/user_type_enum.dart';
import 'package:se7ety/core/services/local_storage.dart';

Future<void> updateLocalUserDetails(
    {required ProfileFieldsEnum field,
    required String newValue,
    required UserType userType}) async {
  // Map enum to Firestore field name
  String fieldText;
  switch (field) {
    case ProfileFieldsEnum.name:
      fieldText = 'name';
      break;
    case ProfileFieldsEnum.address:
      fieldText = 'address';
      break;
    case ProfileFieldsEnum.phone:
      fieldText = 'phone';
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

  final uid =
      await AppLocalStorage.getData(key: AppLocalStorage.uid) as String?;
  if (uid == null) throw Exception('No UID in local storage');
  await FirebaseFirestore.instance
      .collection(col)
      .doc(uid)
      .update({fieldText: newValue});
  final storageKey = {
    ProfileFieldsEnum.name: AppLocalStorage.userName,
    ProfileFieldsEnum.address: AppLocalStorage.userAddress,
    ProfileFieldsEnum.phone: AppLocalStorage.userPhone,
    ProfileFieldsEnum.age: AppLocalStorage.userAge,
    ProfileFieldsEnum.bio: AppLocalStorage.userBio,
  }[field]!; 
  // Map each enum to the corresponding SharedPreferences key
    // so we update the local cache under the correct storage constant.
  await AppLocalStorage.cacheData(key: storageKey, value: newValue);
}
