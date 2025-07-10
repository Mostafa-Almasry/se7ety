import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/core/widgets/doctor_card.dart';
import 'package:se7ety/feature/auth/data/model/doctor_model.dart';

class TopRatedWidget extends StatefulWidget {
  const TopRatedWidget({super.key});

  @override
  State<TopRatedWidget> createState() => _TopRatedWidgetState();
}

class _TopRatedWidgetState extends State<TopRatedWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الأعلي تقييماََ', style: getTitleStyle()),
          const Gap(10),

          FutureBuilder(
            future:
                FirebaseFirestore.instance
                    .collection('doctors')
                    .orderBy('rating', descending: true)
                    .get(),
            // initialData: InitialData,
            builder: (
              BuildContext context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text('حدث خطأ اثناء تحميل قائمة الأعلي تقييما'),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('لا يوجد أطباء لعرضهم حالياً'));
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                physics:
                    const NeverScrollableScrollPhysics(), // Don't allow scrolling for this widge cz i don't want nested scrolling
                shrinkWrap: true, // Only take needed space
                itemBuilder: (BuildContext context, int index) {
                  try {
                    final doctor = DoctorModel.fromJson(
                      snapshot.data!.docs[index].data(),
                    );
                    print('✅ Loaded doctor: ${doctor.name}');
                    print('🖼️ doctor.image = ${doctor.image}');

                    return DoctorCard(doctor: doctor);
                  } catch (e) {
                    print('❌ Error parsing doctor at index $index: $e');
                    return const SizedBox();
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
