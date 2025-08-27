import 'package:flutter/material.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/constants/responsive.dart';
import 'package:immunicare/controllers/controller.dart';
import 'package:immunicare/screens/components/dashboard/profile_info.dart';
import 'package:immunicare/screens/components/dashboard/search_field.dart';
import 'package:provider/provider.dart';

class CustomAppbar extends StatelessWidget {
  const CustomAppbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            onPressed: context.read<Controller>().controlMenu,
            icon: Icon(Icons.menu, color: textColor.withValues(alpha: 0.5)),
          ),
        Expanded(child: SearchField()),
        ProfileInfo(),
      ],
    );
  }
}
