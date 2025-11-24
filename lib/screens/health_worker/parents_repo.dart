import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/constants/responsive.dart';
import 'package:immunicare/controllers/child_viewmodel.dart';
import 'package:immunicare/screens/components/dashboard/custom_appbar.dart';
import 'package:immunicare/screens/components/dashboard/drawer_menu.dart';
import 'package:provider/provider.dart';

class ParentsRepo extends StatefulWidget {
  const ParentsRepo({super.key});

  @override
  State<ParentsRepo> createState() => _ParentsRepoState();
}

class _ParentsRepoState extends State<ParentsRepo> {
  String _selectedSortOption = 'name';

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ChildViewModel>(context, listen: false);
    provider.getAllParents();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChildViewModel>(
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
                      padding: EdgeInsets.all(appPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomAppbar(),
                          Gap(appPadding),
                          Text(
                            'Registered Parents',
                            style: Theme.of(context).textTheme.headlineMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Sort by:'),
                              Gap(8),
                              DropdownButton<String>(
                                dropdownColor: Colors.white,
                                value: _selectedSortOption,
                                items: [
                                  DropdownMenuItem(
                                    value: 'name',
                                    child: Text('Name'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'address',
                                    child: Text('Address'),
                                  ),
                                ],
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedSortOption = newValue;
                                      value.sortParents(newValue);
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          Gap(appPadding),
                          if (value.parents.length == 0 &&
                              value.filteredParents.length == 0)
                            Center(
                              child: Text(
                                textAlign: TextAlign.center,
                                'No added Parents. Barangay Health Workers can add parents through User Management.',
                              ),
                            ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount:
                                value.filteredParents.length > 0
                                    ? value.filteredParents.length
                                    : value.parents.length,
                            itemBuilder: (context, index) {
                              final parent =
                                  value.filteredParents.isNotEmpty
                                      ? value.filteredParents[index]
                                      : value.parents[index];

                              final initials =
                                  parent.firstname.isNotEmpty
                                      ? parent.firstname[0].toUpperCase() +
                                          parent.lastname[0].toUpperCase()
                                      : '';
                              return Card(
                                color: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.only(
                                  bottom: 12.0,
                                  left: 4,
                                  right: 4,
                                ),
                                child: InkWell(
                                  onTap:
                                      () => Navigator.pushNamed(
                                        context,
                                        '/children_list',
                                        arguments: parent,
                                      ),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.blue[300],
                                          ),
                                          child: Center(
                                            child: Text(
                                              initials,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const Gap(16),

                                        // Parent Details (Center Section)
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                parent.firstname +
                                                    ' ' +
                                                    parent.lastname,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Color(
                                                    0xFF1F2937,
                                                  ), // gray-900
                                                ),
                                              ),
                                              const Gap(2),
                                              Text(
                                                'Address: ${parent.address}, Caramoran',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
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
