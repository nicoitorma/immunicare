import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/constants/responsive.dart';
import 'package:immunicare/controllers/health_worker/health_worker_viewmodel.dart';
import 'package:immunicare/models/user_model.dart';
import 'package:immunicare/screens/components/dashboard/custom_appbar.dart';
import 'package:immunicare/screens/components/dashboard/drawer_menu.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HealthWorkers extends StatefulWidget {
  const HealthWorkers({super.key});

  @override
  State<HealthWorkers> createState() => _HealthWorkersState();
}

class _HealthWorkersState extends State<HealthWorkers> {
  HealthWorkerViewmodel? healthWorkerProv;

  // State variables for sorting
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  // bool _isSaving = false;

  // Widget _firstnameField() {
  //   return TextFormField(
  //     controller: _firstnameController,
  //     decoration: InputDecoration(
  //       labelText: 'Firstname',
  //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  //       prefixIcon: const Icon(Icons.person_outline),
  //       prefixIconColor: primaryColor,
  //     ),
  //   );
  // }

  // Widget _lastnameField() {
  //   return TextFormField(
  //     controller: _lastnameController,
  //     decoration: InputDecoration(
  //       labelText: 'Lastname',
  //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  //       prefixIcon: const Icon(Icons.person_outline),
  //       prefixIconColor: primaryColor,
  //     ),
  //   );
  // }

