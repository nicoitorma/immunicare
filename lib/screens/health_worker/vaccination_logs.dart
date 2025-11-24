import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/constants/responsive.dart';
import 'package:immunicare/controllers/health_worker/health_worker_viewmodel.dart';
import 'package:immunicare/screens/components/dashboard/custom_appbar.dart';
import 'package:immunicare/screens/components/dashboard/drawer_menu.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

class VaccinationLogs extends StatefulWidget {
  const VaccinationLogs({super.key});

  @override
  State<VaccinationLogs> createState() => _VaccinationLogsState();
}

class _VaccinationLogsState extends State<VaccinationLogs> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<HealthWorkerViewmodel>(context, listen: false);
    provider.getVaccinationLogs();
  }

  @override
  Widget build(BuildContext context) {
    String? healthWorker;

    return Consumer<HealthWorkerViewmodel>(
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: bgColor,
          drawer: DrawerMenu(),
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Responsive.isDesktop(context))
                  Expanded(child: DrawerMenu()),
                Expanded(
                  flex: 5,
                  child: SafeArea(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsets.all(appPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomAppbar(),
                          Gap(appPadding),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Vaccination Logs',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () async {
                                  final pdfData = await value.exportVaxLog(
                                    healthWorker ?? '',
                                  );
                                  await Printing.layoutPdf(
                                    name: '${healthWorker}_vax_log',
                                    onLayout: (format) async => pdfData,
                                  );
                                },
                                child: Text('Export Log'),
                              ),
                            ],
                          ),
                          Gap(appPadding),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: [
                                const DataColumn(label: Text('Child name')),
                                const DataColumn(label: Text('Vaccine name')),
                                const DataColumn(
                                  label: Text('Administered by'),
                                ),
                                const DataColumn(
                                  label: Text('Administered at'),
                                ),
                              ],
                              rows:
                                  value.vaxLog.map((vax) {
                                    healthWorker = vax.administeredBy;
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(vax.childName ?? '')),
                                        DataCell(Text(vax.vaccineName ?? '')),
                                        DataCell(
                                          Text(vax.administeredBy ?? ''),
                                        ),
                                        DataCell(
                                          Text(
                                            DateFormat('MMMM d, y, h:mm a')
                                                .format(
                                                  vax.administeredAt.toDate(),
                                                )
                                                .toString(),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
