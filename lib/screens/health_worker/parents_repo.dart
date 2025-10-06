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
                        children: [
                          CustomAppbar(),
                          Gap(appPadding),
                          Text(
                            'Children Registered',
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
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _ParentChildrenExpansionTile(
                                  parent: parent,
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

class _ParentChildrenExpansionTile extends StatefulWidget {
  final UserModel parent;
  const _ParentChildrenExpansionTile({required this.parent});

  @override
  State<_ParentChildrenExpansionTile> createState() =>
      _ParentChildrenExpansionTileState();
}

class _ParentChildrenExpansionTileState
    extends State<_ParentChildrenExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(10),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(10),
      ),
      collapsedBackgroundColor: const Color.fromARGB(179, 195, 218, 238),
      title: Text(
        '${widget.parent.firstname} ${widget.parent.lastname}',
        style: TextStyle(color: Colors.black),
      ),
      subtitle:
          widget.parent.address != ''
              ? Text(
                '${widget.parent.address}, Caramoran',
                style: TextStyle(color: Colors.black),
              )
              : null,
      textColor: Colors.black,
      onExpansionChanged: (isExpanded) {
        setState(() {
          _isExpanded = isExpanded;
        });
        if (isExpanded) {
          Provider.of<ChildViewModel>(
            context,
            listen: false,
          ).getChildrenByParentId(widget.parent.id ?? '');
        }
      },
      children: [
        if (_isExpanded)
          Consumer<ChildViewModel>(
            builder: (context, childViewModel, _) {
              // Retrieve the specific list of children for *this* parent ID
              final children = childViewModel.getChildrenForParent(
                widget.parent.id ?? '',
              );

              if (children.isEmpty) {
                // Check for null or empty list. You might want to also check for a loading state.
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No children found for this parent.'),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: children.length, // Use the specific children list
                itemBuilder: (context, index) {
                  final child = children[index];
                  return Card(
                    color: Color.fromARGB(179, 195, 218, 238),
                    child: ListTile(
                      title: Text('${child.firstname} ${child.lastname}'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Ensure your view model method can use the child's data even if it's from the map
                        childViewModel.getChildById(childId: child.id);
                        Navigator.pushNamed(context, '/child_details');
                      },
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}
