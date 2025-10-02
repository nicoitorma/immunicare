import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:immunicare/controllers/child_viewmodel.dart';
import 'package:intl/intl.dart';

class ScheduleList extends StatefulWidget {
  final ChildViewModel viewModel;
  final bool isExpanded;
  final Function(String)? onReschedule;
  final Function? onMarkComplete;

  const ScheduleList({
    required this.viewModel,
    required this.isExpanded,
    this.onReschedule,
    this.onMarkComplete,
  });

  @override
  State<ScheduleList> createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  @override
  Widget build(BuildContext context) {
    final selectedChild = widget.viewModel.child;
    if (selectedChild == null) {
      return const SizedBox.shrink();
    }
    return AnimatedCrossFade(
      firstChild: const SizedBox.shrink(),
      secondChild: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var ageGroup in selectedChild.schedule)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ageGroup['age'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const Gap(8),
                    if (ageGroup['vaccines'] is List)
                      for (var vaccine in ageGroup['vaccines'])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Gap(20),
                              Text(
                                vaccine['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  overflow: TextOverflow.ellipsis,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Gap(10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      DateFormat('MMMM d, y')
                                          .format(vaccine['date'].toDate())
                                          .toString(),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      vaccine['status'].toUpperCase(),
                                      style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            vaccine['status'] == 'complete'
                                                ? const Color(0xFF15803D)
                                                : vaccine['status'] == 'due'
                                                ? const Color(0xFFE11D48)
                                                : const Color(0xFFF59E0B),
                                      ),
                                    ),
                                  ),
                                  const Gap(5),
                                  if (vaccine['status'] == 'due')
                                    if (widget.viewModel.parentUid != '')
                                      Expanded(
                                        child: TextButton(
                                          onPressed:
                                              () => widget.onMarkComplete!(
                                                vaccine['name'],
                                              ),
                                          style: TextButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF22C55E,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: const Text(
                                            'Done',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                  if (vaccine['status'] == 'due') const Gap(8),
                                  if (vaccine['status'] == 'due')
                                    if (widget.viewModel.parentUid != '')
                                      Expanded(
                                        child: TextButton(
                                          onPressed:
                                              () => widget.onReschedule!(
                                                vaccine['name'],
                                              ),
                                          style: TextButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFF59E0B,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: const Text(
                                            'Reschedule',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
            ),
        ],
      ),
      crossFadeState:
          widget.isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
    );
  }
}
