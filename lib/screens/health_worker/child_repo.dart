import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/constants/responsive.dart';
import 'package:immunicare/controllers/child_viewmodel.dart';
import 'package:immunicare/screens/components/dashboard/custom_appbar.dart';
import 'package:immunicare/screens/components/dashboard/drawer_menu.dart';
import 'package:immunicare/screens/parent/components/schedule_list.dart';
import 'package:immunicare/screens/parent/components/schedule_section.dart';
import 'package:immunicare/screens/parent/components/upcoming_vaccination_card.dart';
import 'package:provider/provider.dart';

class ChildRepo extends StatefulWidget {
  const ChildRepo({super.key});

  @override
  State<ChildRepo> createState() => _ChildRepoState();
}

class _ChildRepoState extends State<ChildRepo> {
  bool _isScheduleExpanded = false;
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MobileLayout extends StatefulWidget {
  final ChildViewModel viewModel;
  final bool isExpanded;
  final VoidCallback onExpand;
  final Function(String)? onReschedule;

  const _MobileLayout({
    required this.viewModel,
    required this.isExpanded,
    required this.onExpand,
    this.onReschedule,
  });

  @override
  State<_MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<_MobileLayout> {
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
            if (widget.viewModel.child != null)
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

  Widget nameCard(ChildViewModel viewModel) {
    final selectedChild = viewModel.child ?? viewModel.children.first;
    final ageInMonths = viewModel.calculateAgeInMonths(
      selectedChild.dateOfBirth,
    );
    final ageDisplay =
        ageInMonths < 12
            ? '$ageInMonths months'
            : '${(ageInMonths / 12).floor()} years, ${ageInMonths % 12} months';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFBFDBFE),
              borderRadius: BorderRadius.circular(32),
            ),
            alignment: Alignment.center,
            child: Text(
              selectedChild.firstname[0],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D4ED8),
              ),
            ),
          ),
          const Gap(16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${selectedChild.firstname} ${selectedChild.lastname}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                ageDisplay,
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLayout(BuildContext context) {
    return Column(
      children: [
        nameCard(widget.viewModel),
        const Gap(24),
        UpcomingVaccinationCard(viewModel: widget.viewModel),
        const Gap(24),
        ScheduleSection(isExpanded: widget.isExpanded, onTap: widget.onExpand),
        const Gap(16),
        ScheduleList(
          viewModel: widget.viewModel,
          isExpanded: widget.isExpanded,
          onReschedule: widget.onReschedule,
          onMarkComplete: widget.viewModel.markAsComplete,
        ),
      ],
    );
  }
}

class _DesktopLayout extends StatefulWidget {
  final ChildViewModel viewModel;
  final bool isExpanded;
  final VoidCallback onExpand;

  const _DesktopLayout({
    required this.viewModel,
    required this.isExpanded,
    required this.onExpand,
  });

  @override
  State<_DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<_DesktopLayout> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1100,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CustomAppbar(),
          const Gap(24),
          if (widget.viewModel.child != null)
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

  Widget nameCard(ChildViewModel viewModel) {
    final selectedChild = viewModel.child ?? viewModel.children.first;
    final ageInMonths = viewModel.calculateAgeInMonths(
      selectedChild.dateOfBirth,
    );
    final ageDisplay =
        ageInMonths < 12
            ? '$ageInMonths months'
            : '${(ageInMonths / 12).floor()} year/s, ${ageInMonths % 12} months';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFBFDBFE),
              borderRadius: BorderRadius.circular(32),
            ),
            alignment: Alignment.center,
            child: Text(
              selectedChild.firstname[0],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D4ED8),
              ),
            ),
          ),
          const Gap(16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${selectedChild.firstname} ${selectedChild.lastname}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                ageDisplay,
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
            ],
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
                  nameCard(widget.viewModel),
                  const Gap(24),
                  UpcomingVaccinationCard(viewModel: widget.viewModel),
                  // Gap(appPadding),
                  // ElevatedButton(
                  //   onPressed: () {},
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.red,
                  //     foregroundColor: Colors.white,
                  //   ),
                  //   child: Text('Archive child'),
                  // ),
                ],
              ),
            ),
          ),
          const Gap(24),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ScheduleSection(
                    isExpanded: widget.isExpanded,
                    onTap: widget.onExpand,
                  ),
                  const Gap(16),
                  ScheduleList(
                    viewModel: widget.viewModel,
                    isExpanded: widget.isExpanded,
                    onMarkComplete: widget.viewModel.markAsComplete,
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
