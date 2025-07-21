import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:se7ety/core/enum/profile_fields_enum.dart';
import 'package:se7ety/core/enum/user_type_enum.dart';
import 'package:se7ety/core/services/local_storage.dart';
import 'package:se7ety/core/services/user_services.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial());

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
      emit(SettingsSuccessState(field: field, newValue: newValue));
      // Fetch updated name so UI updates instantly
      await fetchUser();
    } catch (e) {
      emit(SettingsErrorState(e.toString()));
    }
  }

  Future<void> fetchUser() async {
    emit(FetchUserLoadingState());
    try {
      // Get user name from local storage
      final name =
          await AppLocalStorage.getData(key: AppLocalStorage.userName) ?? '';
      final phone =
          await AppLocalStorage.getData(key: AppLocalStorage.userPhone) ?? '';
      final address =
          await AppLocalStorage.getData(key: AppLocalStorage.userAddress) ?? '';
      final age =
          await AppLocalStorage.getData(key: AppLocalStorage.userAge) ?? '';
      final bio =
          await AppLocalStorage.getData(key: AppLocalStorage.userBio) ?? '';
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
