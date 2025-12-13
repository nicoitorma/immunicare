import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/constants/responsive.dart';
import 'package:immunicare/controllers/auth_viewmodel.dart';
import 'package:immunicare/controllers/child_viewmodel.dart';
import 'package:immunicare/models/analytic_info_model.dart';
import 'package:immunicare/models/user_model.dart';
import 'package:immunicare/screens/components/dashboard/analytic_cards.dart';
import 'package:immunicare/screens/components/dashboard/analytic_info_card.dart';
import 'package:immunicare/screens/components/dashboard/custom_appbar.dart';
import 'package:immunicare/screens/components/dashboard/drawer_menu.dart';
import 'package:immunicare/screens/parent/components/dashboard/compliance_card.dart';
import 'package:immunicare/screens/parent/components/dashboard/educational_hub.dart';
import 'package:immunicare/screens/parent/components/dashboard/reminder.dart';
import 'package:provider/provider.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  UserModel? parent;
  String? role;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ChildViewModel>(context, listen: false);
      final authProvider = Provider.of<AuthViewModel>(context, listen: false);
      role = authProvider.role;
      provider.parentUid = authProvider.currentUser?.uid ?? '';
      parent = authProvider.userdata;

      if (role == 'relative') {
        provider.getChildrenByParentId(authProvider.userdata?.parentId ?? '');
      } else {
        provider.getChildrenByParentId(provider.parentUid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChildViewModel>(
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: bgColor,
          drawer: DrawerMenu(),
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Responsive.isDesktop(context))
                  Expanded(child: DrawerMenu()),
                Expanded(
                  flex: 5,
                  child: SafeArea(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(appPadding),
                      child: Column(
                        children: [
                          CustomAppbar(),
                          Gap(appPadding),
                          Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      children: [
                                        AnalyticCards(
                                          item: [
                                            AnalyticInfoCard(
                                              onPressed:
                                                  () => Navigator.pushNamed(
                                                    context,
                                                    '/children',
                                                  ),
                                              info: AnalyticInfo(
                                                title:
                                                    role == 'parent'
                                                        ? 'My Children'
                                                        : 'Children List',
                                                count: value.children.length,
                                                svgSrc:
                                                    "assets/icons/Subscribers.svg",
                                                color: primaryColor,
                                              ),
                                            ),
                                            AnalyticInfoCard(
                                              onPressed:
                                                  () => Navigator.pushNamed(
                                                    context,
                                                    '/add_relatives',
                                                  ),
                                              info: AnalyticInfo(
                                                title: 'Added Relatives',
                                                count:
                                                    parent?.relatives?.length,
                                                svgSrc:
                                                    "assets/icons/Subscribers.svg",
                                                color: purple,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Gap(appPadding),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: RemindersCard(),
                                            ),
                                            if (!Responsive.isMobile(context))
                                              Gap(appPadding),
                                            if (!Responsive.isMobile(context))
                                              Expanded(child: EducationalHub()),
                                          ],
                                        ),
                                        Gap(appPadding),
                                        ComplianceCard(),
                                        Gap(appPadding),
                                        if (Responsive.isMobile(context))
                                          EducationalHub(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // if (Responsive.isMobile(context)) UsersByDevice(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
