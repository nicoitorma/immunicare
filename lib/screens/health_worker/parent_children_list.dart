import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:immunicare/controllers/child_viewmodel.dart';
import 'package:immunicare/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ParentChildrenList extends StatefulWidget {
  const ParentChildrenList({super.key});

  @override
  State<ParentChildrenList> createState() => _ParentChildrenListState();
}

class _ParentChildrenListState extends State<ParentChildrenList> {
  UserModel? parent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is UserModel) {
        setState(() {
          parent = args;
        });
        final provider = Provider.of<ChildViewModel>(context, listen: false);
        provider.getChildrenByParentId(parent!.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChildViewModel>(
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text('${parent?.firstname}\'s Children'),
            backgroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  color: Colors.blue.shade50,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Gap(10),
                      Text(
                        'Parent Personal Information',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(8),
                      ListTile(
                        title: Text(
                          '${parent?.firstname} ${parent?.lastname}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Address: ${parent?.address}, Caramoran\nEmail: ${parent?.email}\nNumber of Children: ${value.children.length}',
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(10),
                if (value.children.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'No children registered for this parent.',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: value.children.length,
                    itemBuilder: (context, index) {
                      final child = value.children[index];
                      final initials =
                          child.firstname.isNotEmpty
                              ? child.firstname[0].toUpperCase() +
                                  child.lastname[0].toUpperCase()
                              : '';
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2.0,
                          horizontal: 8.0,
                        ),
                        child: Card(
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
                            onTap: () {
                              value.getChildById(childId: child.id);
                              Navigator.pushNamed(context, '/child_details');
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                          child.firstname +
                                              ' ' +
                                              child.lastname,
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
                                          'DOB: ${DateFormat('MMMM d, y').format(child.dateOfBirth.toDate())}',
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
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
