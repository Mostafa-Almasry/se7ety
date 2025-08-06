import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:se7ety/core/constants/assets_manager.dart';
import 'package:se7ety/core/constants/specialisation.dart';
import 'package:se7ety/core/functions/dialogs.dart';
import 'package:se7ety/core/functions/navigation.dart';
import 'package:se7ety/core/services/local_storage.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/core/widgets/bottom_navigation_button.dart';
import 'package:se7ety/core/widgets/custom_text_form_field.dart';
import 'package:se7ety/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:se7ety/feature/auth/presentation/bloc/auth_event.dart';
import 'package:se7ety/feature/auth/presentation/bloc/auth_state.dart';
import 'package:se7ety/feature/doctor/doctor_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocRegistrationView extends StatefulWidget {
  const DocRegistrationView({super.key});

  @override
  State<DocRegistrationView> createState() => _DocRegistrationViewState();
}

class _DocRegistrationViewState extends State<DocRegistrationView> {
  final GlobalKey<FormState> _docRegistrationKey = GlobalKey<FormState>();
  String _specialisation = specialisation[0];
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _phone1Controller = TextEditingController();
  final TextEditingController _phone2Controller = TextEditingController();
  TimeOfDay? _startTimePicked;
  TimeOfDay? _endTimePicked;
  String _avatarImageUrl = '';
  bool isFirstPhoneNumber = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _startTimeController.text = '';
    _endTimeController.text = '';
  }

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
      log('Failed to upload image: ${response.statusCode}');
      return null;
    }
  }

  String? validatePhone(String? value) {
    if (isFirstPhoneNumber) {
      if (value == null || value.trim().isEmpty) {
        return 'من فضلك ادخل رقم الهاتف';
      }

      final trimmed = value.trim();

      if (!RegExp(r'^\d{9,15}$').hasMatch(trimmed)) {
        return 'ادخل رقم هاتف صالح';
      }

      return null;
    } else {
      if (value != null && value.trim().isNotEmpty) {
        final trimmed = value.trim();

        if (!RegExp(r'^\d{9,15}$').hasMatch(trimmed)) {
          return 'ادخل رقم هاتف صالح';
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            onPressed: () async {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog.adaptive(
                        title: const Text('الغاء الحساب'),
                        content: (const Text('هل انت متأكد من الغاء الحساب؟')),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: AppColors.color1,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text('تراجع',
                                style: getBodyStyle(color: AppColors.white)),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: AppColors.redColor,
                            ),
                            onPressed: () async {
                              final uid = AppLocalStorage.getData(
                                  key: AppLocalStorage.uid);
                              await FirebaseFirestore.instance
                                  .collection('doctors')
                                  .doc(uid)
                                  .delete();
                              Navigator.pop(context); // Pop the dialog
                              Navigator.pop(context); // Pop this screen
                              showErrorDialog(context, 'لم يتم انشاء الحساب');
                            },
                            child: Text('حذف الحساب',
                                style: getBodyStyle(color: AppColors.white)),
                          ),
                        ],
                      ));
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('إكمال عملية التسجيل')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoadingState) {
            showLoadingDialog(context);
          } else if (state is AuthErrorState) {
            Navigator.pop(context);
            showErrorDialog(context, 'حدث خطأ أثناء الحفظ');
          } else if (state is AuthSuccessState) {
            Navigator.pop(context); // dismiss loading dialog

            WidgetsBinding.instance.addPostFrameCallback((_) {
              pushAndRemoveUntil(
                context,
                const DoctorNavBar(page: 0),
              );
            });
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Form(
                key: _docRegistrationKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Gap(10),
                    // -------------------- الصورة الشخصية -------------------- //
                    GestureDetector(
                      onTap: () {
                        showPfpBottomSheet(context, (File imageFile) async {
                          setState(() => _isUploadingImage = true);

                          try {
                            final imageUrl =
                                await uploadToCloudinary(imageFile);

                            if (imageUrl != null) {
                              setState(() {
                                _avatarImageUrl = imageUrl;
                              });
                            } else {
                              if (!mounted) return;
                              showErrorDialog(context, 'فشل في رفع الصورة');
                            }
                          } catch (e) {
                            if (!mounted) return;
                            showErrorDialog(
                                context, 'حدث خطأ أثناء رفع الصورة');
                          } finally {
                            if (mounted) {
                              setState(() => _isUploadingImage = false);
                            }
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
                                    as ImageProvider,
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
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 20,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // -------------------- التخصص -------------------- //
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                      child: Row(
                        children: [
                          Text(
                            'التخصص',
                            style: getBodyStyle(
                              color: AppColors.black,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButton(
                        isExpanded: true,
                        iconEnabledColor: AppColors.color1,
                        icon: const Icon(Icons.expand_circle_down_outlined),
                        value: _specialisation,
                        onChanged: (String? newValue) {
                          setState(() {
                            _specialisation = newValue ?? specialisation[0];
                          });
                        },
                        items: specialisation.map((element) {
                          return DropdownMenuItem(
                            value: element,
                            child: Text(element),
                          );
                        }).toList(),
                      ),
                    ),
                    const Gap(10),

                    // -------------------- نبذة تعريفية -------------------- //
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Text(
                            'نبذة تعريفية',
                            style: getBodyStyle(
                              color: AppColors.black,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomTextFormField(
                      keyboardType: TextInputType.text,
                      hintText:
                          'سجل المعلومات الطبية العامة مثل تعليمك الأكاديمي وخبراتك السابقة...',
                      controller: _bioController,
                      maxLines: 5,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'من فضلك ادخل معلومات عنك';
                        }
                        return null;
                      },
                    ),

                    // -------------------- عنوان العيادة -------------------- //
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Divider(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Text(
                            'عنوان العيادة',
                            style: getBodyStyle(
                              color: AppColors.black,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomTextFormField(
                      hintText: '5 شارع مصدق - الدقي - الجيزة ',
                      controller: _addressController,
                      keyboardType: TextInputType.streetAddress,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'من فضلك ادخل عنوان العيادة';
                        }
                        return null;
                      },
                    ),
                    const Gap(10),

                    // -------------------- ساعات العمل -------------------- //
                    Row(
                      children: [
                        Text(
                          'ساعات العمل',
                          style: getBodyStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Text(
                                  'من',
                                  style: getBodyStyle(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Text(
                                  'الي',
                                  style: getBodyStyle(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Start Time
                        Expanded(
                          child: CustomTextFormField(
                            controller: _startTimeController,
                            onTap: showStartTimePicker,
                            readOnly: true,
                            hintText: '9:00 ص',
                            suffixIcon: const Icon(Icons.watch_later_outlined),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'من فضلك اختر وقت البدء';
                              }
                              return null;
                            },
                          ),
                        ),
                        const Gap(10),
                        // End Time
                        Expanded(
                          child: CustomTextFormField(
                            controller: _endTimeController,
                            onTap: showEndTimePicker,
                            readOnly: true,
                            hintText: '5:00 م',
                            suffixIcon: const Icon(Icons.watch_later_outlined),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'من فضلك اختر وقت الانتهاء';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                    // -------------------- ارقام الهاتف -------------------- //
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            'رقم الهاتف 1',
                            style: getBodyStyle(
                              color: AppColors.black,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomTextFormField(
                        hintText: '20xxxxxxxxxxx+',
                        controller: _phone1Controller,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                        ],
                        validator: validatePhone),
                    const Gap(10),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            'رقم الهاتف 2 (اختياري)',
                            style: getBodyStyle(
                              color: AppColors.black,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomTextFormField(
                        controller: _phone2Controller,
                        hintText: '20xxxxxxxxxxx+',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                        ],
                        keyboardType: TextInputType.phone,
                        validator: validatePhone),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationButton(
        text: 'التسجيل',
        onPressed: () {
          if (_docRegistrationKey.currentState!.validate()) {
            if (_avatarImageUrl.isEmpty) {
              showErrorDialog(context, 'يجب رفع صورة شخصية قبل التسجيل');
              return;
            }
            context.read<AuthBloc>().add(
                  DocRegistrationEvent(
                    context: context,
                    imageUrl: _avatarImageUrl,
                    specialisation: _specialisation,
                    startTime: _startTimeController.text,
                    endTime: _endTimeController.text,
                    address: _addressController.text,
                    phone1: _phone1Controller.text,
                    phone2: _phone2Controller.text,
                    bio: _bioController.text,
                  ),
                );
          }
        },
      ),
    );
  }

  showStartTimePicker() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _startTimePicked = picked;
        _startTimeController.text = picked.format(context);
      });
    }
  }

  showEndTimePicker() async {
    if (_startTimePicked == null) {
      showErrorDialog(context, 'من فضلك اختر وقت البدء أولاً');
      return;
    }
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        DateTime.now().add(const Duration(hours: 2)),
      ),
    );

    if (picked != null) {
      if (picked.hour < _startTimePicked!.hour ||
          picked.hour == _startTimePicked!.hour &&
              picked.minute == _startTimePicked!.minute) {
        if (!mounted) return;
        showErrorDialog(context, 'وقت الانتهاء يجب أن يكون بعد وقت البدء');
        return;
      }
      setState(() {
        _endTimePicked = picked;
        _endTimeController.text = picked.format(context);
      });
    }
  }
}
