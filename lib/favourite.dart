import 'package:flutter/material.dart';
import 'package:watchhub/watchdetail.dart';

class FavouritePage extends StatelessWidget {
  final List<Map<String, dynamic>> favorites;

  const FavouritePage({super.key, required this.favorites});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favourite Watches")),
      body: favorites.isEmpty
          ? const Center(child: Text("No favourites yet ❤️"))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final watch = favorites[index];
                return ListTile(
                  leading: (watch['image_url'] != null &&
                          watch['image_url'].toString().isNotEmpty)
                      ? Image.network(
                          watch['image_url'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.watch,
                          size: 40, color: Colors.grey),
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
            ),
    );
  }
}