  // void _addUserDialog() {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => Dialog(
  //           backgroundColor: Colors.white,
  //           child: ConstrainedBox(
  //             constraints: BoxConstraints(maxWidth: 600),
  //             child: Padding(
  //               padding: const EdgeInsets.all(appPadding),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   if (Responsive.isDesktop(context))
  //                     Row(
  //                       children: [
  //                         Expanded(child: _firstnameField()),
  //                         Gap(appPadding),
  //                         Expanded(child: _lastnameField()),
  //                       ],
  //                     ),
  //                   if (Responsive.isMobile(context)) _firstnameField(),
  //                   Gap(appPadding),
  //                   if (Responsive.isMobile(context)) _lastnameField(),
  //                   Gap(appPadding),
  //                   DropdownMenu<String>(
  //                     label: Text('Address'),
  //                     width: double.infinity,
  //                     controller: _addressController,
  //                     leadingIcon: const Icon(
  //                       Icons.location_on_outlined,
  //                       color: primaryColor,
  //                     ),
  //                     inputDecorationTheme: InputDecorationTheme(
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                     ),
  //                     dropdownMenuEntries:
  //                         barangays.map<DropdownMenuEntry<String>>((
  //                           String value,
  //                         ) {
  //                           return DropdownMenuEntry<String>(
  //                             value: value,
  //                             label: value,
  //                           );
  //                         }).toList(),
  //                   ),
  //                   Gap(appPadding),
  //                   TextFormField(
  //                     controller: _emailController,
  //                     decoration: InputDecoration(
  //                       labelText: 'Email',
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                       prefixIcon: const Icon(Icons.email_outlined),
  //                       prefixIconColor: primaryColor,
  //                     ),
  //                   ),
  //                   Gap(appPadding),
  //                   Text('Notes: '),
  //                   Text('\t -Password will be generated randomly.'),
  //                   Text(
  //                     '\t -Confirmation link will be sent to the provided email.',
  //                   ),
  //                   Gap(appPadding),
  //                   Padding(
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 16,
  //                       vertical: 16,
  //                     ),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.end,
  //                       children: [
  //                         ElevatedButton(
  //                           onPressed: () {
  //                             Navigator.pop(context);
  //                           },
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: Colors.blue[500],
  //                             foregroundColor: Colors.white,
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(20),
  //                             ),
  //                             padding: const EdgeInsets.symmetric(
  //                               horizontal: 12,
  //                               vertical: 6,
  //                             ),
  //                           ),
  //                           child: Text('Cancel'),
  //                         ),
  //                         const Gap(appPadding),
  //                         ElevatedButton(
  //                           onPressed: () async {
  //                             UserModel health_worker = UserModel(
  //                               lastname: _lastnameController.text.trim(),
  //                               firstname: _firstnameController.text.trim(),
  //                               email: _emailController.text.trim(),
  //                               address: _addressController.text.trim(),
  //                               role: 'health_worker',
  //                               createdAt: Timestamp.fromDate(DateTime.now()),
  //                             );

  //                             String randomPassword =
  //                                 AuthService().generateRandomPassword();
  //                             await healthWorkerProv?.createNewAccount(
  //                               health_worker,
  //                               randomPassword,
  //                             );
  //                             if (healthWorkerProv?.result != null) {
  //                               showDialog(
  //                                 barrierDismissible: false,
  //                                 context: context,
  //                                 builder:
  //                                     (context) => AlertDialog(
  //                                       backgroundColor: Colors.white,
  //                                       title: Text('Sign in details'),
  //                                       content: Column(
  //                                         mainAxisSize: MainAxisSize.min,
  //                                         children: [
  //                                           Text(
  //                                             'Email: ${health_worker.email}',
  //                                           ),
  //                                           Gap(8),
  //                                           Text('Password: $randomPassword'),
  //                                         ],
  //                                       ),
  //                                       actions: [
  //                                         TextButton(
  //                                           onPressed: () {
  //                                             _firstnameController.clear();
  //                                             _lastnameController.clear();
  //                                             _addressController.clear();
  //                                             _emailController.clear();
  //                                             Navigator.of(context).pop();
  //                                           },
  //                                           child: const Text('OK'),
  //                                         ),
  //                                       ],
  //                                     ),
  //                               );
  //                             }
  //                             if (healthWorkerProv?.errorMessage != null) {
  //                               showDialog(
  //                                 context: context,
  //                                 builder:
  //                                     (context) => AlertDialog(
  //                                       title: Text('Error creating account!'),
  //                                       content: Text(
  //                                         healthWorkerProv!.errorMessage!,
  //                                       ),
  //                                       actions: [
  //                                         TextButton(
  //                                           onPressed: () {
  //                                             // Dismiss the dialog when the user clicks 'OK'
  //                                             Navigator.of(context).pop();
  //                                           },
  //                                           child: const Text('OK'),
  //                                         ),
  //                                       ],
  //                                     ),
  //                               );
  //                             }
  //                           },
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: Colors.green,
  //                             foregroundColor: Colors.white,
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(20),
  //                             ),
  //                             padding: const EdgeInsets.symmetric(
  //                               horizontal: 12,
  //                               vertical: 6,
  //                             ),
  //                           ),
  //                           child:
  //                               _isSaving
  //                                   ? CircularProgressIndicator()
  //                                   : Text('Save'),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //   );
  // }

  void _deleteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Delete ${user.firstname}?'),
          content: Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                healthWorkerProv?.deleteUser(user.id!);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _editUserRole(UserModel user) {
    String selectedRole = user.role;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Edit Role for ${user.firstname}'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: selectedRole,
                    menuWidth: double.infinity,
                    dropdownColor: Colors.white,
                    items:
                        <String>['parent', 'health_worker'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value == 'parent' ? 'Parent' : 'Health Worker',
                            ),
                          );
                        }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        print('Selected role: $newValue');
                        selectedRole = newValue!;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                UserModel updatedUser = UserModel(
                  id: user.id,
                  firstname: user.firstname,
                  lastname: user.lastname,
                  email: user.email,
                  address: user.address,
                  role: selectedRole,
                  createdAt: user.createdAt,
                );
                healthWorkerProv?.editUser(updatedUser);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    healthWorkerProv = Provider.of<HealthWorkerViewmodel>(
      context,
      listen: false,
    );

    healthWorkerProv?.getAllHealthWorker();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthWorkerViewmodel>(
      builder: (context, value, child) {
        return Scaffold(
          drawer: DrawerMenu(),
          body: Padding(
            padding: const EdgeInsets.all(appPadding),
            child: Row(
              children: [
                if (Responsive.isDesktop(context))
                  Expanded(child: DrawerMenu()),
                Expanded(
                  flex: 5,
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomAppbar(),
                        Text(
                          'Health Workers',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        if (value.filteredHealthWorkers.isEmpty)
                          Expanded(
                            child: Center(
                              child: Text(
                                'No Health Workers added. Click the add button to add health worker.',
                                style: Theme.of(context).textTheme.labelLarge,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        Gap(appPadding),
                        if (value.filteredHealthWorkers.isNotEmpty)
                          SizedBox(
                            width: double.infinity,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                sortColumnIndex: _sortColumnIndex,
                                sortAscending: _sortAscending,
                                columns: [
                                  DataColumn(
                                    label: const Text('Lastname'),
                                    onSort: (columnIndex, ascending) {
                                      setState(() {
                                        _sortColumnIndex = 0;
                                      });
                                      return value.onSort(
                                        columnIndex,
                                        ascending,
                                      );
                                    },
                                  ),
                                  const DataColumn(label: Text('Firstname')),
                                  DataColumn(
                                    label: const Text('Address'),
                                    onSort: (columnIndex, ascending) {
                                      setState(() {
                                        _sortColumnIndex = 1;
                                      });
                                      return value.onSort(
                                        columnIndex,
                                        ascending,
                                      );
                                    },
                                  ),
                                  const DataColumn(label: Text('Role')),
                                  const DataColumn(label: Text('Created')),
                                  const DataColumn(label: Text('Action')),
                                ],
                                rows:
                                    value.filteredHealthWorkers.map((user) {
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(user.lastname)),
                                          DataCell(Text(user.firstname)),
                                          DataCell(Text(user.address)),
                                          DataCell(
                                            Text(
                                              user.role == 'parent'
                                                  ? 'Parent'
                                                  : 'Health Worker',
                                              style: TextStyle(
                                                color:
                                                    user.role == 'parent'
                                                        ? Colors.blue
                                                        : Colors.green,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              DateFormat('MMMM d, y')
                                                  .format(
                                                    user.createdAt!.toDate(),
                                                  )
                                                  .toString(),
                                            ),
                                          ),
                                          DataCell(
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    size: 18,
                                                  ),
                                                  color: Colors.green[600],
                                                  onPressed:
                                                      () => _editUserRole(user),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    size: 18,
                                                  ),
                                                  color: Colors.red[600],
                                                  onPressed:
                                                      () => _deleteUser(user),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   shape: const CircleBorder(),
          //   backgroundColor: primaryColor,
          //   onPressed: () => _addUserDialog(),
          //   child: const Icon(Icons.add, color: Colors.white),
          // ),
        );
      },
    );
  }
}
