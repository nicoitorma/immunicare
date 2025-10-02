import 'package:flutter/material.dart';
import 'package:immunicare/constants/constants.dart';

class Reminders extends StatefulWidget {
  const Reminders({super.key});

  @override
  State<Reminders> createState() => _RemindersState();
}

class _RemindersState extends State<Reminders> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(Icons.notifications, color: primaryColor),
            title: Text(
              'Reminders',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(appPadding),
              child: ListView.builder(
                itemCount: 2,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.notification_important),
                    title: Text('Reminder ${index + 1}'),
                    subtitle: Text(
                      'This is the detail of reminder ${index + 1}.',
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
