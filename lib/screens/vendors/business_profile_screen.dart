import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final upiController = TextEditingController();
  final addressController = TextEditingController();
  final timingController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBusinessInfo();
  }

  Future<void> loadBusinessInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(user.email)
          .get();
      final data = doc.data();
      if (data != null) {
        nameController.text = data['businessName'] ?? '';
        phoneController.text = data['phone'] ?? '';
        upiController.text = data['upiId'] ?? '';
        addressController.text = data['address'] ?? '';
        timingController.text = data['timing'] ?? '';
      }
    } catch (e) {
      debugPrint("❌ Error loading business info: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('vendors')
          .doc(user.email)
          .update({
        'businessName': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'upiId': upiController.text.trim(),
        'address': addressController.text.trim(),
        'timing': timingController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Business info updated successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint("❌ Error saving business info: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Failed to update info. Try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.deepOrange),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.orange.shade300, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.deepOrange, width: 2),
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
        title: const Text("Business Profile"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Business Details",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 24),

            // Input Fields
            TextField(
              controller: nameController,
              decoration: _inputDecoration('Business Name', Icons.storefront),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('Phone Number', Icons.phone_android),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: upiController,
              decoration: _inputDecoration('UPI ID (for payments)', Icons.payment),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: addressController,
              maxLines: 2,
              decoration:
              _inputDecoration('Business Address', Icons.location_on),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: timingController,
              decoration:
              _inputDecoration('Operating Hours (e.g. 10AM - 8PM)', Icons.schedule),
            ),
            const SizedBox(height: 32),

            // Save Button
            Center(
              child: ElevatedButton.icon(
                onPressed: saveChanges,
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 26),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
