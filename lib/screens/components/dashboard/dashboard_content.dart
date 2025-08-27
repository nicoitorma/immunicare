import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/constants/responsive.dart';
import 'package:immunicare/screens/components/dashboard/analytic_cards.dart';
import 'package:immunicare/screens/components/dashboard/custom_appbar.dart';
import 'package:immunicare/screens/components/dashboard/users.dart';
import 'package:immunicare/screens/components/dashboard/users_by_device.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(appPadding),
        child: Column(
          children: [
            CustomAppbar(),
            SizedBox(height: appPadding),
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          AnalyticCards(),
                          SizedBox(height: appPadding),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: Users()),
                              if (!Responsive.isMobile(context))
                                SizedBox(width: appPadding),
                              if (!Responsive.isMobile(context))
                                Expanded(child: UsersByDevice()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (Responsive.isMobile(context)) UsersByDevice(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
