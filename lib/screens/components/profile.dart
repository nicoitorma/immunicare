import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/constants/responsive.dart';
import 'package:immunicare/controllers/auth_viewmodel.dart';
import 'package:immunicare/screens/components/dashboard/custom_appbar.dart';
import 'package:immunicare/screens/components/dashboard/drawer_menu.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? image;
  final ImagePicker imagePicker = ImagePicker();
  bool uploading = false;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstname = TextEditingController();
  final TextEditingController _lastname = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPasswordField = TextEditingController();

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<AuthViewModel>(context, listen: false);
    if (provider.userdata != null) {
      _firstname.text = provider.userdata?.firstname ?? '';
      _lastname.text = provider.userdata?.lastname ?? '';
      _address.text = provider.userdata?.address ?? '';
    }
  }

  @override
  void dispose() {
    _firstname.dispose();
    _lastname.dispose();
    _address.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter.';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number.';
    }
    return null;
  }

  void selectImage() async {
    final img = await imagePicker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      final provider = Provider.of<AuthViewModel>(context, listen: false);
      provider.uploadProfilePhoto(image ?? File(''));
      setState(() {
        image = File(img.path);
      });
    }
  }

  void savePersonalInfo() {
    final provider = Provider.of<AuthViewModel>(context, listen: false);
    provider.updatePersonalInfo(
      _firstname.text.trim(),
      _lastname.text.trim(),
      _address.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget _fname() {
      return TextFormField(
        enabled: _isEditing,
        controller: _firstname,
        decoration: InputDecoration(
          labelText: 'Firstname',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.person),
          prefixIconColor: primaryColor,
        ),
      );
    }

    Widget _lname() {
      return TextFormField(
        controller: _lastname,
        enabled: _isEditing,
        decoration: InputDecoration(
          labelText: 'Lastname',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.person),
          prefixIconColor: primaryColor,
        ),
      );
    }

    Widget _passwordField() {
      return TextFormField(
        controller: _password,
        enabled: _isEditing,
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Password',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.lock),
          prefixIconColor: primaryColor,
        ),
        validator: _validatePassword,
      );
    }

    Widget _confirmPassword() {
      return TextFormField(
        controller: _confirmPasswordField,
        enabled: _isEditing,
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Confirm Password',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.lock),
          prefixIconColor: primaryColor,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please confirm your password.';
          }
          if (value != _password.text) {
            return 'Passwords do not match.';
          }
          return null;
        },
      );
    }

    Widget _nameRow() {
      return Row(
        children: [
          Expanded(child: _fname()),
          const Gap(appPadding),
          Expanded(child: _lname()),
        ],
      );
    }

    Widget _passwordRow() {
      return Row(
        children: [
          Expanded(child: _passwordField()),
          Gap(appPadding),
          Expanded(child: _confirmPassword()),
        ],
      );
    }

    return Consumer<AuthViewModel>(
      builder:
          (context, value, child) => Scaffold(
            drawer: const DrawerMenu(),
            body: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (Responsive.isDesktop(context))
                    const Expanded(child: DrawerMenu()),
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(appPadding),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CustomAppbar(),
                            const Gap(appPadding),
                            Text(
                              'Profile',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Gap(appPadding),
                            // Stack(
                            //   alignment: Alignment.center,
                            //   children: [
                            //     Consumer<AuthViewModel>(
                            //       builder: (context, value, child) {
                            //         return UserAvatar(auth: value.auth);
                            //       },
                            //     ),
                            //     if (image != null)
                            //       CircleAvatar(
                            //         foregroundColor: Colors.white,
                            //         backgroundImage: FileImage(image!),
                            //         radius: 64,
                            //       ),
                            //     Positioned(
                            //       bottom: 0,
                            //       right: 10,
                            //       child: IconButton(
                            //         color: primaryColor,
                            //         onPressed: () => selectImage(),
                            //         icon: const Icon(Icons.add_a_photo),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            const Gap(appPadding),
                            if (Responsive.isDesktop(context)) _nameRow(),
                            if (Responsive.isMobile(context)) _fname(),
                            const Gap(appPadding),
                            if (Responsive.isMobile(context)) _lname(),
                            if (Responsive.isMobile(context))
                              const Gap(appPadding),
                            DropdownMenu<String>(
                              enabled: _isEditing,
                              width: double.infinity,
                              controller: _address,
                              leadingIcon: const Icon(
                                Icons.location_on,
                                color: primaryColor,
                              ),
                              inputDecorationTheme: InputDecorationTheme(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              dropdownMenuEntries:
                                  barangays.map<DropdownMenuEntry<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuEntry<String>(
                                      value: value,
                                      label: value,
                                    );
                                  }).toList(),
                            ),
                            const Gap(appPadding),
                            TextFormField(
                              initialValue: value.currentUser?.email,
                              readOnly: true,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.email),
                                prefixIconColor: primaryColor,
                              ),
                            ),
                            Gap(appPadding),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  if (Responsive.isDesktop(context))
                                    _passwordRow(),
                                  if (Responsive.isMobile(context))
                                    _passwordField(),
                                  Gap(appPadding),
                                  if (Responsive.isMobile(context))
                                    _confirmPassword(),
                                ],
                              ),
                            ),
                            const Gap(appPadding),
                            Row(
                              children: [
                                SizedBox(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isEditing = !_isEditing;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                    child:
                                        _isEditing
                                            ? Text('Cancel')
                                            : const Text('Edit'),
                                  ),
                                ),
                                const Gap(appPadding),
                                SizedBox(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      savePersonalInfo();
                                      if (_formKey.currentState!.validate()) {
                                        if (_password.text.trim().length > 0) {
                                          value.auth.currentUser!
                                              .updatePassword(
                                                _confirmPasswordField.text,
                                              );
                                        }
                                        setState(() {
                                          _isEditing = false;
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Save'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
