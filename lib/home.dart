import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isFavorite = false;
  bool isSearchClicked = false;

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
                      borderRadius: BorderRadius.circular(12), // make circular
                      child: Image.asset(
                        "assets/watchhublogo.jpeg",
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const Spacer(),

                    // 🔍 Search icon with zoom + blur
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isSearchClicked = !isSearchClicked;
                        });
                      },
                      child: AnimatedScale(
                        scale: isSearchClicked ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: Icon(
                          Icons.search,
                          color: Colors.black,
                          size: 27,
                          shadows: isSearchClicked
                              ? [
                                  const Shadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                  ),
                                ]
                              : [],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ❤️ Favorite icon toggle
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                      },
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                        size: 27,
                      ),
                    ),

                    const SizedBox(width: 12),
                  ],
                ),
              ),

              //const Spacer(),
              //  Icon(Icons.search, color: Colors.black, size: 27),
              // const SizedBox(width: 12),
              // Icon(Icons.favorite_border, color: Colors.red),
              // const SizedBox(width: 12),

              // Location Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 0, 105, 95).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.black),
                      const SizedBox(width: 8),
                      const Expanded(child: Text("Sent to : Karachi, Pakisan")),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Banner / Carousel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height:200,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 1, // show 1 full image
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
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildCategory("All Promo", "assets/cat1.png"),
                    _buildCategory("Gentle", "assets/cat2.png"),
                    _buildCategory("Feminine", "assets/cat3.png"),
                    _buildCategory("Strap", "assets/cat4.png"),
                    _buildCategory("Couple", "assets/cat5.png"),
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
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildProduct(
                      "Garmin Instinct 2",
                      "Rp.5.799.000",
                      "assets/watch1.jpg",
                    ),
                    _buildProduct(
                      "Apple Watch SE",
                      "Rp.5.975.000",
                      "assets/watch2.jpg",
                    ),
                    _buildProduct(
                      "Samsung Watch FE",
                      "Rp.6.899.000",
                      "assets/watch3.jpg",
                    ),
                  ],
                ),
              ),
            ],
            // ignore: dead_code
          ),
        ),
      ),

      // ✅ Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color.fromARGB(255, 0, 105, 95),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // ✅ Category Widget
  static Widget _buildCategory(String title, String img) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 80,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 0, 105, 95).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(img, height: 40),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // ✅ Product Card
  static Widget _buildProduct(String name, String price, String img) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(img, height: 150, width: 160, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              price,
              style: const TextStyle(
                color: Color.fromARGB(255, 0, 105, 95),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
