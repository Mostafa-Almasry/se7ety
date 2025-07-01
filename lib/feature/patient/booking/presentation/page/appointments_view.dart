import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:se7ety/core/constants/assets_manager.dart';
import 'package:se7ety/core/services/local_storage.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/core/widgets/custom_text_form_field.dart';
import 'package:se7ety/feature/auth/data/models/doctor_model.dart';

class AppointmentsView extends StatefulWidget {
  const AppointmentsView({super.key, required this.doctor});
  final DoctorModel? doctor;
  @override
  State<AppointmentsView> createState() => _AppointmentsViewState();
}

class _AppointmentsViewState extends State<AppointmentsView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  @override
  void initState() {
    super.initState();

    final savedName = AppLocalStorage.getData(key: AppLocalStorage.userName);
    if (savedName != null && savedName.isNotEmpty) {
      _nameController.text = savedName;
    } else {
      // For users that have been registered without their names being cached
      final uid = AppLocalStorage.getData(key: AppLocalStorage.userToken);
      if (uid != null) {
        FirebaseFirestore.instance.collection('patients').doc(uid).get().then((
          doc,
        ) {
          final fetchedName = doc.data()?['name'];
          if (fetchedName != null) {
            _nameController.text = fetchedName;
            AppLocalStorage.cacheData(
              key: AppLocalStorage.userName,
              value: fetchedName,
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: EdgeInsets.only(right: 10),
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('احجز مع دكتورك'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15), // Standardise
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.accentColor,
                    ),
                    child: Row(
                      children: [
                        //--------------------- Profile Picture ---------------------
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 55,
                                backgroundColor: AppColors.white,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: AppColors.white,
                                  child: ClipOval(
                                    child:
                                        (widget.doctor?.image != null)
                                            ? Hero(
                                              tag:
                                                  'doctor-${widget.doctor?.uid}-image',
                                              child: Image.network(
                                                widget.doctor!.image!,
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                            : SvgPicture.asset(
                                              AssetsManager.doctor,
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 30),

                        //--------------------- Quick Overview ---------------------
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                ' د. ${widget.doctor?.name ?? ''}',
                                style: getTitleStyle(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Gap(3),
                              Text(
                                widget.doctor?.specialisation ?? '',
                                style: getBodyStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const Gap(10),
                              Row(
                                children: [
                                  Text(widget.doctor?.rating.toString() ?? '0'),
                                  const SizedBox(width: 3),
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                ],
                              ),
                              const Gap(25),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    bottom: -13,
                    left: -10,
                    child: Icon(
                      Icons.watch_later_outlined,
                      color: AppColors.white,
                      size: 60,
                    ),
                  ),
                ],
              ),
              const Gap(20),
              Text('-- ادخل بيانات الحجز --', style: getTitleStyle()),
              const Gap(5),
              // -------------------- اسم المريض -------------------- //
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Text(
                      'اسم المريض',
                      style: getBodyStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

              // -------------------- اسم المريض -------------------- //
              CustomTextFormField(
                hintText: 'ادخل اسمك',
                controller: _nameController,
                keyboardType: TextInputType.streetAddress,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'من فضلك ادخل اسمك';
                  }
                  return null;
                },
              ),
              // -------------------- رقم الهاتف -------------------- //
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      'رقم الهاتف',
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
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'يجب ادخال رقم الهاتف للتواصل';
                  }
                  return null;
                },
              ),
              const Gap(10),

              // -------------------- وصف الحالة -------------------- //
              Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Text(
                      'وصف الحالة',
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
                    'اذكر ما تشعر به بشكل مختصر، مثل الألم أو الأعراض التي تعاني منها',
                // controller: ,
                maxLines: 5,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'من فضلك ادخل معلومات عنك';
                  }
                  return null;
                },
              ),
              const Gap(10),
              // -------------------- وصف الحالة -------------------- //
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Text(
                      'تاريخ الحجز',
                      style: getBodyStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
