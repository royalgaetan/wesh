import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PaymentActivityPage extends StatefulWidget {
  const PaymentActivityPage({super.key});

  @override
  State<PaymentActivityPage> createState() => _PaymentActivityPageState();
}

class _PaymentActivityPageState extends State<PaymentActivityPage> {
  User? user;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0,
        elevation: 0,
        leading: IconButton(
          splashRadius: 25,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Votre activité de paiement',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              // Display all Payment here
              children: List.generate(
                  30,
                  (index) => Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(index.toString()),
                      )),
            ),
          ),
        ),
      ),
    );
  }
}
