import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watchhub/addcart.dart';
import 'package:watchhub/checkout.dart';
import 'package:watchhub/favourite.dart';
import 'package:watchhub/profile.dart';
import 'package:watchhub/search.dart';
import 'package:watchhub/watchdetail.dart';

class HomePage extends StatefulWidget {
  final List<Map<String, dynamic>>? watches;

  const HomePage({super.key, this.watches});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;

  late Future<List<Map<String, dynamic>>> _futureWatches;
  List<Map<String, dynamic>> cart = [];
  List<Map<String, dynamic>> favorites = [];

  int _selectedIndex = 0;

  Future<List<Map<String, dynamic>>> _fetchWatches() async {
    final response = await supabase
        .from('watches')
        .select()
        .not('image_url', 'is', null)
        .limit(10);
    return (response as List).cast<Map<String, dynamic>>();
  }

  @override
  void initState() {
    super.initState();
    _futureWatches = widget.watches != null
        ? Future.value(widget.watches)
        : _fetchWatches();
  }

  String selectedCategory = "All";
  String currentLocation = "Karachi, Pakistan";

  final List<String> locations = [
    "Karachi, Pakistan",
    "Lahore, Pakistan",
    "Islamabad, Pakistan",
    "Rawalpindi, Pakistan",
    "Multan, Pakistan",
  ];

  Future<List<Map<String, dynamic>>> _catchWatches({String? category}) async {
    var query = supabase.from('watches').select();
    if (category != null && category != "All") {
      query = query.eq('type', category);
    }
    final response = await query;
    return (response as List).cast<Map<String, dynamic>>();
  }

  bool isFavorite(Map<String, dynamic> watch) {
    return favorites.any((item) => item['id'] == watch['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        "assets/watchhublogo.jpeg",
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Spacer(),

                    // 🔍 Search icon
                    IconButton(
                      icon: const Icon(Icons.search, size: 27),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchPage(),
                          ),
                        );
                      },
                    ),
                    

