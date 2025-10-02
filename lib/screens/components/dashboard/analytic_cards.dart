import 'package:flutter/material.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/constants/responsive.dart';

import 'analytic_info_card.dart';

class AnalyticCards extends StatelessWidget {
  AnalyticCards({Key? key, required this.item}) : super(key: key);

  final List<AnalyticInfoCard> item;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      child: Responsive(
        mobile: AnalyticInfoCardGridView(
          crossAxisCount: size.width < 650 ? 2 : 2,
          childAspectRatio: size.width < 650 ? 2 : 1.5,
          item: item,
        ),
        tablet: AnalyticInfoCardGridView(item: item),
        desktop: AnalyticInfoCardGridView(
          childAspectRatio: size.width < 1400 ? 1.5 : 2.1,
          item: item,
        ),
      ),
    );
  }
}

class AnalyticInfoCardGridView extends StatelessWidget {
  AnalyticInfoCardGridView({
    Key? key,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.4,
    required this.item,
  }) : super(key: key);

  final int crossAxisCount;
  final double childAspectRatio;
  final List<AnalyticInfoCard> item;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: item.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: appPadding,
        mainAxisSpacing: appPadding,
        mainAxisExtent: 100,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => item[index],
    );
  }
}
