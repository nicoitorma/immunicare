import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/constants/responsive.dart';
import 'package:immunicare/controllers/auth_viewmodel.dart';
import 'package:immunicare/controllers/relative_viewmodel.dart';
import 'package:immunicare/models/user_model.dart';
import 'package:immunicare/screens/components/dashboard/custom_appbar.dart';
import 'package:immunicare/screens/components/dashboard/drawer_menu.dart';
import 'package:immunicare/screens/parent/components/relative_card.dart';
import 'package:provider/provider.dart';

class AddRelatives extends StatefulWidget {
  const AddRelatives({super.key});

  @override
  State<AddRelatives> createState() => _AddState();
}

class _AddState extends State<AddRelatives> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  String? address;
  UserModel? existingUser;
  RelativeViewModel? relativeViewModel;

  void _addRelative(UserModel existingUser) {
    int randomPin =
        100000 +
        (999999 - 100000) *
            (new DateTime.now().millisecondsSinceEpoch % 100000) ~/
            100000;
    print('Generated PIN: $randomPin');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Add Relative'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _lastnameController,
                  decoration: InputDecoration(
                    labelText: 'Relative Lastame',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter a name'
                              : null,
                ),
                Gap(10),
                TextFormField(
                  controller: _firstnameController,
                  decoration: InputDecoration(
                    labelText: 'Relative Firstname',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter a name'
                              : null,
                ),
                Gap(10),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Relative Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter an email'
                              : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await relativeViewModel?.createNewAccount(
                    existingUser,
                    UserModel(
                      lastname: _lastnameController.text,
                      firstname: _firstnameController.text,
                      address: address ?? '',
                      email: _emailController.text,
                      role: 'relative',
                      createdAt: Timestamp.now(),
                    ),
                    randomPin,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      relativeViewModel = Provider.of<RelativeViewModel>(
        context,
        listen: false,
      );
      existingUser =
          Provider.of<AuthViewModel>(context, listen: false).userdata;
      address =
          Provider.of<AuthViewModel>(context, listen: false).userdata?.address;
      relativeViewModel?.getRelatives();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RelativeViewModel>(
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
                          'Relatives Access',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        if (value.relatives.isEmpty)
                          Expanded(
                            child: Center(
                              child: Text(
                                'No Relatives added. Click the + button to add relatives.',
                                style: Theme.of(context).textTheme.labelLarge,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        Gap(appPadding),
                        if (value.relatives.isNotEmpty)
                          Expanded(
                            child: ListView.builder(
                              itemCount: value.relatives.length,
                              itemBuilder: (context, index) {
                                return RelativeCard(
                                  name:
                                      value.relatives[index].firstname +
                                      ' ' +
                                      value.relatives[index].lastname,
                                  email: value.relatives[index].email,
                                  accessPin:
                                      int.tryParse(
                                        value.relatives[index].pin ?? '0',
                                      )!,
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            backgroundColor: Colors.white,
                                            title: Text(
                                              'Are you sure you want to remove ${value.relatives[index].firstname}?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(context),
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  String result = await value
                                                      .deleteExistingAccount(
                                                        value.relatives[index],
                                                      );
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(result),
                                                    ),
                                                  );
                                                },
                                                child: Text('Confirm'),
                                              ),
                                            ],
                                          ),
                                    );
                                  },
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
          floatingActionButton: FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: primaryColor,
            onPressed: () {
              if (existingUser?.role == 'parent' &&
                  relativeViewModel!.relatives.length >= 2) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You can only add up to 2 relatives.'),
                  ),
                );
                return;
              }
              _addRelative(existingUser!);
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}
