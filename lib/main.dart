import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:immunicare/controllers/auth_viewmodel.dart';
import 'package:immunicare/controllers/child_viewmodel.dart';
import 'package:immunicare/controllers/health_worker/educ_res_viewmodel.dart';
import 'package:immunicare/controllers/controller.dart';
import 'package:immunicare/controllers/health_worker/health_worker_viewmodel.dart';
import 'package:immunicare/controllers/relative_viewmodel.dart';
import 'package:immunicare/screens/auth/login_page.dart';
import 'package:immunicare/screens/auth/signup_page.dart';
import 'package:immunicare/screens/components/profile.dart';
import 'package:immunicare/screens/health_worker/child_repo.dart';
import 'package:immunicare/screens/health_worker/educational_resources.dart';
import 'package:immunicare/screens/health_worker/gis_mapping.dart';
import 'package:immunicare/screens/health_worker/health_workers.dart';
import 'package:immunicare/screens/health_worker/parent_children_list.dart';
import 'package:immunicare/screens/health_worker/parents_repo.dart';
import 'package:immunicare/screens/health_worker/dashboard_screen.dart';
import 'package:immunicare/screens/health_worker/scheduled.dart';
import 'package:immunicare/screens/health_worker/vaccination_logs.dart';
import 'package:immunicare/screens/parent/add_relatives.dart';
import 'package:immunicare/screens/parent/children_list.dart';
import 'package:immunicare/screens/parent/dashboard.dart';
import 'package:immunicare/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 1. Declare the plugin instance
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    // _initializeNotifications(); // Call the async setup function
  }

  // Future<void> _initializeNotifications() async {
  //   const AndroidInitializationSettings initializationSettingsAndroid =
  //       AndroidInitializationSettings('@mipmap/ic_launcher');

  //   final InitializationSettings initializationSettings =
  //       InitializationSettings(android: initializationSettingsAndroid);

  //   await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  //   // Request notification permissions for Android 13+
  //   await flutterLocalNotificationsPlugin
  //       .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin
  //       >()
  //       ?.requestPermission();
  // }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => Controller()),
        ChangeNotifierProvider(create: (context) => ChildViewModel()),
        ChangeNotifierProvider(create: (context) => EducResViewmodel()),
        ChangeNotifierProvider(create: (context) => HealthWorkerViewmodel()),
        ChangeNotifierProvider(create: (context) => RelativeViewModel()),
      ],
      child: MaterialApp(
        title: 'ImmuniCare',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Poppins',
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasData && snapshot.data != null) {
              final user = snapshot.data!;
              final provider = Provider.of<AuthViewModel>(
                context,
                listen: false,
              );
              provider.fetchUserRole(user.uid);
              return Consumer<AuthViewModel>(
                builder: (context, value, _) {
                  if (value.role == '') {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (value.role == 'null') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User not found.')),
                    );
                  }

                  // Once the role is not loading, render the appropriate screen.
                  final userRole = value.role;
                  if (userRole == 'health_worker' ||
                      userRole == 'super_admin') {
                    return const DashBoardScreen();
                  } else {
                    return const ParentDashboard();
                  }
                },
              );
            }
            return LoginPage();
          },
        ),
        routes: {
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignUpPage(),
          '/children': (context) => const ChildrenList(),
          '/registered_children': (context) => const ParentsRepo(),
          '/child_details': (context) => ChildRepo(),
          '/scheduled': (context) => Scheduled(),
          '/educational_resources': (context) => EducationalResources(),
          '/user_management': (context) => HealthWorkers(),
          '/profile': (context) => Profile(),
          '/add_relatives': (context) => const AddRelatives(),
          '/parentDashboard': (context) => const ParentDashboard(),
          '/healthWorkerDashboard': (context) => const DashBoardScreen(),
          '/gis_data_overview': (context) => const GisMapping(),
          '/children_list': (context) => const ParentChildrenList(),
          '/vaccination_logs': (context) => VaccinationLogs(),
        },
      ),
    );
  }
}
