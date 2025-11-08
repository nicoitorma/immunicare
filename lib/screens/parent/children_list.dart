import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:immunicare/controllers/auth_viewmodel.dart';
import 'package:immunicare/controllers/child_viewmodel.dart';
import 'package:immunicare/screens/parent/add_child_dialog.dart';
import 'package:immunicare/screens/parent/components/child_profile_card.dart';
import 'package:immunicare/screens/parent/components/schedule_list.dart';
import 'package:immunicare/screens/parent/components/schedule_section.dart';
import 'package:immunicare/screens/parent/components/upcoming_vaccination_card.dart';
import 'package:provider/provider.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/constants/responsive.dart';
import 'package:immunicare/screens/components/dashboard/custom_appbar.dart';
import 'package:immunicare/screens/components/dashboard/drawer_menu.dart';

class ChildrenList extends StatefulWidget {
  const ChildrenList({super.key});

  @override
  State<ChildrenList> createState() => _ChildrenListState();
}

class _ChildrenListState extends State<ChildrenList> {
  bool _isScheduleExpanded = false;
  String? role;

  void _showAddChildDialog(BuildContext context, ChildViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return addChildDialog(context, viewModel);
      },
    );
  }

  void _showRescheduleDialog(
    BuildContext context,
    ChildViewModel viewModel,
    String vaccineName,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      viewModel.updateVaccineDate(
        viewModel.parentUid,
        viewModel.child!,
        vaccineName,
        picked,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ChildViewModel>(context, listen: false);
    final authProv = Provider.of<AuthViewModel>(context, listen: false);
    provider.getChildrenByParentId(authProv.currentUser?.uid ?? '');

    role = authProv.role;
    if (role == 'relative') {
      provider.getChildrenByParentId(authProv.userdata?.parentId ?? '');
    } else {
      provider.getChildrenByParentId(provider.parentUid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChildViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: bgColor,
          drawer: const DrawerMenu(),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(appPadding),
              child: Responsive(
                mobile: _MobileLayout(
                  viewModel: viewModel,
                  isExpanded: _isScheduleExpanded,
                  onExpand:
                      () => setState(
                        () => _isScheduleExpanded = !_isScheduleExpanded,
                      ),
                  onReschedule:
                      (vaccineName) => _showRescheduleDialog(
                        context,
                        viewModel,
                        vaccineName,
                      ),
                ),
                desktop: Row(
                  children: [
                    const DrawerMenu(),
                    Expanded(
                      child: _DesktopLayout(
                        viewModel: viewModel,
                        isExpanded: _isScheduleExpanded,
                        onExpand:
                            () => setState(
                              () => _isScheduleExpanded = !_isScheduleExpanded,
                            ),
                        onReschedule:
                            (vaccineName) => _showRescheduleDialog(
                              context,
                              viewModel,
                              vaccineName,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton:
              role == 'parent'
                  ? FloatingActionButton(
                    shape: const CircleBorder(),
                    backgroundColor: primaryColor,
                    onPressed: () => _showAddChildDialog(context, viewModel),
                    child: const Icon(Icons.add, color: Colors.white),
                  )
                  : null,
        );
      },
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final ChildViewModel viewModel;
  final bool isExpanded;
  final VoidCallback onExpand;
  final Function(String) onReschedule;

  const _MobileLayout({
    required this.viewModel,
    required this.isExpanded,
    required this.onExpand,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CustomAppbar(),
            const Gap(10),
            if (viewModel.children.isNotEmpty)
              _buildLayout(context)
            else
              const Center(
                child: Text('No children found. Add a child to get started.'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayout(BuildContext context) {
    return Column(
      children: [
        ChildProfileCard(viewModel: viewModel),
        const Gap(24),
        UpcomingVaccinationCard(viewModel: viewModel),
        const Gap(24),
        ScheduleSection(isExpanded: isExpanded, onTap: onExpand),
        const Gap(16),
        ScheduleList(
          viewModel: viewModel,
          isExpanded: isExpanded,
          onReschedule: onReschedule,
        ),
      ],
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final ChildViewModel viewModel;
  final bool isExpanded;
  final VoidCallback onExpand;
  final Function(String) onReschedule;

  const _DesktopLayout({
    required this.viewModel,
    required this.isExpanded,
    required this.onExpand,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CustomAppbar(),
          const Gap(24),
          if (viewModel.child != null)
            _buildLayout(context)
          else
            const Expanded(
              child: Center(
                child: Text('No children found. Add a child to get started.'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLayout(BuildContext context) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ChildProfileCard(viewModel: viewModel),
                  const Gap(24),
                  UpcomingVaccinationCard(viewModel: viewModel),
                ],
              ),
            ),
          ),
          const Gap(24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ScheduleSection(isExpanded: isExpanded, onTap: onExpand),
                  const Gap(16),
                  ScheduleList(
                    viewModel: viewModel,
                    isExpanded: isExpanded,
                    onReschedule: onReschedule,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
