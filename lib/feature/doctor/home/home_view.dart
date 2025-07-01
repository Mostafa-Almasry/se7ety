import 'package:flutter/material.dart';
import 'package:se7ety/core/utils/text_styles.dart';

class DoctorHomeView extends StatelessWidget {
  const DoctorHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text('بكرا إن شاء اللّه ,Phase 3', style: getTitleStyle()),
          ),
        ],
      ),
    );
  }
}
