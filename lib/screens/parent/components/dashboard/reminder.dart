import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/controllers/child_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RemindersCard extends StatelessWidget {
  const RemindersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChildViewModel>(
      builder: (context, value, child) {
        // Only display the card if a child is actively selected
        final nextReminder = value.nextVaccination;
        final String vaccineName = nextReminder?['name'] ?? 'No Due Vaccine';
        final String dueDateString =
            nextReminder != null
                ? DateFormat('MMMM d, y').format(nextReminder['date'].toDate())
                : 'No Date Set';
        // -
        return Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(Icons.notifications_active, color: primaryColor),
                title: Text(
                  'Upcoming Reminder',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('Select Child:'),
                    Gap(appPadding),
                    DropdownButton<String>(
                      style: TextStyle(overflow: TextOverflow.ellipsis),
                      value: value.child?.id ?? value.children.first.id,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          value.getChildById(newValue);
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
                  ],
                ),
              ),
              SizedBox(
                height: 120, // Provides good vertical spacing for content
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: Icon(Icons.vaccines, color: primaryColor),
                    title: Text(
                      vaccineName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      // Format the Firestore Timestamp to a readable date string
                      dueDateString,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
