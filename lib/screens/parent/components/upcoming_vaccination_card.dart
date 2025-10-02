import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:immunicare/controllers/child_viewmodel.dart';
import 'package:intl/intl.dart';

class UpcomingVaccinationCard extends StatelessWidget {
  final ChildViewModel viewModel;

  const UpcomingVaccinationCard({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final nextVaccine = viewModel.nextVaccine(
      viewModel.child ?? viewModel.children.first,
    );
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Next Upcoming Vaccination',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vaccine Due',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const Gap(4),
                    Text(
                      nextVaccine?['name'] ?? 'No upcoming vaccinations',
                      style: const TextStyle(
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE11D48),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Due Date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const Gap(4),
                    Text(
                      nextVaccine != null
                          ? DateFormat(
                            'MMMM d, y',
                          ).format(nextVaccine['date'].toDate())
                          : '--',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE11D48),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value:
                  nextVaccine != null
                      ? viewModel.calculateProgress(nextVaccine['date'])
                      : 1.0,
              backgroundColor: const Color(0xFFFEE2E2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFE11D48),
              ),
              minHeight: 10,
            ),
          ),
          const Gap(8),
          Center(
            child: Text(
              nextVaccine != null
                  ? 'Days left: ${nextVaccine['date'].toDate().difference(DateTime.now()).inDays}'
                  : 'All vaccinations complete!',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
