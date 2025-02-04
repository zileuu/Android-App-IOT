import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../kitchen_app/kitchen_home_screen.dart';
import '../sale_app/pizza-home-screen.dart';

class UserRoleScreen extends StatelessWidget {
  const UserRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const Spacer(flex: 2),
            Image.network(
              MediaQuery.of(context).platformBrightness == Brightness.light
                  ? "https://i.postimg.cc/jqHsJL0v/d.png"
                  : "https://i.postimg.cc/jqHsJL0v/d.png",
              height: 186,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Get.offAll(() => PizzaHomeScreen());
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF00BF6D),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: const StadiumBorder(),
              ),
              child: const Text("Sale App"),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Get.offAll(() => KitchenHomeScreen());
              },
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: const StadiumBorder(),
                  backgroundColor: const Color(0xFFFE9901)),
              child: const Text("Kitchen App"),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
