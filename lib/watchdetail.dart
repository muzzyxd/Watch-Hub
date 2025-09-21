// import 'package:flutter/material.dart';
// import 'package:watchhub/addcart.dart';
// import 'package:watchhub/checkout.dart';

// class WatchDetailsPage extends StatelessWidget {
//   final Map<String, dynamic> watch;

//   const WatchDetailsPage({super.key, required this.watch});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(watch['name'] ?? "Watch Details"),
//         backgroundColor: const Color.fromARGB(255, 0, 105, 95),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ✅ Image
//             ClipRRect(
//               borderRadius: BorderRadius.circular(16),
//               child: Image.network(
//                 watch['image_url'] ?? '',
//                 height: 250,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) =>
//                     const Icon(Icons.watch, size: 120, color: Colors.grey),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // ✅ Labels
//            Text(
//               "Name: ${watch['name'] ?? 'Unknown'}",
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),

//             Text(
//               "Brand: ${watch['brand'] ?? 'Not available'}",
//               style: const TextStyle(fontSize: 18, color: Colors.black),
//             ),
//             const SizedBox(height: 8),

//             Text(
//               "Type: ${watch['type'] ?? 'Unknown'}",
//               style: const TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 8),

//             Text(
//               "Price: \$${watch['price']?.toStringAsFixed(2) ?? '0.00'}",
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Color.fromARGB(255, 0, 105, 95),
//               ),
//             ),
//             const SizedBox(height: 8),

//             Text(
//               "Stock: ${watch['stock'] ?? 0}",
//               style: TextStyle(
//                 fontSize: 16,
//                 color: (watch['stock'] ?? 0) > 0 ? Colors.green : Colors.red,
//               ),
//             ),
//             const SizedBox(height: 20),

//             const Text(
//               "About this watch",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),

//             Text(
//               watch['description'] ?? "No description available",
//               style: const TextStyle(fontSize: 16, height: 1.5),
//             ),
//             const SizedBox(height: 30),

//             // ✅ Buttons
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => CheckoutPage(product: watch),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color.fromARGB(255, 0, 105, 95),
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       "Buy Now",
//                       style: TextStyle(fontSize: 16, color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 IconButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => CartPage(
//                           cart: [watch], // ✅ pass selected watch in a list
//                         ),
//                       ),
//                     );
//                   },
//                   icon: const Icon(Icons.shopping_cart, size: 30),
//                   color: const Color.fromARGB(255, 0, 105, 95),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watchhub/addcart.dart';
import 'package:watchhub/checkout.dart';

class WatchDetailsPage extends StatefulWidget {
  final Map<String, dynamic> watch;

  const WatchDetailsPage({super.key, required this.watch});

  @override
  State<WatchDetailsPage> createState() => _WatchDetailsPageState();
}

class _WatchDetailsPageState extends State<WatchDetailsPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> reviews = [];
  bool isLoading = false;

  final TextEditingController reviewController = TextEditingController();
  int selectedRating = 5;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() => isLoading = true);
    final response = await supabase
        .from('watch_reviews')
        .select()
        .eq('watch_id', widget.watch['id'])
        .order('created_at', ascending: false);
    setState(() {
      reviews = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  Future<void> _addReview() async {
    final user = supabase.auth.currentUser;
    if (user == null || reviewController.text.isEmpty) return;

    await supabase.from('watch_reviews').insert({
      'watch_id': widget.watch['id'],
      'user_id': user.id,
      'username': user.email?.split('@')[0] ?? 'User',
      'rating': selectedRating,
      'comment': reviewController.text,
    });

    reviewController.clear();
    selectedRating = 5;
    _fetchReviews();
  }

  double _calculateAverageRating() {
  if (reviews.isEmpty) return 0;
  final total = reviews.fold<int>(
    0,
    (sum, r) => sum + ((r['rating'] ?? 0) as int),
  );
  return total / reviews.length;
}


  @override
  Widget build(BuildContext context) {
    final watch = widget.watch;
    final avgRating = _calculateAverageRating();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(watch['name'] ?? "Watch Details"),
        backgroundColor: const Color.fromARGB(255, 0, 105, 95),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- Watch Image ----------------
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                  child: Image.network(
                    watch['image_url'] ?? '',
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.watch, size: 120, color: Colors.grey),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          "${avgRating.toStringAsFixed(1)} (${reviews.length})",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ---------------- Name & Brand ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                watch['name'] ?? "Unknown",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                "Brand: ${watch['brand'] ?? 'Not available'}",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 12),

            // ---------------- Price & Stock ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    "\$${watch['price']?.toStringAsFixed(2) ?? '0.00'}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 105, 95),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Stock: ${watch['stock'] ?? 0}",
                    style: TextStyle(
                      fontSize: 16,
                      color: (watch['stock'] ?? 0) > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutPage(product: watch),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 105, 95),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Buy Now",style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---------------- Description ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                "Description",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                watch['description'] ?? "No description available",
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),

            // ---------------- Reviews Section ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                "Customer Reviews",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            // Add Review Input
            if (supabase.auth.currentUser != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Write a review:"),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < selectedRating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedRating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    TextField(
                      controller: reviewController,
                      decoration: const InputDecoration(
                        hintText: "Your review",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _addReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 105, 95),
                        ),
                        child: const Text("Submit", style: TextStyle(color: Colors.white),),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Login to add a review."),
              ),

            // List of Reviews
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                  : reviews.isEmpty
                      ? const Text("No reviews yet.")
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            final r = reviews[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(r['username']?.substring(0, 1).toUpperCase() ?? 'U'),
                                ),
                                title: Text(r['username'] ?? 'User'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: List.generate(5, (i) {
                                        return Icon(
                                          i < (r['rating'] ?? 0)
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                          size: 16,
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(r['comment'] ?? ''),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
