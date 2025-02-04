import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:pizza_app/screen/auth/auth_screen.dart';
import 'package:pizza_app/screen/auth/user_role.dart';
import 'package:pizza_app/screen/sale_app/pizza-home-screen.dart';


class PizzaApp extends StatelessWidget {
  const PizzaApp({super.key});

  @override
  Widget build(BuildContext context) {


    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.grey.shade200,
      statusBarIconBrightness: Brightness.dark,
    ));
    return GetMaterialApp(

      debugShowCheckedModeBanner: false,
      // home: PizzaHomeScreen(),

      home: _buildInitialScreen(),
    );
  }
  /// ✅ Determine the initial screen based on authentication state
  Widget _buildInitialScreen() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return const PizzaHomeScreen();
    } else {
      return const SignInOrSignupScreen();
    }
  }
}
