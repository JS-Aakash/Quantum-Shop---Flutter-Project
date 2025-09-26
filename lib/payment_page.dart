import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final cardCtrl = TextEditingController();
  final expCtrl = TextEditingController();
  final cvvCtrl = TextEditingController();
  String feedback = '';

  void simulatePayment() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        feedback = "Payment successful! Thank you for your order.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payment")),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Enter Payment Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                SizedBox(height: 18),
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: "Cardholder's Name", border: OutlineInputBorder()),
                  validator: (v) => v == null || v.trim().isEmpty ? "Enter name" : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: cardCtrl,
                  decoration: InputDecoration(labelText: "Card Number", border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  validator: (v) => v == null || v.length != 16 ? "Enter valid 16-digit card number" : null,
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: expCtrl,
                        decoration: InputDecoration(labelText: "MM/YY", border: OutlineInputBorder()),
                        keyboardType: TextInputType.datetime,
                        maxLength: 5,
                        validator: (v) => v == null || !RegExp(r"^\d\d/\d\d$").hasMatch(v) ? "MM/YY?" : null,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: cvvCtrl,
                        decoration: InputDecoration(labelText: "CVV", border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        validator: (v) => v == null || v.length != 3 ? "CVV?" : null,
                        obscureText: true,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.payment),
                    label: Text("Pay Now"),
                    onPressed: simulatePayment,
                  ),
                ),
                if (feedback.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(feedback, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
