import 'package:se7ety/core/enum/user_type_enum.dart';

class AuthState {}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthSuccessState extends AuthState {
  final UserType userType;
  AuthSuccessState({required this.userType});
}

class AuthErrorState extends AuthState {
  final String message;
  AuthErrorState(this.message);
}

class UpdateDocRegistrationState extends AuthState {}

class CheckPasswordConfirmedState extends AuthState {}

class CheckPasswordLoadingState extends AuthState {}

class CheckPasswordErrorState extends AuthState {
  final String message;

  CheckPasswordErrorState({required this.message});
}

class ProfileUpdateSuccessState extends AuthState {
  final String? imageUrl;
  final String? name;
  final String? address;
  final String? phone;

  ProfileUpdateSuccessState({
    this.imageUrl,
    this.name,
    this.address,
    this.phone,
  });
}
