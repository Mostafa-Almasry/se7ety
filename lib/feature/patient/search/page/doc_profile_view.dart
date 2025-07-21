import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:se7ety/core/constants/assets_manager.dart';
import 'package:se7ety/core/functions/navigation.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/core/widgets/bottom_navigation_button.dart';
import 'package:se7ety/feature/auth/data/model/doctor_model.dart';
import 'package:se7ety/feature/patient/booking/presentation/page/booking_view.dart';
import 'package:se7ety/feature/patient/search/widgets/info_tile_widget.dart';
import 'package:se7ety/feature/patient/search/widgets/phone_button_widget.dart';

class DocProfileView extends StatefulWidget {
  const DocProfileView({super.key, required this.doctor});
  final DoctorModel? doctor;

  @override
  State<DocProfileView> createState() => _DocProfileViewState();
}

class _DocProfileViewState extends State<DocProfileView> {
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
      body: Padding(
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
                  child: ClipOval(
                    child:
                        (widget.doctor?.image != null)
                            ? Hero(
                              tag: 'doctor-${widget.doctor?.uid}-image',
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
                          PhoneTile(number: 1, onTap: () {}),
                          if (widget.doctor?.phone2 != null &&
                              widget.doctor!.phone2!.isNotEmpty)
                            PhoneTile(number: 2, onTap: () {}),
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
                //--------------------- نبذة تعريفية --------------------- //
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
                            "${widget.doctor?.openHour} - ${widget.doctor?.closeHour}",
                      ),
                      const Gap(25),
                      TileWidget(
                        icon: Icons.location_on,
                        text: "${widget.doctor?.address}",
                      ),
                    ],
                  ),
                ),
                const Divider(),
                const Gap(25),

                //--------------------- معلومات الاتصال --------------------- //
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
                      TileWidget(
                        icon: Icons.phone,
                        text: "${widget.doctor?.phone1}",
                      ),
                      if (widget.doctor?.phone2 != null &&
                          widget.doctor!.phone2!.isNotEmpty) ...[
                        const Gap(25),
                        TileWidget(
                          icon: Icons.phone,
                          text: "${widget.doctor?.phone2}",
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
      bottomNavigationBar: BottomNavigationButton(
        text: "احجز موعد الان",
        onPressed: () {
          push(context, BookingView(doctor: widget.doctor));
        },
      ),
    );
  }
}
