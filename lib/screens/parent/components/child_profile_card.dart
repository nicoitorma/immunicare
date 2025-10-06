import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:immunicare/controllers/child_viewmodel.dart';

class ChildProfileCard extends StatelessWidget {
  final ChildViewModel viewModel;

  const ChildProfileCard({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final selectedChild = viewModel.child ?? viewModel.children.first;
    final ageInMonths = viewModel.calculateAgeInMonths(
      selectedChild.dateOfBirth,
    );
    final ageDisplay =
        ageInMonths < 12
            ? '$ageInMonths months'
            : '${(ageInMonths / 12).floor()} years, ${ageInMonths % 12} months';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFBFDBFE),
              borderRadius: BorderRadius.circular(32),
            ),
            alignment: Alignment.center,
            child: Text(
              selectedChild.firstname[0],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D4ED8),
              ),
            ),
          ),
          const Gap(16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButton<String>(
                style: TextStyle(overflow: TextOverflow.ellipsis),
                value: viewModel.child?.id ?? viewModel.children.first.id,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    viewModel.getChildById(childId: newValue);
                  }
                },
                items:
                    viewModel.children.map<DropdownMenuItem<String>>((child) {
                      return DropdownMenuItem<String>(
                        value: child.id,
                        child: Text(
                          '${child.firstname} ${child.lastname}',
                          style: const TextStyle(
                            fontSize: 20,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      );
                    }).toList(),
              ),
              Text(
                ageDisplay,
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
