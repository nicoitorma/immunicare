import 'package:flutter/material.dart';
import 'package:immunicare/constants/constants.dart';

class SearchField extends StatelessWidget {
  const SearchField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search for Statistics",
        helperStyle:
            TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 15),
        fillColor: secondaryColor,
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon:
            Icon(Icons.search, color: textColor.withValues(alpha: (0.5))),
      ),
    );
  }
}
