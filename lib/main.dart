import 'package:ffrm/features/home/home_screen.dart';
import 'package:ffrm/features/login/login_screen.dart';
import 'package:ffrm/features/password/password_screen.dart';
import 'package:ffrm/features/profile/profile_screen.dart';
import 'package:ffrm/features/register/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await dotenv.load(fileName: ".env");

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? accessToken = prefs.getString('accessToken');
  final String? refreshToken = prefs.getString('refreshToken');
  final initialRoute = (accessToken == null ||
          accessToken.isEmpty ||
          refreshToken == null ||
          refreshToken.isEmpty)
      ? '/login'
      : '/home';

  runApp(GetMaterialApp(
    title: 'FFRM',
    theme: ThemeData(primarySwatch: Colors.green),
    initialRoute: initialRoute,
    routes: {
      '/login': (context) => const LoginScreen(),
      '/register': (context) => const RegisterScreen(),
      '/home': (context) => const HomeScreen(),
      '/profile': (context) => const ProfileScreen(),
      '/password': (context) => const PasswordScreen(),
    },
  ));

  FlutterNativeSplash.remove();
}
