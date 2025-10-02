import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:immunicare/constants/constants.dart';

class EducationalHub extends StatefulWidget {
  const EducationalHub({super.key});

  @override
  State<EducationalHub> createState() => _EducationalHubState();
}

class _EducationalHubState extends State<EducationalHub> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.info, color: Colors.blue),
            title: Text(
              'Educational Hub',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Access a variety of educational resources about vaccinations, health tips, and more to keep your family informed and healthy.',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Divider(),
          Gap(appPadding),
        ],
      ),
    );
  }
}
