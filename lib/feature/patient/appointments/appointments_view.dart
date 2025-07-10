import 'package:flutter/material.dart';
import 'package:se7ety/feature/patient/appointments/appointments_list.dart';

class AppointmentsView extends StatefulWidget {
  const AppointmentsView({super.key});

  @override
  State<AppointmentsView> createState() => _AppointmentsViewState();
}

class _AppointmentsViewState extends State<AppointmentsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('مواعيد الحجز')),
      body: AppointmentsList(),
    );
  }
}
