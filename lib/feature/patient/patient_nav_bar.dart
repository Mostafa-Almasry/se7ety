import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/feature/patient/appointments/appointments_view.dart';
import 'package:se7ety/feature/patient/home/presentation/page/patient_home_view.dart';
import 'package:se7ety/feature/patient/profile/patient_profile.dart';
import 'package:se7ety/feature/patient/search/page/search_view.dart';

class PatientNavBar extends StatefulWidget {
  const PatientNavBar({super.key});

  @override
  State<PatientNavBar> createState() => _PatientNavBarState();
}

class _PatientNavBarState extends State<PatientNavBar> {
  int _selectedIndex = 0;
  final List _pages = [
    const PatientHomeView(), // Home Screen
    const SearchView(searchKey: ''), // SearchView
    AppointmentsView(), // MyAppointments
    PatientProfileView(), // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(
          right: 10,
          left: 10,
          top: 13,
          bottom: 13,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.2)),
          ],
        ),
        child: GNav(
          curve: Curves.easeOutExpo,
          rippleColor: AppColors.grey,
          hoverColor: AppColors.grey,
          haptic: true,
          gap: 5,
          activeColor: AppColors.white,
          tabBorderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: const Duration(milliseconds: 300),
          tabBackgroundColor: AppColors.color1,
          textStyle: getBodyStyle(color: AppColors.white),
          tabs: const [
            GButton(iconSize: 28, icon: Icons.home, text: 'الرئيسية'),
            GButton(icon: Icons.search, text: 'البحث'),
            GButton(
              iconSize: 28,
              icon: Icons.calendar_month_rounded,
              text: 'المواعيد',
            ),
            GButton(iconSize: 29, icon: Icons.person, text: 'الحساب'),
          ],
          selectedIndex: _selectedIndex,
          onTabChange: (value) {
            setState(() {
              _selectedIndex = value;
            });
          },
        ),
      ),
    );
  }
}
