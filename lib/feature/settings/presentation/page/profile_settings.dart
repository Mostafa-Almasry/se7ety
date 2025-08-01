import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se7ety/core/enum/user_type_enum.dart';
import 'package:se7ety/core/services/local_storage.dart';
import 'package:se7ety/feature/auth/data/model/doctor_model.dart';
import 'package:se7ety/feature/settings/data/options/settings_tiles.dart';
import 'package:se7ety/feature/settings/presentation/cubit/settings_cubit.dart';

class ProfileSettingsView extends StatefulWidget {
  const ProfileSettingsView(
      {super.key, required this.userType, this.doctorModel});
  final DoctorModel? doctorModel;
  final UserType userType;

  @override
  State<ProfileSettingsView> createState() => _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends State<ProfileSettingsView> {
  final uid = AppLocalStorage.getData(key: AppLocalStorage.uid);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(true);
        return false;
      },
      child: BlocProvider(
        create: (_) => SettingsCubit()..fetchUser(userType: widget.userType),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              padding: const EdgeInsets.only(right: 10),
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            title: const Text('اعدادات الحساب'),
          ),
          body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection(widget.userType == UserType.patient
                    ? 'patients'
                    : 'doctors')
                .doc(uid)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final doc = snapshot.data!;
              if (!doc.exists) {
                return const Center(
                  child: Text(
                    'لم يتم العثور على بيانات المستخدم',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }

              final userData = doc.data() as Map<String, dynamic>;
              return SettingsTiles(
                setting: 'profileSettings',
                userData: userData,
                userType: widget.userType,
                doctorModel: widget.doctorModel,
              );
            },
          ),
        ),
      ),
    );
  }
}
