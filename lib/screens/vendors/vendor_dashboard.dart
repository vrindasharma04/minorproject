import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VendorDashboard extends StatelessWidget {
  final String email;
  const VendorDashboard({super.key, required this.email});

  String get displayName => email.split('@')[0];

  void handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login', arguments: 'vendor');
  }

  void openAddBusinessForm(BuildContext context) {
    Navigator.pushNamed(context, '/add_business');
  }

  void openBusinessProfile(BuildContext context) {
    Navigator.pushNamed(context, '/business_profile');
  }

  void openMenuManagement(BuildContext context) {
    Navigator.pushNamed(context, '/menu_management');
  }

  Widget _orderCard(Map<String, dynamic> order) {
    final items = order['items'] as List<dynamic>? ?? [];
    final firstItem = items.isNotEmpty ? items[0] : null;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          decoration: BoxDecoration(
            color: Colors.deepOrange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.receipt_long, color: Colors.deepOrange, size: 28),
        ),
        title: Text(
          firstItem?['name'] ?? 'Item',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          "Qty: ${firstItem?['quantity'] ?? 1} | Paid: ${order['paid'] ? '✅' : '❌'} | Status: ${order['status']}",
          style: const TextStyle(fontSize: 14),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Icon(Icons.person_outline, size: 20, color: Colors.grey),
            const SizedBox(height: 4),
            Text(
              order['customerEmail'] ?? 'Customer',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fairCard(String title, String subtitle, String assetPath) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(assetPath, height: 160, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.event_available, size: 18),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {},
                    label: const Text("Register"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepOrange,
        elevation: 3,
        title: Text(
          "Namastey, $displayName 🙏",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: Colors.white,
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onSelected: (value) {
              if (value == 'logout') {
                handleLogout(context);
              } else if (value == 'add_business') {
                openAddBusinessForm(context);
              } else if (value == 'profile') {
                openBusinessProfile(context);
              } else if (value == 'menu') {
                openMenuManagement(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Text('My Profile')),
              const PopupMenuItem(value: 'add_business', child: Text('Add Business')),
              const PopupMenuItem(value: 'menu', child: Text('Add Menu')),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "📦 Received Orders",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .where('vendorEmail', isEqualTo: email)
                    .where('status', isEqualTo: 'Confirmed')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(color: Colors.deepOrange),
                        ));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        "No confirmed orders yet.",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    );
                  }
                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return _orderCard(data);
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 30),
              const Text(
                "📅 Upcoming Fairs & Events",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _fairCard("Street Food Festival",
                  "Downtown Park - 25th Sept", "assets/images/festival.jpg"),
              _fairCard("Night Market", "City Center - 30th Sept",
                  "assets/images/nightmarket.jpg"),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
