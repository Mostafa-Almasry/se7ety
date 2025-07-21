import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:se7ety/core/functions/navigation.dart';
import 'package:se7ety/core/services/local_storage.dart';
import 'package:se7ety/core/utils/app_colors.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/core/widgets/custom_text_form_field.dart';
import 'package:se7ety/feature/patient/home/presentation/widgets/specialisation_banner.dart';
import 'package:se7ety/feature/patient/home/presentation/widgets/top_rated_widget.dart';
import 'package:se7ety/feature/patient/search/page/search_view.dart';

class PatientHomeView extends StatefulWidget {
  const PatientHomeView({super.key});

  @override
  State<PatientHomeView> createState() => _PatientHomeViewState();
}

class _PatientHomeViewState extends State<PatientHomeView> {
  final TextEditingController _searchController = TextEditingController();

  final userName =
      AppLocalStorage.getData(key: AppLocalStorage.userName) as String?;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_active_rounded,
              color: AppColors.titleColor,
            ),
          ),
        ],
        title: Text(
          'صــحّتـي',
          style: getTitleStyle(fontSize: 22, color: AppColors.titleColor),
        ),
        backgroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text.rich(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'مرحبا، ',
                        style: getBodyStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      TextSpan(
                        text: userName ?? '',
                        style: getBodyStyle(
                          color: AppColors.color1,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Gap(10),
              Text(
                'احجز الآن وكن جزءاََ من رحلتك الصحية',
                style: getTitleStyle(color: AppColors.titleColor, fontSize: 24),
              ),
              const Gap(20),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(5, 5),
                    ),
                  ],
                ),
                child: CustomTextFormField(
                  controller: _searchController,
                  hintText: 'ابحث عن دكتور',
                  suffixIconButton: Container(
                    decoration: BoxDecoration(
                      color: AppColors.color1,
                      border: Border.all(color: AppColors.color1, width: 1.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      onPressed: () {
                        push(
                          context,
                          SearchView(searchKey: _searchController.text),
                        );
                      },
                      icon: const Icon(Icons.search, color: AppColors.white),
                    ),
                  ),
                ),
              ),
              const Gap(30),

              // --------------------  التخصصات -------------------- //
              const SpecialisationBanner(),
              const Gap(10),
              // --------------------  الأعلي تقييماََ -------------------- //
              const TopRatedWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
