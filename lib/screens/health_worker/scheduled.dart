import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/constants/responsive.dart';
import 'package:immunicare/controllers/child_viewmodel.dart';
import 'package:immunicare/screens/components/dashboard/custom_appbar.dart';
import 'package:immunicare/screens/components/dashboard/drawer_menu.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Scheduled extends StatefulWidget {
  const Scheduled({super.key});

  @override
  State<Scheduled> createState() => _ScheduledState();
}

class _ScheduledState extends State<Scheduled> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChildViewModel>(
      builder:
          (context, value, child) => Scaffold(
            drawer: DrawerMenu(),
            backgroundColor: Colors.white,
            body: Padding(
              padding: const EdgeInsets.all(appPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (Responsive.isDesktop(context))
                    Expanded(child: DrawerMenu()),
                  Expanded(
                    flex: 5,
                    child: SafeArea(
                      child: Column(
                        children: [
                          CustomAppbar(),
                          Text(
                            'Overdue & Scheduled Vaccinations',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: value.scheduled.length,
                              itemBuilder: (context, index) {
                                final data = value.scheduled[index];
                                final dueDateTime =
                                    (data['vaccine']['date'] as Timestamp)
                                        .toDate();
                                return Container(
                                  margin: const EdgeInsets.all(appPadding),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      241,
                                      252,
                                      255,
                                    ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${data['child'].firstname} ${data['child'].lastname}',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const Text(
                                        'Next Vaccination',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                            255,
                                            71,
                                            109,
                                            169,
                                          ),
                                        ),
                                      ),
                                      const Gap(16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                                  data['vaccine']['name'] ??
                                                      'No upcoming vaccinations',
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFFE11D48),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
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
                                                  DateFormat(
                                                    'MMMM d, y',
                                                  ).format(dueDateTime),
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
                                      Center(
                                        child: Text(
                                          data['vaccine']['date'] != null
                                              ? 'Days left: ${dueDateTime.difference(DateTime.now()).inDays}'
                                              : 'All vaccinations complete!',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                      const Gap(24),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                      255,
                                                      47,
                                                      234,
                                                      72,
                                                    ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              onPressed: () async {
                                                final result = await value
                                                    .markAsComplete(
                                                      data['parentId'],
                                                      data['child'],
                                                      data['vaccine']['name'],
                                                    );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(result),
                                                  ),
                                                );
                                              },
                                              child: const Text(
                                                'Done',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Gap(16),
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFFFEE2E2,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  side: const BorderSide(
                                                    color: Color(0xFFE11D48),
                                                  ),
                                                ),
                                              ),
                                              onPressed: () async {
                                                final newDate =
                                                    await showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          DateTime.now(),
                                                      firstDate: DateTime.now(),
                                                      lastDate: DateTime.now()
                                                          .add(
                                                            const Duration(
                                                              days: 365 * 5,
                                                            ),
                                                          ),
                                                    );
                                                if (newDate != null) {
                                                  final result = await value
                                                      .updateVaccineDate(
                                                        data['parentId'],
                                                        data['child'],
                                                        data['vaccine']['name'],
                                                        newDate,
                                                      );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(result),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Text(
                                                'Reschedule',
                                                style: TextStyle(
                                                  color: Color(0xFFE11D48),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
