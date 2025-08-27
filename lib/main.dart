import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:immunicare/controllers/auth_viewmodel.dart';
import 'package:immunicare/controllers/controller.dart';
import 'package:immunicare/screens/auth/login_page.dart';
import 'package:immunicare/screens/auth/signup_page.dart';
import 'package:immunicare/screens/health_worker/dashboard_screen.dart';
import 'package:immunicare/screens/health_worker/vaccination_records.dart';
import 'package:immunicare/screens/parent/dashboard.dart';
import 'package:immunicare/services/user_services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => Controller()),
      ],
      child: MaterialApp(
        title: 'ImmuniCare',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // Check kung may authenticated user
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasData) {
              final user = snapshot.data!;
              return FutureBuilder<String>(
                future: UserService().getUserRole(user.uid),
                builder: (context, roleSnapshot) {
                  if (roleSnapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  // Check kung may user role
                  final userRole = roleSnapshot.data;
                  if (userRole == 'health_worker') {
                    return const DashBoardScreen();
                  } else {
                    return const ParentDashboard();
                  }
                },
              );
            }

            return const LoginPage();
          },
        ),
        routes: {
          '/signup': (context) => const SignUpPage(),
          '/records': (context) => const VaccinationRecords(),
        },
      ),
    );
  }
}
