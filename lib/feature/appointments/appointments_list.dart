import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:se7ety/core/constants/assets_manager.dart';
import 'package:se7ety/core/enum/user_type_enum.dart';
import 'package:se7ety/core/services/local_storage.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/core/widgets/custom_button.dart';

class AppointmentsList extends StatefulWidget {
  const AppointmentsList({
    super.key,
    this.padding,
    this.showPastAppointments = false,
    this.scrollable = true,
    required this.userType,
  });

  final EdgeInsetsGeometry? padding;
  final bool showPastAppointments;
  final bool scrollable;
  final UserType userType;
  @override
  State<AppointmentsList> createState() => _AppointmentsListState();
}

class _AppointmentsListState extends State<AppointmentsList> {
  final user = FirebaseAuth.instance.currentUser;
  String formatDate(DateTime date) => DateFormat("dd-MM-yyyy").format(date);
  String formatTime(DateTime date) {
    // Formatting as 12-hour, English numbers, Arabic AM/PM
    final formatted = DateFormat('h:mm a', 'en').format(date);
    return formatted.replaceAll('AM', 'ص').replaceAll('PM', 'م');
  }

  // Check if the appointment isn't expired
  bool isExpired(DateTime date) {
    final now = DateTime.now();
    return now.difference(date).inHours > 2;
  }

  // Check if it's today to highlight to user
  bool isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  Future<void> deleteAppointment(String id) {
    return FirebaseFirestore.instance
        .collection('appointments')
        .doc(id)
        .delete();
  }

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('حذف الحجز'),
        content: const Text('هل متأكد أنك تريد حذف الحجز؟'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: AppColors.color1,
            ),
            onPressed: () => Navigator.pop(context),
            child: Text('لا', style: getBodyStyle(color: AppColors.white)),
          ),
          TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: AppColors.redColor,
            ),
            onPressed: () async {
              await deleteAppointment(id);
              if (mounted) Navigator.pop(context);
            },
            child: Text('نعم', style: getBodyStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  // NEW: Safe document field access
  String _getField(DocumentSnapshot doc, String field, [String fallback = '']) {
    return (doc[field]?.toString() ?? fallback).trim();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text('لم يتم تسجيل الدخول'));
    }

    String? uid = AppLocalStorage.getData(key: AppLocalStorage.uid);
    if (uid == null || uid.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('مواعيد الحجز')),
        body: FutureBuilder(
          future: Future.delayed(const Duration(milliseconds: 300)),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: Text(
                'حدث خطأ في بيانات المستخدم',
                style: getBodyStyle().copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      );
    }

    final Stream<QuerySnapshot> appointmentsStream = FirebaseFirestore.instance
        .collection('appointments')
        .where(
          widget.userType == UserType.patient ? 'patientID' : 'doctorID',
          isEqualTo: uid,
        )
        .orderBy('date', descending: false)
        .snapshots();

    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        stream: appointmentsStream,
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ أثناء تحميل البيانات'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(AssetsManager.noScheduled, width: 200),
                  const Gap(10),
                  Text('لا يوجد حجوزات', style: getBodyStyle()),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          // NEW: Safe filtering and sorting
          final filteredDocs = docs.where((doc) {
            final dateField = doc['date'];
            if (dateField == null) return false;

            try {
              final dateTime = (dateField as Timestamp).toDate();
              return widget.showPastAppointments || !isExpired(dateTime);
            } catch (e) {
              return false;
            }
          }).toList();

          // Sort with null safety
          filteredDocs.sort((a, b) {
            final aDate = (a['date'] as Timestamp?)?.toDate();
            final bDate = (b['date'] as Timestamp?)?.toDate();

            if (aDate == null || bDate == null) return 0;

            final aExpired = isExpired(aDate);
            final bExpired = isExpired(bDate);

            if (aExpired == bExpired) return aDate.compareTo(bDate);
            return aExpired ? 1 : -1;
          });

          return ListView.builder(
            shrinkWrap: true,
            physics: widget.scrollable
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: filteredDocs.length,
            itemBuilder: (BuildContext context, int index) {
              final doc = filteredDocs[index];
              final dateField = doc['date'];
              DateTime? dateTime;

              // NEW: Safe date handling
              if (dateField is Timestamp) {
                dateTime = dateField.toDate();
              }

              // Skip invalid documents
              if (dateTime == null) return const SizedBox.shrink();

              return Padding(
                padding:
                    widget.padding ?? const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: AppColors.accentColor,
                  child: ExpansionTile(
                    shape: const RoundedRectangleBorder(side: BorderSide.none),
                    // NEW: Use safe field access
                    title: widget.userType == UserType.patient
                        ? Text('د. ${_getField(doc, 'doctor', 'غير معروف')}',
                            style: getTitleStyle())
                        : Text(_getField(doc, 'name', 'غير معروف'),
                            style: getTitleStyle()),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Gap(10),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: AppColors.color1,
                            ),
                            const SizedBox(width: 5),
                            Text(formatDate(dateTime), style: getBodyStyle()),
                            if (isToday(dateTime)) ...[
                              const SizedBox(width: 8),
                              Text(
                                'اليوم',
                                style: getBodyStyle().copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ] else if (isExpired(dateTime)) ...[
                              const SizedBox(width: 8),
                              Text(
                                'انتهي',
                                style: getBodyStyle().copyWith(
                                  color: AppColors.redColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const Gap(8),
                        Row(
                          children: [
                            const Icon(
                              Icons.watch_later_outlined,
                              size: 20,
                              color: AppColors.color1,
                            ),
                            const SizedBox(width: 5),
                            Text(formatTime(dateTime), style: getBodyStyle()),
                          ],
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        child: Column(
                          children: [
                            widget.userType == UserType.patient
                                ? Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        color: AppColors.color1,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          // NEW: Safe field access
                                          _getField(
                                              doc, 'location', 'لا يوجد عنوان'),
                                          style: getBodyStyle(),
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      const Icon(
                                        Icons.description_outlined,
                                        color: AppColors.color1,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          // NEW: Safe field access
                                          _getField(doc, 'description',
                                              'لا يوجد وصف'),
                                          style: getBodyStyle(),
                                        ),
                                      ),
                                    ],
                                  ),
                            const Gap(10),
                            CustomButton(
                              text:
                                  !isExpired(dateTime) ? 'الغاء الحجز' : 'حذف',
                              color: AppColors.redColor,
                              onPressed: () => confirmDelete(doc.id),
                            ),
                            const Gap(8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
