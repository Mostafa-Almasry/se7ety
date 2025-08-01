import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:se7ety/core/constants/assets_manager.dart';
import 'package:se7ety/core/functions/navigation.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/feature/patient/home/data/card.dart';
import 'package:se7ety/feature/patient/home/presentation/page/specialisation_search_view.dart';

// Row(children: [Text('التخصصات', style: getTitleStyle())]),
// const Gap(10),
class SpecialisationBanner extends StatelessWidget {
  const SpecialisationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('التخصصات', style: getTitleStyle()),
        const Gap(10),
        SizedBox(
          height: 230,
          width: double.infinity,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  push(
                      context,
                      SpecialisationSearchView(
                          selectedSpecilisation: cards[index].specialisation));
                },
                child: ItemCardWidget(
                  cardBgColor: cards[index].cardBgColor,
                  lightColor: cards[index].cardLightColor,
                  title: cards[index].specialisation,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ItemCardWidget extends StatelessWidget {
  const ItemCardWidget({
    super.key,
    required this.lightColor,
    required this.title,
    required this.cardBgColor,
  });

  final Color cardBgColor;
  final Color lightColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 150,
      margin: const EdgeInsets.only(left: 15, bottom: 15, top: 10),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            offset: const Offset(4, 4),
            blurRadius: 10,
            color: lightColor.withOpacity(.4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: -25,
              right: -25,
              child: CircleAvatar(radius: 60, backgroundColor: lightColor),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SvgPicture.asset(AssetsManager.doctorCard, width: 140),
                const Gap(15),
                Text(
                  title,
                  style: getSmallStyle(color: AppColors.white),
                ),
                const Gap(20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
