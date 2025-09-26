import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text('Please log in to access your orders')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('My Orders')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final orders = snapshot.data!.docs;

          if (orders.isEmpty)
            return Center(child: Text('No orders found'));

          return ListView(
            children: orders.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final items = data['items'] as List<dynamic>;
              final total = data['total'];
              final status = data['status'] ?? 'pending';

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text('Order ID: ${doc.id}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...items.map((item) => Text(
                          '${item['name']} x ${item['quantity']} - ₹${item['price']}')),
                      SizedBox(height: 8),
                      Text('Total: ₹$total'),
                      Text('Status: $status'),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
