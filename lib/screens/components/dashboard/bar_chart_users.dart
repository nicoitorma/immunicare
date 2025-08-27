import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:immunicare/constants/constants.dart';

class BarChartUsers extends StatelessWidget {
  const BarChartUsers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(border: Border.all(width: 0)),
          groupsSpace: 15,
          titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(axisNameWidget: Text('Barangays')),
          ),
          barGroups: [
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: 10,
                  width: 20,
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: 3,
                  width: 20,
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(
                  toY: 12,
                  width: 20,
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),
            BarChartGroupData(
              x: 4,
              barRods: [
                BarChartRodData(
                  toY: 8,
                  width: 20,
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),
            BarChartGroupData(
              x: 5,
              barRods: [
                BarChartRodData(
                  toY: 6,
                  width: 20,
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),
            BarChartGroupData(
              x: 6,
              barRods: [
                BarChartRodData(
                  toY: 10,
                  width: 20,
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),
            BarChartGroupData(
              x: 7,
              barRods: [
                BarChartRodData(
                  toY: 16,
                  width: 20,
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),
            BarChartGroupData(
              x: 8,
              barRods: [
                BarChartRodData(
                  toY: 6,
                  width: 20,
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
