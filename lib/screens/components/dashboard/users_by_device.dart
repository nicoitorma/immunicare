import 'package:flutter/material.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/screens/components/dashboard/radial_painter.dart';

class UsersByDevice extends StatelessWidget {
  const UsersByDevice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(appPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vaccination Ratio',
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(
            margin: EdgeInsets.all(appPadding),
            padding: EdgeInsets.all(appPadding),
            height: 230,
            child: CustomPaint(
              foregroundPainter: RadialPainter(
                bgColor: textColor.withValues(alpha: 0.1),
                lineColor: primaryColor,
                percent: 0.7,
                width: 18.0,
              ),
              child: Center(
                child: Text(
                  '70%',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: appPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Icon(Icons.circle, color: primaryColor, size: 10),
                    SizedBox(width: appPadding / 2),
                    Text(
                      'Vaccinated',
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: textColor.withValues(alpha: 0.2),
                      size: 10,
                    ),
                    SizedBox(width: appPadding / 2),
                    Text(
                      'Non-Vaccinated',
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
