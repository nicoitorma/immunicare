import 'package:flutter/material.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/constants/responsive.dart';
import 'package:immunicare/screens/components/dashboard/profile_info.dart';
import 'package:immunicare/screens/components/dashboard/search_field.dart';

class CustomAppbar extends StatelessWidget {
  const CustomAppbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            onPressed:
                Scaffold.hasDrawer(context)
                    ? () {
                      Scaffold.of(context).openDrawer();
                    }
                    : null,
            icon: Icon(Icons.menu, color: textColor.withValues(alpha: 0.5)),
          ),
        // if (ModalRoute.of(context)!.settings.name == '/scheduled')
        //   Expanded(child: SearchField()),
        if (ModalRoute.of(context)!.settings.name == '/registered_children')
          Expanded(child: SearchField()),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [ProfileInfo()],
        ),
      ],
    );
  }
}
