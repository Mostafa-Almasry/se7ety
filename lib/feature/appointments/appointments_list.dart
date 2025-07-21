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

  // Check if the appointment isn't pending (expired)
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
              Navigator.pop(context);
            },
            child: Text('نعم', style: getBodyStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text('لم يتم تسجيل الدخول'));
    }
    String? uid = AppLocalStorage.getData(key: AppLocalStorage.uid);
    if (uid == null || uid.isEmpty) {
      // Show a loading indicator first, then error if still null after a short delay
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

    final Stream<QuerySnapshot> appointmentsStream;
    if (widget.userType == UserType.patient) {
      appointmentsStream = FirebaseFirestore.instance
          .collection('appointments')
          .where('patientID', isEqualTo: uid)
          .orderBy('date', descending: false)
          .snapshots();
    } else {
      appointmentsStream = FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorID', isEqualTo: uid)
          .orderBy('date', descending: false)
          .snapshots();
    }

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
          if (!snapshot.hasData) {
            return const Center(child: Text('لا يوجد بيانات'));
          }
          final docs = snapshot.data!.docs;

          final filteredDocs = widget.showPastAppointments
              ? docs.toList()
              : docs.where((doc) {
                  final dateTime = (doc['date'] as Timestamp).toDate();
                  return !isExpired(dateTime);
                }).toList();

          // Sort (really cool method!)
          filteredDocs.sort((a, b) {
            // Convert to dart date
            final aDate = (a['date'] as Timestamp).toDate();
            final bDate = (b['date'] as Timestamp).toDate();
            // Check each one for expiration
            final aExpired = isExpired(aDate);
            final bExpired = isExpired(bDate);
            // If they're both expired or if they both aren't
            if (aExpired == bExpired) {
              return aDate.compareTo(bDate); // earlier first
            }
            // If one is expired and thye other isn't:
            // if a is the one that's expired make it 1 in order, if not, the opposite
            return aExpired ? 1 : -1; // expired go after upcoming
          });

          if (filteredDocs.isEmpty) {
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
          return ListView.builder(
            shrinkWrap: true,
            physics: widget.scrollable
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: filteredDocs.length,
            itemBuilder: (BuildContext context, int index) {
              final doc = filteredDocs[index];
              final dateTime = (doc['date'] as Timestamp).toDate();
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
                    title: widget.userType == UserType.patient
                        ? Text('د. ${doc['doctor']}', style: getTitleStyle())
                        : Text('data', style: getTitleStyle()),
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
                                          doc['location'] ?? 'لا يوجد عنوان',
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
                                          doc['description'] ?? 'لا يوجد وصف',
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
                              onPressed: () {
                                confirmDelete(doc.id);
                              },
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
