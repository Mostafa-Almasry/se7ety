import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se7ety/core/enum/user_type_enum.dart';
import 'package:se7ety/core/services/local_storage.dart';
import 'package:se7ety/feature/settings/data/model/settings_model.dart';
import 'package:se7ety/feature/settings/data/options/settings_tiles.dart';
import 'package:se7ety/feature/settings/presentation/cubit/settings_cubit.dart';

class ProfileSettingsView extends StatefulWidget {
  const ProfileSettingsView({super.key, required this.userType});
  final UserType userType;

  @override
  State<ProfileSettingsView> createState() => _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends State<ProfileSettingsView> {
  final List<SettingsModel> profileFields = [];
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
         create: (_) => SettingsCubit()..fetchUser(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            padding: const EdgeInsets.only(right: 10),
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('اعدادات الحساب'),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('patients')
              .doc(AppLocalStorage.getData(key: AppLocalStorage.uid))
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            return SettingsTiles(
              setting: 'profileSettings',
              userData: userData,
              userType: widget.userType,
            );
          },
        ),
      ),
    );
  }
}
