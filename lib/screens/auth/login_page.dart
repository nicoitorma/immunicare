import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:immunicare/constants/responsive.dart';
import 'package:immunicare/controllers/auth_viewmodel.dart';
import 'package:immunicare/models/user_model.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthViewModel? authViewModel;

  @override
  void initState() {
    super.initState();

    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Future<String?>? _authUser(LoginData data) async {
  //   if (_formKey.currentState!.validate()) {
  //     authViewModel?.signIn(
  //       email: _emailController.text,
  //       password: _passwordController.text,
  //     );
  //   }
  // }

  // Future<String?> _signupUser(SignupData data) {
  //   debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
  //   return Future.delayed(loginTime).then((_) {
  //     return null;
  //   });
  // }

  // Common login form widget for all screen sizes.
  Widget _loginForm(double width, double iconSize) {
    return MaterialApp(
      color: Colors.blue,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,

        /// Decoration for input fields like email, and password in the sign up
        /// and register page
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),

        /// Decoration for button like sign in, and register in the sign up
        /// and register page
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            textStyle: WidgetStateProperty.all<TextStyle>(
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            padding: WidgetStateProperty.all<EdgeInsets>(
              const EdgeInsets.all(16),
            ),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
            foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
          ),
        ),
      ),
      home: Center(
        child: SignInScreen(
          providers: [EmailAuthProvider()],
          showAuthActionSwitch: false,
          showPasswordVisibilityToggle: true,
          headerBuilder: (context, constraints, shrinkOffset) {
            return Padding(
              padding: const EdgeInsets.only(top: 15),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset("assets/icons/immunicare.png"),
              ),
            );
          },
          actions: [
            AuthStateChangeAction<UserCreated>((context, state) {
              try {
                UserModel newUser = UserModel(
                  id: state.credential.user!.uid,
                  lastname: '',
                  firstname: '',
                  email: state.credential.user?.email ?? '',
                  address: '',
                  role: 'parent',
                  createdAt: Timestamp.fromDate(DateTime.now()),
                );
                authViewModel?.signUp(
                  userCredential: state.credential,
                  user: newUser,
                );
              } catch (e) {
                // Delete authenticated user if user creation fails
                state.credential.user?.delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error during sign up. Please try again.'),
                  ),
                );
              }
            }),
          ],
          subtitleBuilder: (context, action) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                action == AuthAction.signIn
                    ? 'Welcome to Caramoran Immunicare System'
                    : 'Please create an account to continue',
              ),
            );
          },
          sideBuilder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.all(15),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset("assets/icons/immunicare.png"),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Responsive(
          // Mobile view: full width
          mobile: _loginForm(double.infinity, 100),
          // Tablet view: fixed width
          tablet: _loginForm(450, 120),
          // Desktop view: fixed width, larger icon/font
          desktop: _loginForm(400, 150),
        ),
      ),
    );
  }
}
