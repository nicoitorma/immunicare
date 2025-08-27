import 'package:flutter/material.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/controllers/auth_viewmodel.dart';
import 'package:immunicare/screens/components/dashboard/drawer_list_tile.dart';
import 'package:provider/provider.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
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
            tap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          DrawerListTile(
            title: 'Vaccination Records',
            svgSrc: 'assets/icons/syringe.svg',
            tap: () => Navigator.pushNamed(context, '/records'),
          ),
          DrawerListTile(
            title: 'Educational Resources',
            svgSrc: 'assets/icons/BlogPost.svg',
            tap: () {},
          ),
          DrawerListTile(
            title: 'Statistics',
            svgSrc: 'assets/icons/Statistics.svg',
            tap: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: appPadding * 2),
            child: Divider(color: grey, thickness: 0.2),
          ),

          DrawerListTile(
            title: 'Settings',
            svgSrc: 'assets/icons/Setting.svg',
            tap: () {},
          ),
          DrawerListTile(
            title: 'Logout',
            svgSrc: 'assets/icons/Logout.svg',
            tap: () => authViewModel.signOut(),
          ),
        ],
      ),
    );
  }
}
