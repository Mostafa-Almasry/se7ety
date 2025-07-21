import 'package:flutter/material.dart';
import 'package:se7ety/core/enum/user_type_enum.dart';
import 'package:se7ety/feature/appointments/appointments_list.dart';

class AppointmentsView extends StatefulWidget {
  const AppointmentsView({super.key, required this.userType});
  final UserType userType;

  @override
  State<AppointmentsView> createState() => _AppointmentsViewState();
}

class _AppointmentsViewState extends State<AppointmentsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مواعيد الحجز')),
      body: AppointmentsList(
        userType: widget.userType,
      ),
    );
  }
}
