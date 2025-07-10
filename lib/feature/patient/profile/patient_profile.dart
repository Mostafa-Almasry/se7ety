import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:se7ety/core/constants/assets_manager.dart';
import 'package:se7ety/core/functions/dialogs.dart';
import 'package:se7ety/core/functions/navigation.dart';
import 'package:se7ety/core/services/local_storage.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:se7ety/feature/auth/presentation/bloc/auth_event.dart';
import 'package:se7ety/feature/patient/appointments/appointments_list.dart';
import 'package:se7ety/feature/patient/search/widgets/info_tile_widget.dart';
import 'package:se7ety/feature/settings/presentation/page/settings_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientProfileView extends StatefulWidget {
  const PatientProfileView({super.key});

  @override
  State<PatientProfileView> createState() => _PatientProfileViewState();
}

class _PatientProfileViewState extends State<PatientProfileView> {
  final user = FirebaseAuth.instance.currentUser;
  String _avatarImageUrl =
      AppLocalStorage.getData(key: AppLocalStorage.imageUrl) ?? '';

  final String _name =
      AppLocalStorage.getData(key: AppLocalStorage.userName) ?? '';
  final String _phone =
      AppLocalStorage.getData(key: AppLocalStorage.userPhone) ?? '';

  final String? _address =
      AppLocalStorage.getData(key: AppLocalStorage.userAddress) ?? '';

  Future<String?> uploadToCloudinary(File imageFile) async {
    final cloudName = 'dvhb0hsj3';
    final uploadPreset = 'unsigned_pfp';
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request =
        http.MultipartRequest('POST', uri)
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('الحساب الشخصي'),
        actions: [
          IconButton(
            onPressed: () {
              push(context, SettingsView());
            },
            icon: Icon(Icons.settings),
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
                        backgroundImage:
                            _avatarImageUrl.isNotEmpty
                                ? NetworkImage(_avatarImageUrl)
                                : AssetImage(AssetsManager.doctor),
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

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_name, style: getTitleStyle()),
                    const Gap(15),
                    Text(_address ?? '', style: getBodyStyle()),
                  ],
                ),
              ],
            ),

            const Gap(30),
            Row(children: [Text('معلومات المستخدم', style: getBodyStyle())]),
            const Gap(15),
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
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              showPastAppointments: true,
              scrollable: false,
            ),
          ],
        ),
      ),
    );
  }
}
