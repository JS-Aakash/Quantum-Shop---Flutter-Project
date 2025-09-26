import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text('Please log in to access your cart')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('My Cart')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final cartItems = snapshot.data!.docs;

          if (cartItems.isEmpty)
            return Center(child: Text('Your cart is empty'));

          double total = 0;
          cartItems.forEach((doc) {
            final data = doc.data() as Map<String, dynamic>;
            total += (data['price'] as num) * (data['quantity'] as int);
          });

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: cartItems.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      leading: Image.network(data['image'], width: 50, height: 50),
                      title: Text(data['name']),
                      subtitle: Text('₹${data['price']} x ${data['quantity']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('cart')
                              .doc(doc.id)
                              .delete();
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text('Total: ₹$total',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }
}
