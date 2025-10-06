import 'package:flutter/material.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/controllers/child_viewmodel.dart';
import 'package:immunicare/screens/components/dashboard/radial_painter.dart';
import 'package:provider/provider.dart';

class OverallVaccinationRatioCard extends StatelessWidget {
  const OverallVaccinationRatioCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap with Consumer to access the ChildViewModel
    return Consumer<ChildViewModel>(
      builder: (context, value, child) {
        // Fetch the score (0 to 100)
        final double score = value.overallComplianceScore;

        // Convert score to a fraction (0.0 to 1.0) for the CustomPainter
        final double percent = score / 100.0;

        // Format score for the center text (e.g., "75.5%")
        final String formattedScore = '${score.round()}%';

        return Container(
          height: 350,
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(100),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(appPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Overall Vaccination Ratio',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                margin: const EdgeInsets.all(appPadding),
                padding: const EdgeInsets.all(appPadding),
                height: 230,
                // CustomPaint uses the dynamic percentage
                child: CustomPaint(
                  foregroundPainter: RadialPainter(
                    // Background track color
                    bgColor: textColor.withOpacity(0.1),
                    // Progress color
                    lineColor: primaryColor,
                    // Dynamic percentage from ViewModel
                    percent: percent,
                    width: 18.0,
                  ),
                  child: Center(
                    child: Text(
                      // Dynamic score text
                      formattedScore,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 48, // Made slightly larger for impact
                        fontWeight: FontWeight.w800,
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
                    // Vaccinated (Completed)
                    Row(
                      children: [
                        Icon(Icons.circle, color: primaryColor, size: 10),
                        const SizedBox(width: appPadding / 2),
                        Text(
                          'Vaccinated',
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    // Non-Vaccinated (Due/Upcoming)
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: textColor.withOpacity(0.2),
                          size: 10,
                        ),
                        const SizedBox(width: appPadding / 2),
                        Text(
                          'Remaining', // Changed label for clarity
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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
      },
    );
  }
}
