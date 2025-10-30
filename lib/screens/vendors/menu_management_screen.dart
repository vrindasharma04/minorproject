import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  Uint8List? selectedImageBytes;
  bool isLoading = false;

  late final String vendorEmail;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    vendorEmail = user?.email ?? 'unknown@vendor.com';
  }

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() => selectedImageBytes = bytes);
      }
    } catch (e) {
      debugPrint("❌ Error picking image: $e");
    }
  }

  Future<String?> uploadImage(Uint8List imageBytes) async {
    try {
      final fileName = 'menu/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putData(imageBytes);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("❌ Error uploading image: $e");
      return null;
    }
  }

  Future<void> addMenuItem() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) return;

    setState(() => isLoading = true);

    String? imageUrl;
    if (selectedImageBytes != null) {
      imageUrl = await uploadImage(selectedImageBytes!);
    }

    try {
      await FirebaseFirestore.instance.collection('menu_items').add({
        'vendorEmail': vendorEmail,
        'name': nameController.text.trim(),
        'price': double.tryParse(priceController.text) ?? 0,
        'imageUrl': imageUrl,
        'createdAt': Timestamp.now(),
      });

      nameController.clear();
      priceController.clear();
      selectedImageBytes = null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Item added successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint("❌ Firestore add failed: $e");
    }

    setState(() => isLoading = false);
  }

  Stream<QuerySnapshot> getMenuStream() {
    return FirebaseFirestore.instance
        .collection('menu_items')
        .where('vendorEmail', isEqualTo: vendorEmail)
        .snapshots();
  }

  Widget _menuCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: data['imageUrl'] != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            data['imageUrl'],
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        )
            : Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.deepOrange.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.fastfood,
              size: 36, color: Colors.deepOrange),
        ),
        title: Text(
          data['name'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "₹${data['price']?.toString() ?? '0'}",
          style: const TextStyle(color: Colors.black54),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.deepOrange),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
        backgroundColor: Colors.deepOrange,
        elevation: 2,
        title: const Text("Manage Menu"),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const Text(
                "Add New Item",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: _inputDecoration('Item Name', Icons.fastfood),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: _inputDecoration('Price', Icons.currency_rupee),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Select Image"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              if (selectedImageBytes != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(selectedImageBytes!,
                        height: 140, width: double.infinity, fit: BoxFit.cover),
                  ),
                ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: isLoading ? null : addMenuItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : const Text(
                  "Add Item",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                "📋 Your Menu",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: getMenuStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("No items added yet."),
                    );
                  }
                  return Column(children: docs.map(_menuCard).toList());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
