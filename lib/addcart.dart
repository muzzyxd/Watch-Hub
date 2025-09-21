import 'package:flutter/material.dart';
import 'package:watchhub/checkout.dart';
import 'package:watchhub/home.dart';
import 'package:watchhub/search.dart';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;

  const CartPage({super.key, required this.cart});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double get totalPrice {
    double sum = 0;
    for (var item in widget.cart) {
      sum += (item['price'] ?? 0).toDouble();
    }
    return sum;
  }

  void _placeOrder() {
    if (widget.cart.isEmpty) return;

    setState(() {
      widget.cart.clear(); // 🧹 Clear cart
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Order placed successfully!"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  List<Map<String, dynamic>> cart = [];

  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Cart")),
      body: widget.cart.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : Column(
              children: [
                // 🛒 Cart Items
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      final item = widget.cart[index];
                      return ListTile(
                        leading: Image.network(
                          item['image_url'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(item['name'] ?? "Unknown"),
                        subtitle: Text("\$${item['price']}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              widget.cart.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

                // 🧾 Total + Place Order Button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: const Border(
                      top: BorderSide(color: Colors.black12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Total: \$${totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CheckoutPage(cart: widget.cart),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            0,
                            105,
                            95,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Place Order",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      // ✅ Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == _selectedIndex) return; // avoid reloading same page

          setState(() {
            _selectedIndex = index;
          });

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(), // ✅ index 0 = Home
              ),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchPage(), // ✅ index 1 = Search
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartPage(cart: widget.cart), // ✅ Cart
              ),
            );
          } else if (index == 3) {
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => const ProfilePage(), // ✅ Profile
            //   ),
            // );
          }
        },
        selectedItemColor: const Color.fromARGB(255, 0, 105, 95),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (widget.cart.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        "${widget.cart.length}",
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: "Cart",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
