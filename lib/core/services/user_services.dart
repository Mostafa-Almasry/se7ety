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
  final uid =
      await AppLocalStorage.getData(key: AppLocalStorage.uid) as String?;
  await FirebaseFirestore.instance
      .collection('patients')
      .doc(uid)
      .update({fieldText: newValue});
  await AppLocalStorage.cacheData(key: fieldText, value: newValue);
  final getName =
      await FirebaseFirestore.instance.collection('patients').doc(uid).get();
  String getString = getName.toString();
  print(
      '$getString -00000000000000000000000000000000000000000-293468590268-35');
}
// '${userType.toString()}s'