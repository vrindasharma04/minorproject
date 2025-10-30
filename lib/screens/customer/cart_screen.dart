import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatefulWidget {
  final String vendorEmail;
  final Map<String, int> cart;
  const CartScreen({super.key, required this.vendorEmail, required this.cart});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Map<String, dynamic> itemDetails = {};
  bool isLoading = true;
  double total = 0;
  bool isCODChecked = false;

  @override
  void initState() {
    super.initState();
    fetchItemDetails();
  }

  Future<void> fetchItemDetails() async {
    total = 0;
    for (String itemId in widget.cart.keys) {
      final doc = await FirebaseFirestore.instance.collection('menu_items').doc(itemId).get();
      final data = doc.data();
      if (data != null) {
        itemDetails[itemId] = data;
        total += (data['price'] ?? 0) * widget.cart[itemId]!;
      }
    }
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> confirmAndPlaceOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Pickup"),
        content: const Text("Please confirm you'll pick up your order within 20 minutes."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await placeOrder();
    }
  }

  Future<void> placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !mounted) return;

    final orderItems = widget.cart.entries.map((entry) {
      final item = itemDetails[entry.key];
      return {
        'itemId': entry.key,
        'name': item['name'],
        'price': item['price'],
        'quantity': entry.value,
      };
    }).toList();

    await FirebaseFirestore.instance.collection('orders').add({
      'vendorEmail': widget.vendorEmail,
      'customerEmail': user.email,
      'items': orderItems,
      'total': total,
      'paid': false,
      'timestamp': Timestamp.now(),
      'status': 'Confirmed',
    });

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/order_success');
  }

  Widget _cartItem(String itemId, int quantity) {
    final item = itemDetails[itemId];
    return Card(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.deepOrange.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: item['imageUrl'] != null && item['imageUrl'].toString().startsWith('http')
                  ? Image.network(
                item['imageUrl'],
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 40, color: Colors.grey),
              )
                  : const Icon(Icons.fastfood, size: 50, color: Colors.deepOrange),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₹${item['price']} x $quantity",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            Text(
              "₹${item['price'] * quantity}",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3E7),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 2,
        title: const Text("Your Cart"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: widget.cart.isEmpty
                  ? const Center(
                child: Text(
                  "Your cart is empty 🛒",
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              )
                  : ListView(
                children: widget.cart.entries
                    .map((e) => _cartItem(e.key, e.value))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Total: ₹$total",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: isCODChecked,
                        onChanged: (value) {
                          setState(() => isCODChecked = value ?? false);
                        },
                        activeColor: Colors.deepOrange,
                      ),
                      const Text(
                        "Cash on Delivery (COD)",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: isCODChecked ? confirmAndPlaceOrder : null,
                    icon: const Icon(Icons.check_circle),
                    label: const Text("Place Order"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
