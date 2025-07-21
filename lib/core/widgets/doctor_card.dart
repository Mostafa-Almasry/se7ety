import 'package:flutter/material.dart';
import 'package:se7ety/core/constants/assets_manager.dart';
import 'package:se7ety/core/functions/navigation.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/feature/auth/data/model/doctor_model.dart';
import 'package:se7ety/feature/patient/search/page/doc_profile_view.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({super.key, required this.doctor});

  final DoctorModel doctor;
  String? fixedImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;

    final trimmed = url.trim();
    if (trimmed.contains('cloudinary.com') && trimmed.contains('/upload/')) {
      return trimmed.replaceFirst('/upload/', '/upload/f_auto,q_auto/');
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 0),
      margin: const EdgeInsets.only(top: 10),
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(-3, 10),
            blurRadius: 15,
            color: AppColors.grey.withOpacity(.2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          FocusScope.of(context).unfocus();
          await Future.delayed(const Duration(milliseconds: 150));
          push(context, DocProfileView(doctor: doctor));
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(13)),
              child: Container(
                height: 55,
                width: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: AppColors.white,
                ),
                child: Hero(
                  tag: 'doctor-${doctor.uid}-image',
                  child: Image.network(
                    fixedImageUrl(doctor.image ?? '') ??
                        AssetsManager.doctorCard,
                    height: 50,
                    width: 50,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    doctor.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getTitleStyle(fontSize: 16),
                  ),
                  Text(doctor.specialisation ?? '', style: getBodyStyle()),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(doctor.rating.toString(), style: getBodyStyle()),
                const SizedBox(width: 3),
                const Icon(Icons.star_rate_rounded, size: 20, color: Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
