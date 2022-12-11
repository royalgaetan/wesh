import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/widgets/payment_card.dart';

import '../../models/payment.dart';
import '../../services/firestore.methods.dart';
import '../../widgets/buildWidgets.dart';

class PaymentActivityPage extends StatefulWidget {
  const PaymentActivityPage({super.key});

  @override
  State<PaymentActivityPage> createState() => _PaymentActivityPageState();
}

class _PaymentActivityPageState extends State<PaymentActivityPage> {
  User? user;
  @override
  void initState() {
    super.initState();
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: MorphingAppBar(
          heroTag: 'paymentActivityPageAppBar',
          backgroundColor: Colors.white,
          titleSpacing: 0,
          elevation: 0,
          leading: IconButton(
            splashRadius: 0.06.sw,
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

          // TAB BAR
          bottom: TabBar(
              indicatorColor: Colors.black87,
              unselectedLabelColor: Colors.black87,
              // labelPadding: EdgeInsets.only(top: 20),
              unselectedLabelStyle: TextStyle(fontSize: 15.sp),
              labelStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
              labelColor: Colors.black,
              tabs: const [
                Tab(
                  text: 'Envoyés',
                ),
                Tab(
                  text: 'Reçus',
                ),
              ]),
        ),
        body: TabBarView(
          children: [
            // PAYMENT SENT
            StreamBuilder<List<Payment>>(
              stream: FirestoreMethods().getPaymentBySenderId(FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                // Handle error
                if (snapshot.hasError) {
                  debugPrint('error: ${snapshot.error}');
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 100),
                    child: Column(
                      children: const [
                        Center(
                          child: buildErrorWidget(onWhiteBackground: true),
                        ),
                      ],
                    ),
                  );
                }

                // handle data
                if (snapshot.hasData && snapshot.data != null) {
                  List<Payment> listPayment = snapshot.data as List<Payment>;
                  log('listReminder: $listPayment');
                  listPayment.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                  if (listPayment.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(30),
                      height: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            height: 150,
                            'assets/animations/112136-empty-red.json',
                            width: double.infinity,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Vous n\'avez pas encore envoyé de l\'argent à une personne !',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    shrinkWrap: true,
                    children: listPayment.map((payment) {
                      return PaymentCard(payment: payment);
                    }).toList(),
                  );
                }

                // Diplay Loader
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CupertinoActivityIndicator(
                      radius: 12.sp,
                    ),
                  );
                }

                return Container();
              },
            ),

            // PAYMENT RECEIVED
            StreamBuilder<List<Payment>>(
              stream: FirestoreMethods().getPaymentByReceiverId(FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                // Handle error
                if (snapshot.hasError) {
                  debugPrint('error: ${snapshot.error}');
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 100),
                    child: Column(
                      children: const [
                        Center(
                          child: buildErrorWidget(onWhiteBackground: true),
                        ),
                      ],
                    ),
                  );
                }

                // handle data
                if (snapshot.hasData && snapshot.data != null) {
                  List<Payment> listPayment = snapshot.data as List<Payment>;
                  log('listReminder: $listPayment');
                  listPayment.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                  if (listPayment.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(30),
                      height: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            height: 150,
                            'assets/animations/112136-empty-red.json',
                            width: double.infinity,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Vous n\'avez pas encore reçu de l\'argent de la part d\'une personne !',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    shrinkWrap: true,
                    children: listPayment.map((payment) {
                      return PaymentCard(payment: payment);
                    }).toList(),
                  );
                }

                // Diplay Loader
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CupertinoActivityIndicator(
                      radius: 12.sp,
                    ),
                  );
                }

                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}
