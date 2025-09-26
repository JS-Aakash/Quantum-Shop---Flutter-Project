import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> product =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    Future<void> addToCart() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please log in to add items to cart')));
        return;
      }
      try {
        final cartDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .doc(product['name']);

        final snapshot = await cartDoc.get();

        if (snapshot.exists) {
          final currentQty = snapshot['quantity'] ?? 1;
          await cartDoc.update({'quantity': currentQty + 1});
        } else {
          await cartDoc.set({
            'name': product['name'],
            'price': product['price'],
            'image': product['image'],
            'quantity': 1,
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added to cart successfully')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add to cart: $e')));
      }
    }

    Future<void> placeOrder() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please log in to place orders')));
        return;
      }
      try {
        final orderDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('orders')
            .doc();

        await orderDoc.set({
          'items': [
            {
              'name': product['name'],
              'price': product['price'],
              'quantity': 1,
              'image': product['image'],
            }
          ],
          'total': product['price'],
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        Navigator.pushNamed(context, '/payment');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to place order: $e')));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(product['name'] ?? 'Product Details')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container with AspectRatio preserves image proportions
            Container(
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: 4 / 3, // Adjust this ratio to match your image ratio or keep 4:3
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product['image'] ?? '',
                    fit: BoxFit.contain, // Show entire image without cropping/distortion
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              product['name'] ?? '',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Price: ₹${product['price'] ?? ''}',
              style: TextStyle(fontSize: 20, color: Colors.green),
            ),
            SizedBox(height: 12),
            Text(
              'Category: ${product['category'] ?? 'N/A'}',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 12),
            Text(
              'Stock: ${product['stock'] ?? '0'} available',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              product['description'] ?? 'No description available.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.shopping_cart),
                  label: Text('Add to Cart'),
                  onPressed: addToCart,
                ),
                SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.payment),
                  label: Text('Order Now'),
                  onPressed: placeOrder,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
