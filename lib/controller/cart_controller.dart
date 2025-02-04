import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var cartItems = <Map<String, dynamic>>[].obs;
  var orders = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance; // ✅ Firebase Auth
  /// ✅ **Load Orders & Sync Changes in Real-Time**
  Future<void> loadOrders() async {
    isLoading.value = true;
    try {
      _firestore
          .collection('orders')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        orders.value = snapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).toList();
      });
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to load orders",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ **Delete Order from Firestore**
  Future<void> deleteOrder(String orderID) async {
    try {
      await _firestore.collection('orders').doc(orderID).delete();
      orders.removeWhere((order) => order['orderID'] == orderID);
      Get.snackbar(
        "Deleted",
        "Order $orderID has been removed!",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to delete order",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void addToCart(Map<String, dynamic> item) {
    cartItems.add(item);
  }

  void removeFromCart(int index) {
    cartItems.removeAt(index);
  }

  void clearCart() {
    cartItems.clear();
  }

  double getTotalPrice() {
    return cartItems.fold(0.0, (sum, item) => sum + (item['totalPrice'] ?? 0));
  }

  /// ✅ **Generate Order ID (`Pizza-01`, `Pizza-02`, ...)**
  Future<String> generateOrderID() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .orderBy('timestamp', descending: true)
          .get();

      int orderNumber = snapshot.docs.isNotEmpty
          ? int.parse(snapshot.docs.first['orderID'].split('-')[1]) + 1
          : 1;

      return 'Pizza-${orderNumber.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Pizza-01';
    }
  }

  Future<void> addToMyOrders(Map<String, dynamic> order) async {
    String orderID = await generateOrderID();
    order['orderID'] = orderID;
    order['date'] = DateTime.now().toString();
    order['timestamp'] = FieldValue.serverTimestamp();
    order['status'] = "Pending"; // ✅ Default order status

    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        order['userName'] = userDoc['userName'] ?? "Unknown";
      } else {
        order['userName'] = "Unknown"; // ফায়ারস্টোর-এ না থাকলে ডিফল্ট মান
      }
      order['userEmail'] = user.email;
    } else {
      order['userName'] = "Guest";
      order['userEmail'] = "guest@example.com";
    }

    Map<String, dynamic> cartItemsMap = {};
    double totalOrderPrice = 0.0;

    for (int i = 0; i < cartItems.length; i++) {
      Map<String, dynamic> item = Map.from(cartItems[i]);

      double itemPrice = item['itemPrice'] ?? 0.0; // ✅ Price of one pizza
      int quantity = item['quantity'] ?? 1;
      double totalItemPrice =
          itemPrice * quantity; // ✅ Total price for this pizza

      // ✅ Use extras pricing that was passed from `PizzaDetailScreen`
      double extrasTotalPrice = 0.0;
      if (item.containsKey('extras') && item['extras'] is List) {
        Map<String, dynamic> extrasMap = {};
        for (int j = 0; j < item['extras'].length; j++) {
          Map<String, dynamic> extra = item['extras'][j];
          double extraPrice = extra['price'] ?? 0.0;
          int extraQuantity = extra['quantity'] ?? 1;
          double extraTotal = extraPrice * extraQuantity;
          extrasTotalPrice += extraTotal;

          extrasMap["extra_${j + 1}"] = {
            "name": extra['name'],
            "quantity": extraQuantity,
            "price": extraPrice,
            "totalPrice": extraTotal
          };
        }
        item['extras'] = extrasMap;
        item['extrasTotalPrice'] = extrasTotalPrice;
      }

      // ✅ Use beverages pricing that was passed from `PizzaDetailScreen`
      double beveragesTotalPrice = 0.0;
      if (item.containsKey('beverages') && item['beverages'] is List) {
        Map<String, dynamic> beveragesMap = {};
        for (int j = 0; j < item['beverages'].length; j++) {
          Map<String, dynamic> beverage = item['beverages'][j];
          double beveragePrice = beverage['price'] ?? 0.0;
          int beverageQuantity = beverage['quantity'] ?? 1;
          double beverageTotal = beveragePrice * beverageQuantity;
          beveragesTotalPrice += beverageTotal;

          beveragesMap["beverage_${j + 1}"] = {
            "name": beverage['name'],
            "quantity": beverageQuantity,
            "price": beveragePrice,
            "totalPrice": beverageTotal
          };
        }
        item['beverages'] = beveragesMap;
        item['beveragesTotalPrice'] = beveragesTotalPrice;
      }

      // ✅ Calculate final total price for this item (pizza + extras + beverages)
      double finalTotalPrice =
          totalItemPrice + extrasTotalPrice + beveragesTotalPrice;
      item['totalItemPrice'] = totalItemPrice;
      item['finalTotalPrice'] = finalTotalPrice;

      cartItemsMap["item_${i + 1}"] = item;
      totalOrderPrice += finalTotalPrice;
    }

    order['cartItems'] = cartItemsMap;
    order['totalOrderPrice'] = totalOrderPrice;

    try {
      await _firestore.collection('orders').doc(orderID).set(order);
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to save order to Firestore",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// ✅ **Update Order Status (Kitchen Updates)**
  Future<void> updateOrderStatus(String orderID, String newStatus) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderID)
          .update({'status': newStatus});
      int index = orders.indexWhere((order) => order['orderID'] == orderID);
      if (index != -1) {
        orders[index]['status'] = newStatus;
        orders.refresh();
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update order status",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// ✅ **Increment/Decrement Item Quantity (Extras & Beverages)**
  void updateItemQuantity(int cartIndex, String type, String action) {
    var item = cartItems[cartIndex];

    if (type == 'extras' && item['extras'] != null) {
      _updateList(item, 'extras', action);
    } else if (type == 'beverages' && item['beverages'] != null) {
      _updateList(item, 'beverages', action);
    }

    update();
  }

  void _updateList(Map<String, dynamic> item, String key, String action) {
    if (action == 'increment') {
      item[key].add('$key ${item[key].length + 1}');
    } else if (action == 'decrement' && item[key].isNotEmpty) {
      item[key].removeLast();
    }
  }
}
