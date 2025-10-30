import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddBusinessScreen extends StatefulWidget {
  const AddBusinessScreen({super.key});

  @override
  State<AddBusinessScreen> createState() => _AddBusinessScreenState();
}

class _AddBusinessScreenState extends State<AddBusinessScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final upiController = TextEditingController();
  final addressController = TextEditingController();
  final timingController = TextEditingController();

  Future<void> submitBusiness() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('vendors').doc(user.email).set({
      'businessName': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'upiId': upiController.text.trim(),
      'address': addressController.text.trim(),
      'timing': timingController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Your business has been registered successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.deepOrange),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.orange.shade300, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.deepOrange.shade700, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text("Add Business"),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        elevation: 2,
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
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 10),
            const Text(
              "Register Your Business",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration:
              _inputDecoration('Business Name', Icons.storefront_rounded),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration:
              _inputDecoration('Phone Number', Icons.phone_android_rounded),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: upiController,
              decoration: _inputDecoration(
                  'UPI ID (for payments)', Icons.payment_rounded),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration:
              _inputDecoration('Business Address', Icons.location_on_rounded),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timingController,
              decoration: _inputDecoration(
                  'Operating Hours (e.g. 10AM - 8PM)', Icons.access_time_rounded),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: submitBusiness,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("Submit Business"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                textStyle: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
