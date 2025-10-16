import 'package:flutter/material.dart';
import 'package:immunicare/constants/constants.dart';
import 'package:immunicare/constants/responsive.dart';
import 'package:immunicare/controllers/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class ProfileInfo extends StatelessWidget {
  const ProfileInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access AuthViewModel to get user info and handle logout
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    return Row(
      children: [
        Container(
          margin: EdgeInsets.only(left: appPadding),
          padding: EdgeInsets.symmetric(vertical: appPadding / 2),
          child: Row(
            children: [
              PopupMenuButton<String>(
                color: Colors.white,
                onSelected: (value) {
                  if (value == 'profile') {
                    // Handle profile click
                    Navigator.pushNamed(context, '/profile');
                  } else if (value == 'logout') {
                    authViewModel.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'profile',
                        child: Text('View Profile'),
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Text('Logout'),
                      ),
                    ],
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        width: 38,
                        height: 38,
                        fit: BoxFit.cover,
                        'https://avatar.iran.liara.run/public',
                        errorBuilder:
                            (context, error, stackTrace) => Icon(
                              Icons.account_circle,
                              size: 38,
                              color: textColor.withValues(alpha: 0.5),
                            ),
                      ),
                      // : Image.network(
                      //   authViewModel.currentUser!.photoURL!,
                      //   width: 38,
                      //   height: 38,
                      //   fit: BoxFit.cover,
                      // ),
                    ),
                    if (!Responsive.isMobile(context))
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: appPadding / 2,
                        ),
                        child: Text(
                          'Welcome ${authViewModel.userdata?.firstname} ${authViewModel.userdata?.lastname}',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
