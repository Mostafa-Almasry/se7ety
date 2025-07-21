import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:se7ety/core/widgets/custom_text_form_field.dart';
import 'package:se7ety/feature/patient/search/widgets/search_list.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key, required this.searchKey});
  final String searchKey;

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late TextEditingController _controller;
  String search = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchKey);
    search = widget.searchKey;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ابحث عن دكتور')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
        child: Column(
          children: [
            CustomTextFormField(
              controller: _controller,
              isSearch: true,
              hintText: 'البحث',
              suffixIcon: const Icon(Icons.search),
              onChanged: (searchKey) {
                setState(() {
                  search = searchKey;
                });
              },
            ),
            const Gap(15),
            Expanded(
              child: SearchList(
                searchKey: search,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
