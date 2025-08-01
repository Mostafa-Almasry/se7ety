import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:se7ety/core/constants/assets_manager.dart';
import 'package:se7ety/core/functions/dialogs.dart';
import 'package:se7ety/core/functions/navigation.dart';
import 'package:se7ety/core/services/local_storage.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/core/widgets/alert_dialog.dart';
import 'package:se7ety/core/widgets/bottom_navigation_button.dart';
import 'package:se7ety/core/widgets/custom_text_form_field.dart';
import 'package:se7ety/feature/auth/data/model/doctor_model.dart';
import 'package:se7ety/feature/patient/booking/data/available_appointments.dart';
import 'package:se7ety/feature/patient/patient_nav_bar.dart';

class BookingView extends StatefulWidget {
  const BookingView({super.key, required this.doctor});
  final DoctorModel doctor;
  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  final GlobalKey<FormState> _bookingKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  TimeOfDay selectedDate = TimeOfDay.now();
  DateTime? selectedDay;
  int selectedIndex = -1;
  int? bookedHour;
  List<int> times = [];

  void getAvailableTimes(DateTime selectedDate) {
    final newTimes = getAvailableAppointments(
      selectedDate,
      widget.doctor.openHour,
      widget.doctor.closeHour,
    );
    setState(() {
      times = newTimes;
    });
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    getAvailableTimes(now);

    _phoneController.text =
        AppLocalStorage.getData(key: AppLocalStorage.userPhone) ?? '';

    _dateController.text = "";

    final savedName =
        AppLocalStorage.getData(key: AppLocalStorage.userName) as String?;
    if (savedName != null && savedName.isNotEmpty) {
      _nameController.text = savedName;
    } else {
      // For users that have been registered without their names being cached
      final uid = AppLocalStorage.getData(key: AppLocalStorage.uid);
      if (uid != null) {
        FirebaseFirestore.instance
            .collection('patients')
            .doc(uid)
            .get()
            .then((doc) {
          final fetchedName = doc.data()?['name'] ?? ''; // Handle null
          if (fetchedName.isNotEmpty) {
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
          padding: const EdgeInsets.only(right: 10),
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('احجز مع دكتورك'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15), // Standardise
          child: Form(
            key: _bookingKey,
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
                                      child: (widget.doctor.image.isNotEmpty)
                                          ? Hero(
                                              tag:
                                                  'doctor-${widget.doctor.uid}-image',
                                              child: Image.network(
                                                widget.doctor.image,
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
                          const SizedBox(width: 30),

                          //--------------------- Quick Overview ---------------------
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  ' د. ${widget.doctor.name}',
                                  style: getTitleStyle(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Gap(3),
                                Text(
                                  widget.doctor.specialisation,
                                  style: getBodyStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                const Gap(10),
                                Row(
                                  children: [
                                    Text(
                                      widget.doctor.rating.toString() 
                                    ),
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
                const Gap(
                    10), // -------------------- رقم الهاتف -------------------- //
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
                    } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                      return 'رقم الهاتف يجب أن يحتوي على أرقام فقط';
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
                  controller: _descriptionController,
                  maxLines: 5,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'من فضلك ادخل معلومات عن حالتك';
                    }
                    return null;
                  },
                ),
                const Gap(10),

                // -------------------- تاريخ الحجز -------------------- //
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
                CustomTextFormField(
                  hintText: 'اختر تاريخ الحجز',
                  controller: _dateController,
                  suffixIcon: const Icon(
                    Icons.date_range_outlined,
                    color: AppColors.white,
                  ),
                  suffixIconHasBg: true,
                  readOnly: true,
                  onTap: datePicker,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'يجب ادخال تاريخ  الحجز';
                    }
                    return null;
                  },
                ),
                const Gap(10),

                // -------------------- وقت الحجز -------------------- //
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Text(
                        'وقت الحجز',
                        style: getBodyStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: times.map((hour) {
                    return ChoiceChip(
                      label: Text(
                        "${hour.toString().padLeft(2, '0')}:00",
                        style: TextStyle(
                          color: hour == selectedIndex
                              ? AppColors.white
                              : AppColors.black,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(
                          color: Colors.transparent,
                          width: 2,
                        ),
                      ),
                      backgroundColor: AppColors.accentColor,
                      selectedColor: AppColors.color1,
                      selected: hour == selectedIndex,
                      onSelected: (selected) {
                        setState(() {
                          selectedIndex = hour;
                          bookedHour = hour;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationButton(
        text: 'تأكيد الحجز',
        onPressed: () {
          if (_bookingKey.currentState!.validate()) {
            if (selectedIndex == -1) {
              showErrorDialog(context, 'من فضلك اختر وقت الحجز');
              return;
            } else {
              createAppointment();
              showDialog(
                context: context,
                builder: (context) => CustomAlertDialog(
                  title: 'تم تسجيل الحجز',
                  ok: 'اضغط للانتقال',
                  onPressed: () {
                    pushAndRemoveUntil(
                        context,
                        const PatientNavBar(
                          page: 0,
                        ));
                  },
                ),
              );
            }
          }
        },
      ),
    );
  }

  datePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(
        DateTime.now().year,
        DateTime.now().month + 2,
        DateTime.now().day,
      ),
    );
    if (picked != null) {
      setState(() {
        selectedDay = picked;
        _dateController.text = "${picked.year}-${picked.month}-${picked.day}";
        getAvailableTimes(picked);
      });
    }
  }

  Future<void> createAppointment() async {
    if (selectedDay == null || bookedHour == null) {
      throw Exception('Missing appointment time');
    }

    final patientId = await AppLocalStorage.getData(key: AppLocalStorage.uid);
    if (patientId == null) {
      throw Exception('Patient not logged in');
    }

    final fullDateTime = DateTime(
      selectedDay!.year,
      selectedDay!.month,
      selectedDay!.day,
      bookedHour!,
      0,
    );
    await FirebaseFirestore.instance.collection('appointments').add({
      'patientID': patientId,
      'doctorID': widget.doctor.uid,
      'name': _nameController.text,
      'phone': _phoneController.text,
      'description': _descriptionController.text,
      'doctor': widget.doctor.name ?? '',
      'location': widget.doctor.address ?? '',
      'date': fullDateTime,
      'status': 'pending',
      'rating': null,
    });
  }
}
