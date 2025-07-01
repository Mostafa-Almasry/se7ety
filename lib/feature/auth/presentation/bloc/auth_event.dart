import 'package:flutter/material.dart';
import 'package:se7ety/core/enum/user_type_enum.dart';

class AuthEvent {}

class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final UserType userType;

  RegisterEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.userType,
  });
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  final UserType userType;

  LoginEvent({
    required this.email,
    required this.password,
    required this.userType,
  });
}

class docRegistrationEvent extends AuthEvent {
  final BuildContext context;
  final String specialisation;
  final String imageUrl;
  final String startTime;
  final String endTime;
  final String address;
  final String phone1;
  final String phone2;
  final String bio;

  docRegistrationEvent({
    required this.context,
    required this.imageUrl,
    required this.specialisation,
    required this.startTime,
    required this.endTime,
    required this.address,
    required this.phone1,
    required this.phone2,
    required this.bio,
  });
}
