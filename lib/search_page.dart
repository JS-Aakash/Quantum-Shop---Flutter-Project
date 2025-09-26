import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    final bool isQueryEmpty = query.trim().isEmpty;

    return Scaffold(
      appBar: AppBar(title: Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(labelText: 'Search name'),
              onChanged: (val) => setState(() => query = val.trim()),
            ),
          ),
          Expanded(
            child: isQueryEmpty
                ? Center(child: Text('Enter product name to search'))
                : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('name', isGreaterThanOrEqualTo: query)
                  .where('name', isLessThan: query + 'z')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No products found'));
                }
                final results = snapshot.data!.docs;

                return ListView(
                  children: results.map((doc) {
                    var p = doc.data()! as Map<String, dynamic>;
                    return ListTile(
                      title: Text(p['name'] ?? ''),
                      subtitle: Text('₹${p['price'] ?? ''}'),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
