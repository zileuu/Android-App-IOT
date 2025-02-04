import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../utils/data_path.dart';
import '../auth/auth_screen.dart';
import '../kitchen_app/kitchen_home_screen.dart';
import 'all_product.dart';
import '../../widget/pizza_card.dart';
import 'my_order_screen.dart';

class PizzaHomeScreen extends StatelessWidget {
  const PizzaHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        elevation: 0,
        title: Text('Pizza Oven',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.red),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Stack(
            children: [
              Row(
                children: [
                  // IconButton(
                  //   icon: Icon(Icons.search, color: Colors.red),
                  //   onPressed: () {},
                  // ),
                  IconButton(
                    icon: Icon(
                      Icons.shopping_cart,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyOrdersScreen()));
                    },
                  ),
                ],
              ),
              // Positioned(
              //   right: 6,
              //   top: 6,
              //   child: CircleAvatar(
              //     radius: 8,
              //     backgroundColor: Colors.red,
              //     child: Text(
              //       '2',
              //       style: TextStyle(color: Colors.white, fontSize: 12),
              //     ),
              //   ),
              // )
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ✅ Circular User Image
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      FirebaseAuth.instance.currentUser?.photoURL ??
                          'https://www.w3schools.com/w3images/avatar2.png', // Default Avatar
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ✅ User Email
                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? "Guest User",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // ListTile(
            //   leading: Icon(Icons.list),
            //   title: Text('Orders'),
            //   onTap: () {
            //     Navigator.push(context,
            //         MaterialPageRoute(builder: (context) => MyOrdersScreen()));
            //   },
            // ),
            // ListTile(
            //   leading: Icon(Icons.list),
            //   title: Text('Admin'),
            //   onTap: () {
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => KitchenHomeScreen()));
            //   },
            // ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoryTitle('Popular Pizzas', popularPizzas),
              SizedBox(height: 8),
              _buildHorizontalScrollView(
                  context, popularPizzas, 'Popular Pizzas'),
              SizedBox(height: 8),
              _buildCategoryTitle('Specialty Pizzas', specialtyPizzas),
              SizedBox(height: 8),
              _buildHorizontalScrollView(
                  context, specialtyPizzas, 'Specialty Pizzas'),
              SizedBox(height: 8),
              _buildCategoryTitle('Vegetarian Pizzas', vegetarianPizzas),
              SizedBox(height: 8),
              _buildHorizontalScrollView(
                  context, vegetarianPizzas, 'Vegetarian Pizzas'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTitle(String title, List<Map<String, dynamic>> pizzas) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.to(
                  () => AllPizzasScreen(pizzas: pizzas, categoryTitle: title));
            },
            child: Text(
              "See All",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHorizontalScrollView(
      BuildContext context, List<Map<String, dynamic>> items, String category) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: PizzaCard(
              pizza: items[index],
              context: context,
              category: category,
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Are you sure you want to logout?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut(); // ✅ Logout from Google
        Get.offAll(() => SignInOrSignupScreen());
      },
    );
  }
}
