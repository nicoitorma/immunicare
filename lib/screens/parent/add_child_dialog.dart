import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/controllers/child_viewmodel.dart';

Widget addChildDialog(BuildContext context, ChildViewModel value) {
  final lastnameController = TextEditingController();
  final firstnameController = TextEditingController();
  final dobController = TextEditingController();
  DateTime? selectedDate;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1800),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      selectedDate = picked;
      dobController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  return Dialog(
    backgroundColor: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Child', style: Theme.of(context).textTheme.headlineSmall),
          Gap(appPadding),
          TextFormField(
            controller: lastnameController,
            decoration: InputDecoration(
              labelText: 'Last name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Gap(10),
          TextFormField(
            controller: firstnameController,
            decoration: InputDecoration(
              labelText: 'First Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const Gap(10),
          TextFormField(
            controller: dobController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Date of Birth',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            onTap: _pickDate,
          ),
          const Gap(20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              if (firstnameController.text.isNotEmpty && selectedDate != null) {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid != null) {
                  value.addChild(
                    uid,
                    lastnameController.text,
                    firstnameController.text,
                    selectedDate!,
                  );
                }
                Navigator.of(context).pop();
              }
            },
            child: const Text(
              'Add Child',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}
