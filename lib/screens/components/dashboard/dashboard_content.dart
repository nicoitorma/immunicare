import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/constants/responsive.dart';
import 'package:immunicare/controllers/child_viewmodel.dart';
import 'package:immunicare/models/analytic_info_model.dart';
import 'package:immunicare/screens/components/dashboard/analytic_cards.dart';
import 'package:immunicare/screens/components/dashboard/analytic_info_card.dart';
import 'package:immunicare/screens/components/dashboard/custom_appbar.dart';
import 'package:immunicare/screens/components/dashboard/overall_vaccination_ratio_card.dart';
import 'package:immunicare/screens/parent/components/dashboard/reminder.dart';
import 'package:provider/provider.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({Key? key}) : super(key: key);

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ChildViewModel>(context, listen: false);
      provider.getScheduledChildrenWithVaccines(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChildViewModel>(
      builder: (context, value, child) {
        return SafeArea(
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
                                          '/registered_children',
                                        ),
                                    info: AnalyticInfo(
                                      title: "Children Registered",
                                      count: value.childrenCount,
                                      svgSrc: "assets/icons/Subscribers.svg",
                                      color: primaryColor,
                                    ),
                                  ),
                                  AnalyticInfoCard(
                                    onPressed:
                                        () => Navigator.pushNamed(
                                          context,
                                          '/scheduled',
                                        ),
                                    info: AnalyticInfo(
                                      title: "Scheduled",
                                      count: value.scheduled.length,
                                      svgSrc: "assets/icons/syringe.svg",
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              Gap(appPadding),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 2, child: RemindersCard()),
                                  if (!Responsive.isMobile(context))
                                    Gap(appPadding),
                                  if (!Responsive.isMobile(context))
                                    Expanded(
                                      child: OverallVaccinationRatioCard(),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Gap(appPadding),
                    if (Responsive.isMobile(context))
                      OverallVaccinationRatioCard(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
