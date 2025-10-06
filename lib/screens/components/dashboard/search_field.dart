import 'package:flutter/material.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/controllers/child_viewmodel.dart';
import 'package:provider/provider.dart';

class SearchField extends StatefulWidget {
  const SearchField({Key? key}) : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final viewModel = Provider.of<ChildViewModel>(context, listen: false);
    viewModel.searchParent(_searchController.text.trim());
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: "Search...",
        helperStyle: TextStyle(color: textColor.withAlpha(55), fontSize: 15),
        fillColor: secondaryColor,
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Icon(Icons.search, color: textColor.withAlpha(50)),
      ),
    );
  }
}
