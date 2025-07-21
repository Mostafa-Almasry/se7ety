import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:se7ety/core/constants/assets_manager.dart';
import 'package:se7ety/core/enum/user_type_enum.dart';
import 'package:se7ety/core/functions/dialogs.dart';
import 'package:se7ety/core/functions/navigation.dart';
import 'package:se7ety/core/services/local_storage.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/feature/appointments/appointments_list.dart';
import 'package:se7ety/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:se7ety/feature/auth/presentation/bloc/auth_event.dart';
import 'package:se7ety/feature/patient/search/widgets/info_tile_widget.dart';
import 'package:se7ety/feature/settings/presentation/cubit/settings_cubit.dart';
import 'package:se7ety/feature/settings/presentation/page/settings_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key, required this.userType});
  final UserType userType;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final user = FirebaseAuth.instance.currentUser;
  String _avatarImageUrl =
      AppLocalStorage.getData(key: AppLocalStorage.imageUrl) ?? '';
  final String _phone =
      AppLocalStorage.getData(key: AppLocalStorage.userPhone) ?? '';
  final String? _address =
      AppLocalStorage.getData(key: AppLocalStorage.userAddress) ?? '';
  String name = AppLocalStorage.getData(key: AppLocalStorage.userName) ?? '';
  final String _age =
      AppLocalStorage.getData(key: AppLocalStorage.userAge) ?? '';

  Future<String?> uploadToCloudinary(File imageFile) async {
    const cloudName = 'dvhb0hsj3';
    const uploadPreset = 'unsigned_pfp';
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

    final response = await request.send();

    if (response.statusCode == 200) {
      // Wait for the Stream to complete and makes it a String
      final resStr = await response.stream.bytesToString();

      // Transform the Json (resStr) to a dart map
      final resMap = jsonDecode(resStr);

      // get the secure_url key of the map that stores the url of the image
      final imageUrl = resMap['secure_url'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppLocalStorage.imageUrl, imageUrl);
      return imageUrl;
    } else {
      print('Failed to upload image: ${response.statusCode}');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is FetchUserSuccessState) {
          name = state.name;
        } else if (state is FetchUserErrorState) {
          showErrorDialog(context, 'error fetching name');
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('الحساب الشخصي'),
            actions: [
              IconButton(
                onPressed: () async {
                  await pushReplacement(
                    context,
                    const SettingsView(userType: UserType.patient),
                  );
                  // Refresh name after returning from settings
                  context.read<SettingsCubit>().fetchUser();
                },
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showPfpBottomSheet(context, (File imageFile) async {
                          // Upload image to Cloudinary
                          final imageUrl = await uploadToCloudinary(imageFile);
                          if (imageUrl != null) {
                            setState(() {
                              _avatarImageUrl = imageUrl;
                              // Update 'image' in Firestore
                              context.read<AuthBloc>().add(
                                    PatientProfileUpdateEvent(
                                      context: context,
                                      imageUrl: imageUrl,
                                    ),
                                  );
                            });
                          } else {
                            showErrorDialog(context, 'فشل في رفع الصورة');
                          }
                        });
                      },
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _avatarImageUrl.isNotEmpty
                                ? NetworkImage(_avatarImageUrl)
                                : const AssetImage(AssetsManager.doctor)
                                    as ImageProvider<Object>,
                          ),
                          CircleAvatar(
                            radius: 15,
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 20,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 30),
                    const SizedBox(height: 30),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlocBuilder<SettingsCubit, SettingsState>(
                            builder: (context, state) {
                              return Text(
                                name,
                                style: getTitleStyle(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                          const Gap(15),
                          widget.userType == UserType.patient
                              ? Text(_age, style: getBodyStyle())
                              : Text(_address ?? '', style: getBodyStyle())
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(30),
                Row(children: [
                  widget.userType == UserType.patient
                      ? Text('معلومات المستخدم', style: getBodyStyle())
                      : Text('نبذة تعريفية', style: getBodyStyle())
                ]),
                const Gap(15),

                // Contact Info
                Container(
                  padding: const EdgeInsets.all(15),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TileWidget(icon: Icons.email, text: user?.email ?? ''),
                      const Gap(25),
                      TileWidget(
                        icon: Icons.location_on_outlined,
                        text: _address ?? '',
                      ),
                      const Gap(25),
                      TileWidget(icon: Icons.phone, text: _phone),
                    ],
                  ),
                ),

                const Divider(),
                const Gap(10),

                Row(children: [Text('حجوزاتي', style: getBodyStyle())]),
                const Gap(15),
                AppointmentsList(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  showPastAppointments: true,
                  scrollable: false,
                  userType: widget.userType,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
