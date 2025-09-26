import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final imageCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final stockCtrl = TextEditingController();

  String message = '';

  Future<void> addProduct() async {
    if (nameCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty) {
      setState(() {
        message = 'Please fill in product name and price';
      });
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'name': nameCtrl.text.trim(),
        'price': double.tryParse(priceCtrl.text.trim()) ?? 0,
        'image': imageCtrl.text.trim(),
        'description': descriptionCtrl.text.trim(),
        'category': categoryCtrl.text.trim(),
        'stock': int.tryParse(stockCtrl.text.trim()) ?? 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        message = 'Product added successfully!';
      });
      nameCtrl.clear();
      priceCtrl.clear();
      imageCtrl.clear();
      descriptionCtrl.clear();
      categoryCtrl.clear();
      stockCtrl.clear();
    } catch (e) {
      setState(() {
        message = 'Error adding product: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: priceCtrl,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: imageCtrl,
              decoration: InputDecoration(labelText: 'Image URL'),
            ),
            TextField(
              controller: descriptionCtrl,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            TextField(
              controller: categoryCtrl,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: stockCtrl,
              decoration: InputDecoration(labelText: 'Stock Quantity'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addProduct,
              child: Text('Add Product'),
            ),
            SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(color: message.contains('Error') ? Colors.red : Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
