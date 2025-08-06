import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:se7ety/core/constants/assets_manager.dart';
import 'package:se7ety/core/enum/user_type_enum.dart';
import 'package:se7ety/core/functions/dialogs.dart';
import 'package:se7ety/core/services/local_storage.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/feature/appointments/appointments_list.dart';
import 'package:se7ety/feature/auth/data/model/doctor_model.dart';
import 'package:se7ety/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:se7ety/feature/auth/presentation/bloc/auth_event.dart';
import 'package:se7ety/feature/patient/search/widgets/info_tile_widget.dart';
import 'package:se7ety/feature/settings/presentation/cubit/settings_cubit.dart';
import 'package:se7ety/feature/settings/presentation/page/settings_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key, required this.userType});
  final UserType userType;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isUploadingImage = false;
  final user = FirebaseAuth.instance.currentUser;
  String _avatarImageUrl = '';
  DoctorModel? _doctorModel;
  String? uid;
  bool _isLoading = true;
  // final displayName = _doctorModel?.name??'-';

  @override
  void initState() {
    super.initState();
    uid = AppLocalStorage.getData(key: AppLocalStorage.uid);
    _refreshAll();
  }

  Future<void> _refreshAll() async {
    setState(() => _isLoading = true);
    // fetch cubit data
    await context.read<SettingsCubit>().fetchUser(userType: widget.userType);
    // fetch doctor or image
    if (widget.userType == UserType.doctor) {
      if (uid != null) {
        try {
          final snapshot = await FirebaseFirestore.instance
              .collection('doctors')
              .doc(uid)
              .get();
          if (snapshot.exists) {
            final model = DoctorModel.fromJson(snapshot.data()!);
            setState(() {
              _doctorModel = model;
              _avatarImageUrl = model.image ?? _avatarImageUrl;
            });
          }
        } catch (e) {
          log('Error fetching doctor data: $e');
        }
      }
    } else {
      if (uid != null) {
        try {
          final snapshot = await FirebaseFirestore.instance
              .collection('patients')
              .doc(uid)
              .get();

          final patientData = snapshot.data();
          final imageUrl = patientData?['image'] ?? '';

          setState(() {
            _avatarImageUrl = imageUrl;
            if (patientData != null && patientData['age'] != null) {
              context.read<SettingsCubit>().age = patientData['age'].toString();
            }
          });
        } catch (e) {
          log('Error fetching patient image: $e');
          setState(() {
            _avatarImageUrl = '';
          });
        }
      }
    }

    setState(() => _isLoading = false);
  }

  Future<String?> uploadToCloudinary(File imageFile) async {
    const cloudName = 'dvhb0hsj3';
    const uploadPreset = 'unsigned_pfp';
    final uri =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final resMap = jsonDecode(resStr);
      final imageUrl = resMap['secure_url'];

      showSuccessDialog(context, 'تم رفع الصورة بنجاح');
      return imageUrl;
    } else {
      log('Failed to upload image: ${response.statusCode}');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // prevent flicker by showing loader until all data ready
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الحساب الشخصي'),
        actions: [
          IconButton(
            onPressed: () async {
              final bool? didUpdate =
                  await Navigator.of(context, rootNavigator: true).push<bool>(
                MaterialPageRoute(
                  builder: (_) => SettingsView(
                    userType: widget.userType,
                    doctorModel: _doctorModel,
                  ),
                ),
              );

              if (didUpdate == true) {
                _refreshAll();
              }
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
                  onTap: () async {
                    log('usertype is ${widget.userType}');
                    log('name is ${_doctorModel?.name}');
                    await showPfpBottomSheet(context, (File imageFile) async {
                      setState(() => _isUploadingImage = true); // start loading

                      final imageUrl = await uploadToCloudinary(imageFile);
                      if (imageUrl != null) {
                        setState(() => _avatarImageUrl = imageUrl);

                        if (widget.userType == UserType.patient) {
                          log('Updating Firestore for patient...');
                          if (uid != null) {
                            await FirebaseFirestore.instance
                                .collection('patients')
                                .doc(uid)
                                .update({'image': imageUrl});
                          }

                          context.read<AuthBloc>().add(
                                PatientProfileUpdateEvent(
                                    context: context, imageUrl: imageUrl),
                              );
                        } else if (widget.userType == UserType.doctor &&
                            uid != null) {
                          log('Updating Firestore for doctor...');
                          await FirebaseFirestore.instance
                              .collection('doctors')
                              .doc(uid)
                              .update({'image': imageUrl});
                          setState(() {
                            _doctorModel =
                                _doctorModel?.copyWith(image: imageUrl);
                          });
                        }
                      } else {
                        showErrorDialog(context, 'فشل في رفع الصورة');
                      }
                      setState(() => _isUploadingImage = false); // stop loading
                    });
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _avatarImageUrl.isNotEmpty
                            ? NetworkImage(_avatarImageUrl)
                            : AssetImage(
                                widget.userType == UserType.patient
                                    ? AssetsManager.patient
                                    : AssetsManager.doctor,
                              ) as ImageProvider<Object>,
                      ),
                      if (_isUploadingImage)
                        const Positioned.fill(
                          child: SizedBox(
                            width: 130,
                            height: 130,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              color: AppColors.color1,
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          child: const Icon(Icons.camera_alt_rounded,
                              size: 20, color: AppColors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(30),
                Expanded(
                  child: BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (context, state) {
                      final cubit = context.read<SettingsCubit>();
                      final name = widget.userType == UserType.doctor
                          ? _doctorModel?.name ?? 'No Name Is In doctorModel'
                          : cubit.name;
                      final ageOrSpec = widget.userType == UserType.patient
                          ? cubit.age
                          : _doctorModel?.specialisation ?? '';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: getTitleStyle(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const Gap(15),
                          Text(
                            ageOrSpec,
                            style: getBodyStyle(),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            const Gap(30),
            Row(children: [
              Text(
                  widget.userType == UserType.patient
                      ? 'معلومات المستخدم'
                      : 'نبذة تعريفية',
                  style: getBodyStyle())
            ]),
            const Gap(15),
            Container(
              padding: const EdgeInsets.all(15),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  final cubit = context.read<SettingsCubit>();
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TileWidget(icon: Icons.email, text: user?.email ?? ''),
                      const Gap(25),
                      TileWidget(
                        icon: Icons.location_on_outlined,
                        text: widget.userType == UserType.patient
                            ? cubit.address
                            : _doctorModel?.address ?? '',
                      ),
                      const Gap(25),
                      TileWidget(
                        icon: Icons.phone,
                        text: widget.userType == UserType.patient
                            ? cubit.phone
                            : _doctorModel?.phone1 ?? '',
                      ),
                    ],
                  );
                },
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
  }
}
