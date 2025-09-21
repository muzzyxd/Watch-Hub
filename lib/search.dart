import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watchhub/addcart.dart';
import 'package:watchhub/home.dart';
import 'package:watchhub/watchdetail.dart';

class SearchPage extends StatefulWidget {
  final int selectedIndex;
  final List<Map<String, dynamic>> cart;

  const SearchPage({super.key, this.selectedIndex = 1, this.cart = const []});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final supabase = Supabase.instance.client;

  String query = "";
  Future<List<Map<String, dynamic>>>? _futureWatches;

  Future<List<Map<String, dynamic>>> _searchWatches(String query) async {
    if (query.isEmpty) return [];

    final response = await supabase
        .from('watches')
        .select()
        .ilike('name', '%$query%');

    return (response as List).cast<Map<String, dynamic>>();
  }

  int _selectedIndex = 1; // default to Search

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } else if (index == 1) {
      // already in SearchPage
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CartPage(cart: widget.cart)),
      );
    } else if (index == 3) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => const ProfilePage()),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Watches")),

      // ✅ Body
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search by watch name...",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  query = value;
                  _futureWatches = _searchWatches(query);
                });
              },
            ),
          ),
          Expanded(
            child: query.isEmpty
                ? const Center(child: Text("Start typing to search..."))
                : FutureBuilder<List<Map<String, dynamic>>>(
                    future: _futureWatches,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      final results = snapshot.data ?? [];
                      if (results.isEmpty) {
                        return const Center(child: Text("No watches found"));
                      }

                      return ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final watch = results[index];
                          return ListTile(
                            leading:
                                (watch['image_url'] != null &&
                                    watch['image_url'].toString().isNotEmpty)
                                ? Image.network(
                                    watch['image_url'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.watch,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                            title: Text(watch['name'] ?? "Unknown"),
                            subtitle: Text("Brand: ${watch['brand'] ?? "N/A"}"),
                            trailing: Text("\$${watch['price'] ?? "0"}"),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      WatchDetailsPage(watch: watch),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),

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
