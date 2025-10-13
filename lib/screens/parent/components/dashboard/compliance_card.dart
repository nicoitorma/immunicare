import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/controllers/child_viewmodel.dart';
import 'package:provider/provider.dart';

class ComplianceCard extends StatelessWidget {
  const ComplianceCard({super.key});

  // A simple status message based on the compliance score
  String getStatusMessage(double score) {
    if (score == 1.0) {
      return 'Outstanding! All due vaccinations are complete.';
    } else if (score >= 0.75) {
      return 'Great! You are on track with immunizations.';
    } else if (score >= 0.5) {
      return 'Good progress, but some doses are due.';
    } else {
      return 'Attention: Several vaccinations are currently due.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChildViewModel>(
      builder: (context, value, child) {
        // Only show the card if a child is actively selected
        if (value.child == null) {
          return const SizedBox.shrink();
        }

        final score = value.complianceScore;
        final percentage = (score * 100).round();

        // Define colors based on compliance level for visual feedback
        final Color complianceColor =
            score == 1.0
                ? const Color(0xFF10B981) // Green for 100%
                : score >= 0.75
                ? const Color(0xFFFBBF24) // Yellow for high
                : const Color(0xFFEF4444); // Red for low

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Overall Compliance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Gap(16),
              DropdownButton<String>(
                dropdownColor: Colors.white,
                style: TextStyle(overflow: TextOverflow.ellipsis),
                value: value.child?.id ?? value.children.first.id,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    value.getChildById(childId: newValue);
                  }
                },
                items:
                    value.children.map<DropdownMenuItem<String>>((child) {
                      return DropdownMenuItem<String>(
                        value: child.id,
                        child: Text(
                          '${child.firstname} ${child.lastname}',
                          style: const TextStyle(
                            fontSize: 16,
                            overflow: TextOverflow.ellipsis,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      );
                    }).toList(),
              ),
              Gap(appPadding),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Circular Progress Indicator
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: score,
                            strokeWidth: 8,
                            backgroundColor: const Color(0xFFE5E7EB),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              complianceColor,
                            ),
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: complianceColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(20),
                  // Status Message and Action Button
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getStatusMessage(score),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                        const Gap(8),
                        TextButton.icon(
                          onPressed:
                              () => Navigator.pushNamed(context, '/children'),
                          icon: const Icon(
                            Icons.arrow_forward,
                            size: 18,
                            color: Color(0xFF3B82F6),
                          ),
                          label: const Text(
                            'View Full Schedule',
                            style: TextStyle(
                              color: Color(0xFF3B82F6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
