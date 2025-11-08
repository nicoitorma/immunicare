import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class RelativeCard extends StatelessWidget {
  const RelativeCard({
    super.key,
    required this.name,
    required this.email,
    required this.accessPin,
  });

  final String name;
  final String email;
  final int accessPin;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            Text('Email : $email', style: TextStyle(fontSize: 16)),
            const Gap(8),
            Text(
              'Access PIN: ${accessPin.toString()}',
              style: TextStyle(fontSize: 16),
            ),
            const Gap(16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                // Implement remove relative functionality
              },
              child: const Text(
                'Remove Relative',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
