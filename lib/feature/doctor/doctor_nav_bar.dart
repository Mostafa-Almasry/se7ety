import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:se7ety/core/enum/user_type_enum.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/feature/appointments/appointments_view.dart';
import 'package:se7ety/feature/profile/profile_view.dart';
import 'package:se7ety/feature/settings/presentation/cubit/settings_cubit.dart';

class DoctorNavBar extends StatefulWidget {
  const DoctorNavBar({super.key, required this.page});
  final int page;

  @override
  State<DoctorNavBar> createState() => _DoctorNavBarState();
}

class _DoctorNavBarState extends State<DoctorNavBar> {
  int _selectedIndex = 0;

  final _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.page;
  }

  Future<bool> _onWillPop() async {
    final isFirstRouteInCurrentTab =
        !(await _navigatorKeys[_selectedIndex].currentState!.maybePop());

    if (isFirstRouteInCurrentTab) {
      if (_selectedIndex != 0) {
        setState(() {
          _selectedIndex = 0;
        });
        return false;
      }
    }

    return isFirstRouteInCurrentTab;
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          late Widget page;
          if (index == 0) {
            page = const AppointmentsView(userType: UserType.doctor);
          } else {
            page = BlocProvider(
              create: (_) => SettingsCubit(),
              child: const ProfileView(userType: UserType.doctor),
            );
          }
          return MaterialPageRoute(builder: (_) => page);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            _buildOffstageNavigator(0),
            _buildOffstageNavigator(1),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(blurRadius: 15, color: Colors.black.withOpacity(.2)),
            ],
          ),
          child: GNav(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            curve: Curves.easeOutExpo,
            rippleColor: AppColors.grey,
            hoverColor: AppColors.grey,
            haptic: true,
            gap: 0,
            activeColor: AppColors.white,
            tabBorderRadius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 300),
            tabBackgroundColor: AppColors.color1,
            textStyle: getBodyStyle(color: AppColors.white),
            tabs: const [
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
      ),
    );
  }
}
