import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'signup.dart';
import 'home.dart';
import 'orders_page.dart';
import 'cart_page.dart';
import 'search_page.dart';
import 'profile_page.dart';
import 'add_product_page.dart';
import 'product_details_page.dart';
import 'payment_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late StreamSubscription<User?> _authSubscription;

  @override
  void initState() {
    super.initState();

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _navigatorKey.currentState?.pushReplacementNamed('/login');
      } else {
        _navigatorKey.currentState?.pushReplacementNamed('/home');
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Auth Simple',
      navigatorKey: _navigatorKey,
      initialRoute:
      FirebaseAuth.instance.currentUser == null ? '/login' : '/home',
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => HomePage(),
        '/search': (context) => SearchPage(),
        '/profile': (context) => ProfilePage(),
        '/cart': (context) => CartPage(),
        '/orders': (context) => OrdersPage(),
        '/add-product': (context) => AddProductPage(),
        '/product-details': (context) => ProductDetailsPage(),
        '/payment': (context) => PaymentPage(),
      },
    );
  }
}
