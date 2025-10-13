import 'package:flutter/material.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/controllers/child_viewmodel.dart';
import 'package:provider/provider.dart';

class GisMapping extends StatefulWidget {
  const GisMapping({super.key});

  @override
  State<GisMapping> createState() => _GisMappingState();
}

class _GisMappingState extends State<GisMapping> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GIS Data Overview'),
        backgroundColor: Colors.white,
      ),
      body: Consumer<ChildViewModel>(
        builder: (context, value, child) {
          final List<String> barangays = value.getUniqueBarangays();

          // If data is empty, prompt the user to ensure data is loaded
          if (barangays.isEmpty && value.children.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(appPadding * 2),
                child: Text(
                  'No child data loaded or no unique barangays found.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.all(appPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(100),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: appPadding),
                  child: Text(
                    'Geographic Health Metrics (Barangay View)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.resolveWith(
                      (states) => primaryColor.withAlpha(150),
                    ),
                    border: TableBorder.all(
                      color: Colors.grey.shade400,
                      width: 2.0,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    columnSpacing: 18.0,
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Barangay',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Compliance Score',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text(
                          'Total Children',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text(
                          'Fully Vaccinated',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text(
                          'Incompletely Vaccinated',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text(
                          'Overdue Vaccines',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        numeric: true,
                      ),
                    ],
                    rows:
                        barangays.map((barangay) {
                          final compliance = value.getComplianceScoreByBarangay(
                            barangay,
                          );
                          final totalChildren = value
                              .getTotalChildrenByBarangay(barangay);
                          final fullyVaccinated = value
                              .getFullyVaccinatedCountByBarangay(barangay);
                          final incompleteVaccinated = value
                              .getIncompletelyVaccinatedCountByBarangay(
                                barangay,
                              );
                          final totalOverdue = value.getTotalOverdueByBarangay(
                            barangay,
                          );

                          // Determine color for Compliance Score
                          Color complianceColor;
                          if (compliance >= 90) {
                            complianceColor = Colors.green.shade700;
                          } else if (compliance >= 70) {
                            complianceColor = Colors.orange.shade700;
                          } else {
                            complianceColor = Colors.red.shade700;
                          }

                          return DataRow(
                            cells: [
                              DataCell(Text(barangay)),
                              DataCell(
                                Text(
                                  '${compliance.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: complianceColor,
                                  ),
                                ),
                              ),
                              DataCell(Text(totalChildren.toString())),
                              DataCell(Text(fullyVaccinated.toString())),
                              DataCell(
                                Text(
                                  incompleteVaccinated.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    // Highlight children who are not fully vaccinated
                                    color:
                                        incompleteVaccinated > 0
                                            ? primaryColor
                                            : textColor,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  totalOverdue.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    // Strongly highlight overdue vaccines
                                    color:
                                        totalOverdue > 0
                                            ? Colors.red
                                            : textColor,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
