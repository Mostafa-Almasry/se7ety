part of 'settings_cubit.dart';

@immutable
sealed class SettingsState {}

final class SettingsInitial extends SettingsState {}

final class SettingsLoadingState extends SettingsState {}

final class SettingsSuccessState extends SettingsState {
  final ProfileFieldsEnum field;
  final String newValue;
  SettingsSuccessState({required this.field, required this.newValue});
}

final class SettingsErrorState extends SettingsState {
  final String message;
  SettingsErrorState(this.message);
}

final class FetchUserInitialState extends SettingsState {}

final class FetchUserLoadingState extends SettingsState {}

final class FetchUserSuccessState extends SettingsState {
  final String name;
  final String phoneNumber;
  final String bio;
  final String address;
  final String age;
  FetchUserSuccessState(
      {required this.name,
      required this.age,
      required this.phoneNumber,
      required this.bio,
      required this.address});
}

final class FetchUserErrorState extends SettingsState {
  final String message;
  FetchUserErrorState(this.message);
}