                    // ❤️ Favorites icon → go to FavouritePage
                    IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 27,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FavouritePage(favorites: favorites),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // 🌍 Location Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      0,
                      105,
                      95,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.black),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          value: currentLocation,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: locations.map((loc) {
                            return DropdownMenuItem(
                              value: loc,
                              child: Text(
                                loc,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                currentLocation = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Carousel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 200,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 1,
                  ),
                  items:
                      [
                        "assets/carousel3.jpg",
                        "assets/carousel1.jpg",
                        "assets/carousel2.png",
                      ].map((imgPath) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            imgPath,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        );
                      }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Categories
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Categories",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildCategory("All"),
                    _buildCategory("Automatic"),
                    _buildCategory("Smart"),
                    _buildCategory("Sports"),
                    _buildCategory("Strap"),
                    _buildCategory("Digital"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Curated for you
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Curated for you",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 270,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _futureWatches,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    final watches = snapshot.data ?? [];
                    if (watches.isEmpty) {
                      return const Center(child: Text("No watches found"));
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: watches.length,
                      itemBuilder: (context, index) {
                        final watch = watches[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    WatchDetailsPage(watch: watch),
                              ),
                            );
                          },
                          child: _buildProduct(watch),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // ✅ Fixed Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartPage(cart: cart)),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
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
                if (cart.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        "${cart.length}",
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

  // ✅ Category Widget
  Widget _buildCategory(String title) {
    final isSelected = selectedCategory == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = title;
          _futureWatches = _catchWatches(category: title);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 0, 105, 95)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // ✅ Product Card
  Widget _buildProduct(Map<String, dynamic> watch) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 15),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image + Favourite Icon
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.network(
                      watch['image_url'] ?? "assets/default_watch.png",
                      height: 115,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.watch, size: 80, color: Colors.grey),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white.withOpacity(0.8),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            isFavorite(watch)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              if (isFavorite(watch)) {
                                favorites.removeWhere(
                                  (item) => item['id'] == watch['id'],
                                );
                              } else {
                                favorites.add(watch);
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Text(
                watch['brand'] ?? "Unknown",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                watch['name'] ?? "Unknown",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "\$${watch['price'] ?? 0}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 0, 105, 95),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              // Buttons Row
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 105, 95),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text(
                        "Buy Now",
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 🛒 Cart Button
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          cart.add(watch);
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CartPage(cart: cart),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.shopping_cart,
                        size: 18,
                        color: Color.fromARGB(255, 0, 105, 95),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class WatchDetailsPage extends StatelessWidget {
//   final Map<String, dynamic> watch;

//   const WatchDetailsPage({super.key, required this.watch});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(watch['name'] ?? "Watch Details")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Image.network(watch['image'] ?? '', height: 250, fit: BoxFit.cover),
//             const SizedBox(height: 20),
//             Text(
//               watch['name'] ?? '',
//               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               "Price: \$${watch['price'] ?? ''}",
//               style: const TextStyle(fontSize: 18, color: Colors.grey),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               watch['description'] ?? "No description available",
//               style: const TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// checkout page


  // Widget _buildProduct(String name, String price, String imageUrl) {
  //   return Container(
  //     width: 180,
  //     margin: const EdgeInsets.only(right: 15),
  //     child: Card(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       elevation: 4,
  //       child: Padding(
  //         padding: const EdgeInsets.all(12),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             // Product Image with Favorite icon on top-right
  //             Stack(
  //               children: [
  //                 ClipRRect(
  //                   borderRadius: BorderRadius.circular(12),
  //                   child: Image.network(
  //                     imageUrl,
  //                     height: 130,
  //                     width: double.infinity,
  //                     fit: BoxFit.cover,
  //                     errorBuilder: (context, error, stackTrace) =>
  //                         const Icon(Icons.watch, size: 80, color: Colors.grey),
  //                   ),
  //                 ),
  //               ],
  //             ),

  //             const SizedBox(height: 10),

  //             // Product Name
  //             Text(
  //               name,
  //               maxLines: 1,
  //               overflow: TextOverflow.ellipsis,
  //               style: const TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),

  //             // Product Price
  //             Text(
  //               price,
  //               style: const TextStyle(
  //                 fontSize: 14,
  //                 color: Color.fromARGB(255, 0, 105, 95),
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),

  //             const SizedBox(height: 10),

  //             // Buttons Row
  //             Row(
  //               children: [
  //                 // Buy Now button
  //                 Expanded(
  //                   child: ElevatedButton(
  //                     onPressed: () {
  //                       // TODO: Handle Buy Now
  //                     },
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Color.fromARGB(255, 0, 105, 95),
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                       padding: const EdgeInsets.symmetric(vertical: 8),
  //                     ),
  //                     child: const Text(
  //                       "Buy Now",
  //                       style: TextStyle(fontSize: 12, color: Colors.white),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(width: 8),

  //                 // Cart circle button
  //                 CircleAvatar(
  //                   radius: 18,
  //                   backgroundColor: Colors.white,
  //                   child: IconButton(
  //                     padding: EdgeInsets.zero,
  //                     onPressed: () {
  //                       // TODO: Handle Add to Cart
  //                     },
  //                     icon: const Icon(
  //                       Icons.shopping_cart,
  //                       size: 18,
  //                       color: Color.fromARGB(255, 0, 105, 95),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  //   // ✅ Product Card
  //   static Widget _buildProduct(String name, String price, String img) {
  //     return Container(
  //       margin: const EdgeInsets.only(right: 16),
  //       width: 160,
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(16),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.grey.withOpacity(0.2),
  //             blurRadius: 6,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           ClipRRect(
  //             borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
  //             child: Image.asset(img, height: 150, width: 160, fit: BoxFit.cover),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Text(
  //               name,
  //               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //             child: Text(
  //               price,
  //               style: const TextStyle(
  //                 color: Color.fromARGB(255, 0, 105, 95),
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }
