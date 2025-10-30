import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerVendorView extends StatefulWidget {
  final String vendorEmail;
  const CustomerVendorView({super.key, required this.vendorEmail});

  @override
  State<CustomerVendorView> createState() => _CustomerVendorViewState();
}

class _CustomerVendorViewState extends State<CustomerVendorView> {
  Map<String, dynamic>? vendorData;
  Map<String, int> selectedItems = {};
  bool paymentDone = false;

  @override
  void initState() {
    super.initState();
    fetchVendorInfo();
  }

  Future<void> fetchVendorInfo() async {
    final doc = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(widget.vendorEmail)
        .get();
    if (doc.exists) {
      setState(() {
        vendorData = doc.data();
      });
    }
  }

  void togglePayment() {
    setState(() {
      paymentDone = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment simulated ✅')),
    );
  }

  void placeOrder() async {
    if (!paymentDone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pay before placing order')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    for (var entry in selectedItems.entries) {
      await FirebaseFirestore.instance.collection('orders').add({
        'vendorEmail': widget.vendorEmail,
        'customerEmail': user.email,
        'customerName': user.email?.split('@')[0],
        'itemName': entry.key,
        'quantity': entry.value,
        'paid': true,
        'timestamp': Timestamp.now(),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order placed successfully')),
    );
    setState(() {
      selectedItems.clear();
      paymentDone = false;
    });
  }

  Widget buildMenuItem(Map<String, dynamic> item) {
    final name = item['name'] ?? 'Item';
    final price = item['price'] ?? '0';
    final imageUrl = item['imageUrl'] ?? '';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: imageUrl.isNotEmpty
              ? Image.network(
            imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          )
              : Container(
            width: 60,
            height: 60,
            color: Colors.orange.shade50,
            child: const Icon(Icons.fastfood, size: 36, color: Colors.deepOrange),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          "₹$price",
          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
              onPressed: () {
                setState(() {
                  if (selectedItems[name] != null && selectedItems[name]! > 0) {
                    selectedItems[name] = selectedItems[name]! - 1;
                  }
                });
              },
            ),
            Text(
              '${selectedItems[name] ?? 0}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
              onPressed: () {
                setState(() {
                  selectedItems[name] = (selectedItems[name] ?? 0) + 1;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (vendorData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.deepOrange),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          vendorData!['businessName'] ?? 'Vendor',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepOrange,
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (vendorData!['thelaImageUrl'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  vendorData!['thelaImageUrl'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              "📍 Locations & Timings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...List.generate((vendorData!['addressSlots'] as List).length, (i) {
              final slot = vendorData!['addressSlots'][i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  "• ${slot['location']} — ${slot['from']} to ${slot['to']}",
                  style: const TextStyle(fontSize: 15),
                ),
              );
            }),
            const SizedBox(height: 20),
            const Text(
              "🧾 Menu",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('menu_items')
                  .where('vendorEmail', isEqualTo: widget.vendorEmail)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: CircularProgressIndicator(color: Colors.deepOrange),
                    ),
                  );
                }
                final items = snapshot.data!.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList();
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        'No items available yet.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                  );
                }
                return Column(children: items.map(buildMenuItem).toList());
              },
            ),
            const SizedBox(height: 24),
            Text(
              "💳 UPI ID: ${vendorData!['upiId'] ?? 'Not Provided'}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: togglePayment,
              icon: const Icon(Icons.payment_outlined),
              label: const Text("Simulate Payment"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: placeOrder,
              icon: const Icon(Icons.check_circle_outline),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              label: const Text("Place Order"),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
