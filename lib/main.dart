import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_solution/footer/bottom_nav.dart';
import 'package:google_solution/screens/login.dart';
import 'package:google_solution/screens/ngo_home.dart';
import 'package:google_solution/utils/app_theme.dart';
import 'core/Models/agentModel.dart';
import 'core/Models/ngoModel.dart';
import 'core/data/user_local.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase();
  runApp(const MyApp());
}

Future<void> initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _initialScreen = const LoginPage(); // Default to login page

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    dynamic user = await UserLocalStorage.checkUser();

    if (user != null) {
      String email = user.email;

      if (user is NGOModel) {
        setState(() => _initialScreen = NGOHomeScreen(mail: email));
      } else if (user is NGOAgentModel) {
        setState(() => _initialScreen = NGOHomeScreen(mail: email));
      } else {
        setState(() => _initialScreen = BottomNavBar(email: email));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Donations App',
      theme: AppTheme.lightTheme,
      home: _initialScreen,
    );
  }
}