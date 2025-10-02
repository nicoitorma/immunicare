import 'package:flutter/material.dart';

class ScheduleSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  const ScheduleSection({required this.isExpanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Vaccination Schedule',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            isExpanded ? 'Hide All' : 'View All',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2563EB),
            ),
          ),
        ),
      ],
    );
  }
}
