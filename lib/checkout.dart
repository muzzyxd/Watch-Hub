import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>>? cart; // optional
  final Map<String, dynamic>? product; // optional

  const CheckoutPage({super.key, this.cart, this.product});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  double get totalPrice {
    if (widget.product != null) {
      return (widget.product!['price'] ?? 0).toDouble();
    }
    if (widget.cart != null) {
      return widget.cart!.fold(
        0.0,
        (sum, item) => sum + (item['price'] ?? 0).toDouble(),
      );
    }
    return 0.0;
  }

  Future<void> _submitOrder() async {
    if (_formKey.currentState!.validate()) {
      final supabase = Supabase.instance.client;
      final user = Supabase.instance.client.auth.currentUser;

      try {
        await supabase.from('orders').insert({
          'user_id': user?.id,
          'name': _nameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'total_price': totalPrice,
          'items': widget.product != null
              ? [widget.product] // single product in list
              : widget.cart, // cart items
        });

        if (widget.cart != null) {
          setState(() {
            widget.cart!.clear();
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Order placed successfully!")),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Failed to place order: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Text(
              //   "Total: \$${totalPrice.toStringAsFixed(2)}",
              //   style:
              //       const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              //   textAlign: TextAlign.right,
              // ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter your name" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? "Please enter your phone number" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Delivery Address",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? "Please enter your address" : null,
              ),
              const SizedBox(height: 16),
              Text(
                "Total: \$${totalPrice.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 105, 95),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Confirm Order",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
