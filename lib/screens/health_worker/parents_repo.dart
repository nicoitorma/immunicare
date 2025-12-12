import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/constants/responsive.dart';
import 'package:immunicare/controllers/child_viewmodel.dart';
import 'package:immunicare/models/user_model.dart';
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
  int _expandedIndex = -1;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ChildViewModel>(context, listen: false);
    provider.getAllParents();
  }

  Widget buildParentCard(
    UserModel parent,
    int index,
    ChildViewModel viewModel,
  ) {
    final initials =
        parent.firstname[0].toUpperCase() + parent.lastname[0].toUpperCase();

    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedIndex = _expandedIndex == index ? -1 : index;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
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
                  Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parent.firstname + ' ' + parent.lastname,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 2),
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
                  Icon(
                    _expandedIndex == index
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),

          if (_expandedIndex == index) buildRelativeSection(parent, viewModel),
        ],
      ),
    );
  }

  Widget buildRelativeSection(UserModel parent, ChildViewModel viewModel) {
    return FutureBuilder(
      future: viewModel.fetchRelatives(parent.relatives ?? []),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(12),
            child: Text("No relatives added"),
          );
        }

        final list = snapshot.data!;

        return Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Relatives", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...list.map((r) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 18, color: Colors.orange),
                      Gap(6),
                      Text("${r['firstname']} ${r['lastname']}"),
                      Gap(10),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.orange[100],
                        ),

                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        child: Text(
                          '${r['role'][0].toUpperCase()}${r['role'].substring(1)}',
                          style: TextStyle(color: Colors.orange[900]),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              Gap(10),
              TextButton(
                onPressed:
                    () => Navigator.pushNamed(
                      context,
                      '/children_list',
                      arguments: parent,
                    ),
                child: Text('View Details'),
              ),
            ],
          ),
        );
      },
    );
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
                          Column(
                            children: List.generate(
                              value.filteredParents.isNotEmpty
                                  ? value.filteredParents.length
                                  : value.parents.length,
                              (index) {
                                final parent =
                                    value.filteredParents.isNotEmpty
                                        ? value.filteredParents[index]
                                        : value.parents[index];

                                return buildParentCard(parent, index, value);
                              },
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
