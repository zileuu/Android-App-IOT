import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_app/widget/custom_elevated_button.dart';

import '../../controller/cart_controller.dart';
import 'add_to_cart_screen.dart';

class PizzaDetailScreen extends StatefulWidget {
  final Map<String, dynamic> pizza;
  final String categoryName;

  const PizzaDetailScreen(
      {super.key, required this.pizza, required this.categoryName});

  @override
  _PizzaDetailScreenState createState() => _PizzaDetailScreenState();
}

class _PizzaDetailScreenState extends State<PizzaDetailScreen> {
  int quantity = 1;
  double basePrice = 0.0;
  double totalPrice = 0.0;

  Map<String, double> extraMaterials = {
    'Sausage': 2,
    'Tomato': 1.5,
    'Cheddar': 1.5,
    'Braised': 3.5,
    'Pepper': 1.5,
  };

  Map<String, double> beverages = {
    'Fanta': 2.5,
    'Sprite': 3.5,
    'Pepsi': 2.5,
    'Water': 1.5,
  };

  Map<String, int> selectedExtras = {};
  Map<String, int> selectedBeverages = {};

  @override
  void initState() {
    super.initState();
    basePrice = widget.pizza['price'];
    updateTotalPrice();
  }

  void updateTotalPrice() {
    double extrasTotal = selectedExtras.entries.fold(0.0,
        (sum, entry) => sum + (extraMaterials[entry.key] ?? 0) * entry.value);
    double beverageTotal = selectedBeverages.entries.fold(
        0.0, (sum, entry) => sum + (beverages[entry.key] ?? 0) * entry.value);

    double newTotalPrice = (basePrice * quantity) + extrasTotal + beverageTotal;

    if (newTotalPrice != totalPrice) {
      setState(() {
        totalPrice = newTotalPrice;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Column(
        children: [
          Container(
            height: 300,
            width: 360,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(40)),
            ),
            child: Column(
              children: [
                SizedBox(height: 30),
                Image.asset(
                  widget.pizza['image'],
                  height: 140,
                  fit: BoxFit.fill,
                ),
                SizedBox(height: 10),
                Text(widget.pizza['name'],
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // IconButton(
                    //   icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    //   onPressed: () {},
                    // ),
                    SizedBox(width: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove, color: Colors.red),
                            onPressed: () {
                              if (quantity > 1) {
                                setState(() {
                                  quantity--;
                                  updateTotalPrice();
                                });
                              }
                            },
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              '$quantity',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                quantity++;
                                updateTotalPrice();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    // IconButton(
                    //   icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                    //   onPressed: () {},
                    // ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildOptionSection(
                        'Extra Material', extraMaterials, selectedExtras),
                    SizedBox(height: 20),
                    buildOptionSection(
                        'Beverage', beverages, selectedBeverages),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 45,
            width: 320,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 140,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        spreadRadius: 4,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '\$ ${totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                  ),
                ),
                CustomElevatedButton(
                  onPressed: () {
                    final selectedPizza = {
                      'name': widget.pizza['name'],
                      'itemPrice': widget.pizza['price'], // ✅ Store base pizza price
                      'quantity': quantity,
                      'extras': selectedExtras.entries.map((e) => {
                        'name': e.key,
                        'quantity': e.value,
                        'price': extraMaterials[e.key] ?? 0.0, // ✅ Pass extra price
                        'totalPrice': (extraMaterials[e.key] ?? 0.0) * e.value, // ✅ Calculate total
                      }).toList(),
                      'beverages': selectedBeverages.entries.map((e) => {
                        'name': e.key,
                        'quantity': e.value,
                        'price': beverages[e.key] ?? 0.0, // ✅ Pass beverage price
                        'totalPrice': (beverages[e.key] ?? 0.0) * e.value, // ✅ Calculate total
                      }).toList(),
                      'totalPrice': totalPrice,
                    };

                    cartController.addToCart(selectedPizza);
                    Get.to(() => AddToCartScreen());
                  },
                  label: "Add to cart",
                  icon: Icons.shopping_cart,
                  backgroundColor: Colors.red,
                ),


              ],
            ),
          ),
          SizedBox(
            height: 15,
          )
        ],
      ),
    );
  }

  Widget buildOptionSection(
      String title, Map<String, double> options, Map<String, int> selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.zero,
          child: Text(
            title,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ),
        GridView.count(
          crossAxisCount: 1,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          childAspectRatio: 7,
          padding: EdgeInsets.zero,
          children: options.keys.map((option) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (selected.containsKey(option)) {
                    selected.remove(option);
                  } else {
                    selected[option] = 1;
                  }
                  updateTotalPrice();
                });
              },
              child: Row(
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: selected.containsKey(option)
                          ? Colors.red
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: Colors.grey.shade400, width: 1.5),
                      boxShadow: selected.containsKey(option)
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black12,
                                spreadRadius: 2,
                                blurRadius: 1,
                                offset: Offset(2, 4),
                              ),
                              BoxShadow(
                                color: Colors.white,
                                spreadRadius: -2,
                                blurRadius: 4,
                                offset: Offset(-2, -2),
                              ),
                            ],
                    ),
                    child: selected.containsKey(option)
                        ? Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                  SizedBox(width: 15),
                  Text('$option + ${options[option]} \$',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  SizedBox(width: 15),
                  if (selected.containsKey(option)) ...[
                    IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          if (selected[option]! > 1) {
                            selected[option] = selected[option]! - 1;
                          } else {
                            selected.remove(option);
                          }
                          updateTotalPrice();
                        });
                      },
                    ),
                    Text('${selected[option]}'),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          selected[option] = selected[option]! + 1;
                          updateTotalPrice();
                        });
                      },
                    ),
                  ]
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
