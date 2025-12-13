import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/constants/responsive.dart';
import 'package:immunicare/controllers/health_worker/health_worker_viewmodel.dart';
import 'package:immunicare/models/user_model.dart';
import 'package:immunicare/screens/components/dashboard/custom_appbar.dart';
import 'package:immunicare/screens/components/dashboard/drawer_menu.dart';
import 'package:immunicare/services/auth_services.dart';
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
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _licenseNumberController =
      TextEditingController();

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
                healthWorkerProv?.deleteUser(user);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _addEditUser({UserModel? existingUser}) {
    String dialogTitle =
        existingUser != null
            ? 'Edit Health Worker'
            : healthWorkerProv!.role == 'super_admin'
            ? 'Add Health Worker'
            : 'Add Parent';

    if (isEditing) {
      _firstnameController.text = existingUser!.firstname;
      _lastnameController.text = existingUser.lastname;
      _emailController.text = existingUser.email;
      _addressController.text = existingUser.address;
      _licenseNumberController.text = existingUser.licenseNumber ?? '';
    } else if (healthWorkerProv!.role == 'health_worker') {
      _addressController.text = healthWorkerProv!.address;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title:
              dialogTitle == 'Edit Health Worker'
                  ? Text('Edit ${existingUser!.firstname}')
                  : Text(dialogTitle),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _firstnameController,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter a firstname'
                              : null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'Firstname',
                  ),
                ),
                Gap(appPadding),
                TextFormField(
                  controller: _lastnameController,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter a lastname'
                              : null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'Lastname',
                  ),
                ),
                Gap(appPadding),
                TextFormField(
                  readOnly: isEditing,
                  controller: _emailController,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter an email'
                              : null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'Email',
                  ),
                ),
                Gap(appPadding),
                if (healthWorkerProv!.role == 'super_admin')
                  DropdownButtonFormField<String>(
                    initialValue: isEditing ? existingUser!.address : null,
                    dropdownColor: Colors.white,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Please select an address'
                                : null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: 'Address',
                    ),
                    items:
                        barangays.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (newValue) {
                      _addressController.text = newValue!;
                    },
                  ),
                Gap(appPadding),
                if ((isEditing && existingUser?.role == 'health_worker') ||
                    (!isEditing && healthWorkerProv?.role == 'super_admin'))
                  TextFormField(
                    controller: _licenseNumberController,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Please enter a license number / ID number'
                                : null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: 'PRC Number / ID Number',
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  isEditing = false;
                  clearFormFields();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              child: Text(isEditing ? 'Save Changes' : 'Add'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (isEditing) {
                    String? result = await healthWorkerProv?.updateUser(
                      existingUser!.copyWith(
                        firstname: _firstnameController.text,
                        lastname: _lastnameController.text,
                        address: _addressController.text,
                        updatedAt: Timestamp.now(),
                      ),
                    );
                    Navigator.of(context).pop();
                    if (result != 'success') {
                      _showErrorDialog(result ?? 'An error occurred.');
                    } else {
                      _showInfoDialog(
                        'User Updated',
                        'The user information has been updated successfully.',
                      );
                    }
                    setState(() {
                      isEditing = false;
                      clearFormFields();
                    });
                  } else {
                    String generatedPassword = AuthService()
                        .generateRandomPassword(length: 10);

                    String? result = await healthWorkerProv?.createNewAccount(
                      UserModel(
                        firstname: _firstnameController.text,
                        lastname: _lastnameController.text,
                        email: _emailController.text,
                        address: _addressController.text,
                        licenseNumber: _licenseNumberController.text,
                        role:
                            healthWorkerProv!.role == 'super_admin'
                                ? 'health_worker'
                                : 'parent',
                        createdAt: Timestamp.now(),
                      ),
                      'pass1234',
                    );
                    Navigator.of(context).pop();
                    if (result != 'success') {
                      _showErrorDialog(result ?? 'An error occurred.');
                    } else {
                      _showInfoDialog(
                        'Account Created',
                        'Account created successfully.\n\nTemporary Password: $generatedPassword\n\nPlease inform the user to change their password upon first login.',
                      );
                    }
                  }

                  clearFormFields();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void clearFormFields() {
    _firstnameController.clear();
    _lastnameController.clear();
    _emailController.clear();
    _addressController.clear();
    _licenseNumberController.clear();
  }

  /// Helper: Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  /// Helper: Show info dialog
  void _showInfoDialog(String title, String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
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
          body: Row(
            children: [
              if (Responsive.isDesktop(context)) Expanded(child: DrawerMenu()),
              Expanded(
                flex: 5,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(appPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
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
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
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
                                                user.role == 'health_worker'
                                                    ? 'Health Worker'
                                                    : user.role == 'parent'
                                                    ? 'Parent'
                                                    : 'Relative',
                                                style: TextStyle(
                                                  color:
                                                      user.role ==
                                                              'health_worker'
                                                          ? Colors.green
                                                          : user.role ==
                                                              'parent'
                                                          ? Colors.blue
                                                          : Colors.orange,
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
                                                    onPressed: () {
                                                      isEditing = true;
                                                      _addEditUser(
                                                        existingUser: user,
                                                      );
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      size: 18,
                                                    ),
                                                    color: Colors.red[600],
                                                    onPressed: () {
                                                      _deleteUser(user);
                                                    },
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
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: primaryColor,
            onPressed: () => _addEditUser(),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}
