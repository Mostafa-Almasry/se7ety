class AuthState {}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthSuccessState extends AuthState {}

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
