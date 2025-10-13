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

    healthWorkerProv?.getAllHealthWorkers();
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
                          'User Management',
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
                                  const DataColumn(label: Text('Email')),
                                  const DataColumn(label: Text('Role')),
                                  const DataColumn(label: Text('Created')),
                                  const DataColumn(label: Text('Action')),
                                ],
                                rows:
                                    value.filteredHealthWorkers.map((user) {
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Text(
                                              user.lastname == ''
                                                  ? 'N/A'
                                                  : user.lastname,
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              user.firstname == ''
                                                  ? 'N/A'
                                                  : user.firstname,
                                            ),
                                          ),
                                          DataCell(Text(user.address)),
                                          DataCell(Text(user.email)),
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
