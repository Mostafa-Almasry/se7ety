import 'package:flutter/material.dart';
import 'package:se7ety/feature/patient/search/widgets/search_list.dart';

class SpecialisationSearchView extends StatefulWidget {
  const SpecialisationSearchView(
      {super.key, required this.selectedSpecilisation});
  final String selectedSpecilisation;

  @override
  State<SpecialisationSearchView> createState() =>
      _SpecialisationSearchViewState();
}

class _SpecialisationSearchViewState extends State<SpecialisationSearchView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.selectedSpecilisation)),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
        child: Column(
          children: [
            Expanded(
              child: SearchList(
                searchKey: '',
                where: widget.selectedSpecilisation,
                isSpecialisationSearch: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
