import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VendorDetailScreen extends StatefulWidget {
  final String vendorEmail;
  const VendorDetailScreen({super.key, required this.vendorEmail});

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen> {
  Map<String, dynamic>? vendorData;
  List<DocumentSnapshot> menuItems = [];
  Map<String, int> cart = {};

  @override
  void initState() {
    super.initState();
    fetchVendorInfo();
    fetchMenuItems();
  }

  Future<void> fetchVendorInfo() async {
    final doc = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(widget.vendorEmail.trim())
        .get();
    if (!mounted) return;
    setState(() {
      vendorData = doc.data();
    });
  }

  Future<void> fetchMenuItems() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('menu_items')
        .where('vendorEmail', isEqualTo: widget.vendorEmail.trim())
        .get();
    if (!mounted) return;
    setState(() {
      menuItems = snapshot.docs;
    });
  }

  void addToCart(String itemId) {
    setState(() {
      cart[itemId] = (cart[itemId] ?? 0) + 1;
    });
  }

  void removeFromCart(String itemId) {
    if ((cart[itemId] ?? 0) > 0) {
      setState(() {
        cart[itemId] = cart[itemId]! - 1;
      });
    }
  }

  void goToCart() {
    Navigator.pushNamed(context, '/cart', arguments: {
      'vendorEmail': widget.vendorEmail,
      'cart': cart,
    });
  }

  @override
  Widget build(BuildContext context) {
    final vendorName = vendorData?['businessName'] ?? 'Vendor';
    final location = vendorData?['address'] ?? 'Unknown';
    final timing = vendorData?['timing'] ?? 'Not set';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 3,
        title: Text(
          vendorName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: goToCart,
          ),
        ],
      ),
      body: vendorData == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendorName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              color: Colors.redAccent, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              color: Colors.brown, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            timing,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "🍲 Menu Items",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: menuItems.isEmpty
                    ? Center(
                  child: Text(
                    "No items available for $vendorName",
                    style: const TextStyle(fontSize: 16),
                  ),
                )
                    : ListView.builder(
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final doc = menuItems[index];
                    final data =
                    doc.data() as Map<String, dynamic>;
                    final imageUrl = data['imageUrl'];
                    final name = data['name'] ?? 'Unnamed';
                    final price = data['price'] ?? 0;
                    final itemId = doc.id;
                    final quantity = cart[itemId] ?? 0;

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin:
                      const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: imageUrl != null
                              ? Image.network(
                            imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                              : const Icon(
                            Icons.fastfood,
                            size: 40,
                            color: Colors.deepOrange,
                          ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        subtitle: Text(
                          "₹$price",
                          style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black54),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              onPressed: quantity > 0
                                  ? () => removeFromCart(itemId)
                                  : null,
                            ),
                            Text('$quantity',
                                style:
                                const TextStyle(fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.add_circle,
                                  color: Colors.green),
                              onPressed: () => addToCart(itemId),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
