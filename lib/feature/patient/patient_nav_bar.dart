import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:se7ety/core/enum/user_type_enum.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/feature/appointments/appointments_view.dart';
import 'package:se7ety/feature/patient/home/presentation/page/patient_home_view.dart';
import 'package:se7ety/feature/patient/search/page/search_view.dart';
import 'package:se7ety/feature/profile/profile_view.dart';
import 'package:se7ety/feature/settings/presentation/cubit/settings_cubit.dart';

class PatientNavBar extends StatefulWidget {
  const PatientNavBar({super.key, required this.page});
  final int page;

  @override
  PatientNavBarState createState() => PatientNavBarState();
}

class PatientNavBarState extends State<PatientNavBar> {
  int _selectedIndex = 0;
  final List<int> _navigationHistory = [];

  final List<GlobalKey<NavigatorState>> _navigatorKeys =
      List.generate(4, (_) => GlobalKey<NavigatorState>());

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.page;
    _navigationHistory.add(_selectedIndex);
  }

  Widget _buildTabNavigator(int index, Widget child) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => child),
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        final currentNavigator = _navigatorKeys[_selectedIndex].currentState;

        if (currentNavigator != null && currentNavigator.canPop()) {
          currentNavigator.pop();
          return false;
        } else if (_navigationHistory.length > 1) {
          setState(() {
            _navigationHistory.removeLast();
            _selectedIndex = _navigationHistory.last;
          });
          return false;
        } else {
          return true; // Allow system to close app
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            _buildTabNavigator(0, const PatientHomeView()),
            _buildTabNavigator(1, const SearchView(searchKey: '')),
            _buildTabNavigator(
                2, const AppointmentsView(userType: UserType.patient)),
            _buildTabNavigator(
              3,
              BlocProvider(
                create: (context) => SettingsCubit(),
                child: const ProfileView(userType: UserType.patient),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding:
              const EdgeInsets.only(right: 10, left: 10, top: 13, bottom: 13),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.only(
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            duration: const Duration(milliseconds: 300),
            tabBackgroundColor: AppColors.color1,
            textStyle: getBodyStyle(color: AppColors.white),
            tabs: const [
              GButton(iconSize: 28, icon: Icons.home, text: 'الرئيسية'),
              GButton(icon: Icons.search, text: 'البحث'),
              GButton(
                  iconSize: 28,
                  icon: Icons.calendar_month_rounded,
                  text: 'المواعيد'),
              GButton(iconSize: 29, icon: Icons.person, text: 'الحساب'),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (value) {
              if (value != _selectedIndex) {
                setState(() {
                  _selectedIndex = value;
                  _navigationHistory.remove(value);
                  _navigationHistory.add(value);
                });
              }
            },
          ),
        ),
      ),
    );
  }
}
