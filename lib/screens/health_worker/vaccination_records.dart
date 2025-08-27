import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/constants/responsive.dart';
import 'package:immunicare/controllers/controller.dart';
import 'package:immunicare/screens/components/dashboard/custom_appbar.dart';
import 'package:immunicare/screens/components/dashboard/drawer_menu.dart';
import 'package:provider/provider.dart';

class VaccinationRecords extends StatefulWidget {
  const VaccinationRecords({super.key});

  @override
  State<VaccinationRecords> createState() => _VaccinationRecordsState();
}

class _VaccinationRecordsState extends State<VaccinationRecords> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      drawer:
          Responsive.isMobile(context)
              ? DrawerMenu()
              : null, // Only show drawer on mobile
      key: context.read<Controller>().scaffoldKey,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Static DrawerMenu for desktop
            if (Responsive.isDesktop(context))
              const Expanded(flex: 1, child: DrawerMenu()),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(appPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAppbar(),
                    Gap(appPadding),
                    Text(
                      'Vaccination Records',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Gap(appPadding),
                    ListView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(), // Added to prevent nested scrolling issues
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.medical_services),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Person Name'),
                                Text(
                                  'Vaccine Name',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text('Date Administered: 2023-01-01'),
                            trailing: Text('Dose: 1st'),
                          ),
                        );
                      },
                      itemCount: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: OvalBorder(),
        tooltip: 'Add Vaccination Record',
        onPressed: () {
          // Action to add a new vaccination record
        },
        backgroundColor: const Color.fromARGB(168, 17, 161, 250),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
