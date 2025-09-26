import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;

  // Controllers for initial profile input
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  bool editing = false;

  Future<void> saveProfile() async {
    final uid = user?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'email': user?.email,
      'name': nameCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
      'address': addressCtrl.text.trim(),
    }, SetOptions(merge: true));
    setState(() {
      editing = false;
    });
  }

  Widget buildProfileForm([Map<String, dynamic>? profile]) {
    if (profile != null) {
      nameCtrl.text = profile['name'] ?? '';
      phoneCtrl.text = profile['phone'] ?? '';
      addressCtrl.text = profile['address'] ?? '';
    }
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 80),
          SizedBox(height: 24),
          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          SizedBox(height: 12),
          TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: 'Phone'),
          ),
          SizedBox(height: 12),
          TextField(
            controller: addressCtrl,
            decoration: InputDecoration(labelText: 'Address'),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: saveProfile,
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget buildProfileView(Map<String, dynamic> profile) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 80),
          SizedBox(height: 16),
          Text(profile['name'] ?? '', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text(profile['email'] ?? '', style: TextStyle(color: Colors.grey[600])),
          SizedBox(height: 16),
          if ((profile['phone'] ?? '').isNotEmpty)
            Row(children: [Icon(Icons.phone), SizedBox(width: 8), Text(profile['phone'])]),
          if ((profile['address'] ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(children: [Icon(Icons.home), SizedBox(width: 8), Flexible(child: Text(profile['address']))]),
            ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => setState(() => editing = true),
            child: Text('Edit'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[300]),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // Optionally: Navigator.pop(context);
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = user?.uid;
    if (uid == null) {
      return Scaffold(
        body: Center(child: Text('No user logged in.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final profile = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          // If first time: show form, else show details (edit if asked)
          if (editing || (profile['name'] == null && profile['phone'] == null && profile['address'] == null)) {
            return buildProfileForm(profile);
          } else {
            return buildProfileView(profile);
          }
        },
      ),
    );
  }
}
