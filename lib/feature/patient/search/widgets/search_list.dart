import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se7ety/core/constants/assets_manager.dart';
import 'package:se7ety/core/utils/text_styles.dart';
import 'package:se7ety/core/widgets/doctor_card.dart';
import 'package:se7ety/feature/auth/data/models/doctor_model.dart';

class SearchList extends StatefulWidget {
  const SearchList({super.key, required this.searchKey});
  final String searchKey;

  @override
  State<SearchList> createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  @override
  Widget build(BuildContext context) {
    final searchKeyLower = widget.searchKey.toLowerCase();

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('doctors')
              .orderBy('name')
              .startAt([searchKeyLower])
              .endAt(['$searchKeyLower\uf8ff'])
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final doctors = snapshot.data!.docs;

        if (doctors.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(AssetsManager.noSearch, width: 250),
                  Text('لا يوجد دكتور بهذا الاسم', style: getBodyStyle()),
                ],
              ),
            ),
          );
        }

        return Scrollbar(
          child: ListView.builder(
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = DoctorModel.fromJson(
                doctors[index].data() as Map<String, dynamic>,
              );
              return DoctorCard(doctor: doctor);
            },
          ),
        );
      },
    );
  }
}
