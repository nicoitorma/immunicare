import 'package:flutter/material.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/controllers/auth_viewmodel.dart';
import 'package:immunicare/screens/components/dashboard/drawer_list_tile.dart';
import 'package:immunicare/screens/health_worker/dashboard_screen.dart';
import 'package:immunicare/screens/parent/dashboard.dart';
import 'package:provider/provider.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, value, child) {
        return Drawer(
          backgroundColor: Colors.white,
          child: ListView(
            children: [
              Container(
                padding: EdgeInsets.all(appPadding),
                child: Text(
                  'ImmuniCare',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DrawerListTile(
                title: 'Dashboard',
                svgSrc: 'assets/icons/Dashboard.svg',
                tap: () {
                  if ((value.role == 'health_worker') ||
                      (value.role == 'super_admin')) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashBoardScreen(),
                      ),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ParentDashboard(),
                      ),
                    );
                  }
                },
              ),
              if (value.role == 'super_admin' || value.role == 'health_worker')
                DrawerListTile(
                  title: 'Registered Parents',
                  svgSrc: 'assets/icons/Subscribers.svg',
                  tap:
                      () => Navigator.of(
                        context,
                      ).pushNamed('/registered_children'),
                ),
              DrawerListTile(
                title: 'Educational Resources',
                svgSrc: 'assets/icons/BlogPost.svg',
                tap:
                    () => Navigator.of(
                      context,
                    ).pushNamed('/educational_resources'),
              ),
              if (value.role == 'parent')
                DrawerListTile(
                  title: 'Add Relatives',
                  svgSrc: 'assets/icons/add_people.svg',
                  tap: () {
                    Navigator.of(context).pushNamed('/add_relatives');
                  },
                ),
              if (value.role == 'super_admin' || value.role == 'health_worker')
                DrawerListTile(
                  title: 'GIS Data',
                  svgSrc: 'assets/icons/maps.svg',
                  tap:
                      () =>
                          Navigator.of(context).pushNamed('/gis_data_overview'),
                ),
              if (value.role == 'super_admin' || value.role == 'health_worker')
                DrawerListTile(
                  title: 'Vaccination Logs',
                  svgSrc: 'assets/icons/BlogPost.svg',
                  tap:
                      () =>
                          Navigator.of(context).pushNamed('/vaccination_logs'),
                ),
              if (value.role == 'super_admin' || value.role == 'health_worker')
                DrawerListTile(
                  title: 'User management',
                  svgSrc: 'assets/icons/Subscribers.svg',
                  tap:
                      () => Navigator.of(context).pushNamed('/user_management'),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: appPadding * 2),
                child: Divider(color: grey, thickness: 0.2),
              ),

              DrawerListTile(
                title: 'Profile',
                svgSrc: 'assets/icons/person.svg',
                tap: () => Navigator.of(context).pushNamed('/profile'),
              ),
              DrawerListTile(
                title: 'Logout',
                svgSrc: 'assets/icons/Logout.svg',
                tap: () {
                  value.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
