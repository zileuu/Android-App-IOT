import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../controller/cart_controller.dart';

class MyOrdersScreen extends StatelessWidget {
  MyOrdersScreen({super.key});

  final CartController cartController = Get.find<CartController>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    cartController.loadOrders(); // ✅ Ensure orders are loaded on screen open

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("My Orders", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (cartController.isLoading.value) {
          return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: _buildShimmerLoader());
        }

        final user = _auth.currentUser;
        if (user == null) {
          return const Center(
              child: Text("Please log in to see your orders.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
        }

        // ✅ Filter orders by the logged-in user's email
        final userOrders = cartController.orders
            .where((order) => order['userEmail'] == user.email)
            .toList();

        if (userOrders.isEmpty) {
          return const Center(
              child: Text("No orders found.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
        }

        return RefreshIndicator(
          onRefresh: () async => cartController.loadOrders(),
          child: ListView.builder(
            itemCount: userOrders.length,
            itemBuilder: (context, index) {
              var order = userOrders[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🔥 **Order Header with Status**
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Order ID: ${order['orderID']}",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                          Chip(
                            label: Text(
                              order['status'] ?? "Pending",
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor:
                                _getStatusColor(order['status'] ?? "Pending"),
                          ),
                        ],
                      ),

                      Text(
                        "Total: ${order['totalPrice']} \$",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Date: ${order['date']}",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      const SizedBox(height: 8),

                      /// 🔥 **Item Names Together**
                      const Text("Items:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),

                      if (order['cartItems'] != null && order['cartItems'] is Map)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var item in order['cartItems'].values)
                              Text(
                                "${item['name']} x${item['quantity']} - \$${(item['totalItemPrice'] ?? 0.0).toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                              ),
                          ],
                        ),


                      /// 🔥 **Combined Extras & Beverages**
                      const SizedBox(height: 8),
                      if (order['cartItems'] != null &&
                          order['cartItems'] is Map)
                        _buildExtrasAndBeverages(order['cartItems']),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  /// ✅ **Combine & Count Extras & Beverages with Prices**
  Widget _buildExtrasAndBeverages(Map<String, dynamic> cartItems) {
    Map<String, Map<String, dynamic>> extrasCount = {};
    Map<String, Map<String, dynamic>> beveragesCount = {};

    for (var item in cartItems.values) {
      if (item['extras'] != null && item['extras'] is Map) {
        for (var extra in item['extras'].values) {
          String name = extra['name'];
          int quantity = (extra['quantity'] as num).toInt();
          double price = (extra['price'] ?? 0.0) * quantity; // ✅ Calculate total price

          if (extrasCount.containsKey(name)) {
            extrasCount[name]!['quantity'] += quantity;
            extrasCount[name]!['price'] += price;
          } else {
            extrasCount[name] = {'quantity': quantity, 'price': price};
          }
        }
      }
      if (item['beverages'] != null && item['beverages'] is Map) {
        for (var beverage in item['beverages'].values) {
          String name = beverage['name'];
          int quantity = (beverage['quantity'] as num).toInt();
          double price = (beverage['price'] ?? 0.0) * quantity; // ✅ Calculate total price

          if (beveragesCount.containsKey(name)) {
            beveragesCount[name]!['quantity'] += quantity;
            beveragesCount[name]!['price'] += price;
          } else {
            beveragesCount[name] = {'quantity': quantity, 'price': price};
          }
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (extrasCount.isNotEmpty) ...[
          const Text("Extra Material:",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
          for (var entry in extrasCount.entries)
            Text(
              "${entry.key} x${entry.value['quantity']} - \$${entry.value['price'].toStringAsFixed(2)}",
              style:  TextStyle(color: Colors.grey.shade800),
            ),
        ],
        if (beveragesCount.isNotEmpty) ...[
          const SizedBox(height: 4),
          const Text("Beverages:",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
          for (var entry in beveragesCount.entries)
            Text(
              "${entry.key} x${entry.value['quantity']} - \$${entry.value['price'].toStringAsFixed(2)}",
              style: TextStyle(color: Colors.grey.shade800),
            ),
        ],
      ],
    );
  }


  /// ✅ **Shimmer Loader**
  Widget _buildShimmerLoader() {
    return ListView.builder(
      itemCount: 3, // ✅ Show 3 loading placeholders
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 12,
                          color: Colors.red,
                          margin: const EdgeInsets.only(bottom: 8),
                        ),
                        Container(
                          width: 150,
                          height: 12,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ✅ **Get Status Color**
  Color _getStatusColor(String? status) {
    switch (status) {
      case "Accepted":
        return Colors.orange;
      case "Ongoing":
        return Colors.blue;
      case "Ready to Pick":
        return Colors.green;
      case "Delivered":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
