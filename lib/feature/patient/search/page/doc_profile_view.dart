import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:se7ety/core/constants/assets_manager.dart';
import 'package:se7ety/core/functions/navigation.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/core/widgets/bottom_navigation_button.dart';
import 'package:se7ety/feature/auth/data/model/doctor_model.dart';
import 'package:se7ety/feature/patient/booking/presentation/page/booking_view.dart';
import 'package:se7ety/feature/patient/search/widgets/info_tile_widget.dart';
import 'package:se7ety/feature/patient/search/widgets/phone_button_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class DocProfileView extends StatefulWidget {
  const DocProfileView({super.key, required this.doctor});
  final DoctorModel? doctor;

  @override
  State<DocProfileView> createState() => _DocProfileViewState();
}

class _DocProfileViewState extends State<DocProfileView> {
  bool get hasImage =>
      widget.doctor?.image != null && widget.doctor!.image.trim().isNotEmpty;

  Future<void> _handlePhoneTap(String phoneNumber) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // For Android, check if we have phone permission
    if (Platform.isAndroid) {
      final status = await Permission.phone.request();
      if (!status.isGranted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('تم رفض إذن الاتصال')),
        );
        return;
      }
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خيارات الاتصال'),
        content: Text('اختر الإجراء لرقم: $phoneNumber'),
        actions: [
          // Call option
          TextButton(
            child: const Text('اتصال'),
            onPressed: () async {
              navigator.pop();
              try {
                final url = Uri.parse('tel:$phoneNumber');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  await Clipboard.setData(ClipboardData(text: phoneNumber));
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: const Text('لا يوجد تطبيق اتصال، تم نسخ الرقم'),
                      action: SnackBarAction(
                        label: 'إعادة المحاولة',
                        onPressed: () => _handlePhoneTap(phoneNumber),
                      ),
                    ),
                  );
                }
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('خطأ: ${e.toString()}')),
                );
              }
            },
          ),

          // Copy option
          TextButton(
            child: const Text('نسخ'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: phoneNumber));
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text('تم النسخ: $phoneNumber')),
              );
              navigator.pop();
            },
          ),

          // Cancel
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => navigator.pop(),
          ),
        ],
      ),
    );
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
        title: const Text('بيانات الدكتور'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // --------------------- Header --------------------- //
              Row(
                children: [
                  //--------------------- Profile Picture ---------------------
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.white,
                    child: Hero(
                      tag: 'doctor-${widget.doctor?.uid}-image',
                      child: ClipOval(
                        child: hasImage
                            ? Image.network(
                                widget.doctor!.image,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                  AssetsManager.doctor,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                AssetsManager.doctor,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                      ),
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
                          ' د. ${widget.doctor?.name ?? ''}',
                          style: getTitleStyle(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(3),
                        Text(
                          widget.doctor?.specialisation ?? '',
                          style: getBodyStyle(fontWeight: FontWeight.normal),
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
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  _handlePhoneTap(widget.doctor?.phone1 ?? ''),
                              child: const PhoneTile(
                                number: 1,
                              ),
                            ),
                            if (widget.doctor?.phone2 != null &&
                                widget.doctor!.phone2.isNotEmpty)
                              GestureDetector(
                                onTap: () => _handlePhoneTap(
                                    widget.doctor?.phone2 ?? ''),
                                child: const PhoneTile(
                                  number: 2,
                                ),
                              )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(25),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //--------------------- نبذة تعريفية ---------------------
                  Text('نبذة تعريفية', style: getBodyStyle()),
                  const Gap(10),
                  Text(
                    widget.doctor?.bio ??
                        'دكتور ${widget.doctor?.specialisation}',
                    maxLines: 3,
                    overflow: TextOverflow.fade,
                  ),
                  const Gap(25),

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
                        TileWidget(
                          icon: Icons.watch_later_outlined,
                          text:
                              "${widget.doctor?.openHour ?? '?'} - ${widget.doctor?.closeHour ?? '?'}",
                        ),
                        const Gap(25),
                        TileWidget(
                          icon: Icons.location_on,
                          text: widget.doctor?.address ?? '',
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  const Gap(25),

                  //--------------------- معلومات الاتصال ---------------------
                  Text('معلومات الاتصال', style: getBodyStyle()),
                  const Gap(20),
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
                        TileWidget(
                          icon: Icons.email,
                          text: widget.doctor?.email ?? '',
                        ),
                        const Gap(25),
                        GestureDetector(
                          onTap: () =>
                              _handlePhoneTap(widget.doctor?.phone1 ?? ''),
                          child: TileWidget(
                            icon: Icons.phone,
                            text: widget.doctor?.phone1 ?? '',
                            showActionIcon: true,
                          ),
                        ),
                        if (widget.doctor?.phone2 != null &&
                            widget.doctor!.phone2.isNotEmpty) ...[
                          const Gap(25),
                          GestureDetector(
                            onTap: () =>
                                _handlePhoneTap(widget.doctor?.phone2 ?? ''),
                            child: TileWidget(
                              icon: Icons.phone,
                              text: widget.doctor!.phone2,
                              showActionIcon: true,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationButton(
        text: "احجز موعد الان",
        onPressed: () {
          push(context, BookingView(doctor: widget.doctor!));
        },
      ),
    );
  }
}
