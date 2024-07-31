import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:wesh/widgets/payment_card.dart';
import '../../models/payment.dart';
import '../../services/firestore.methods.dart';
import '../../utils/constants.dart';
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
        appBar: AppBar(
          toolbarHeight: 46,
          scrolledUnderElevation: 0.0,
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
            'Transactions',
            style: TextStyle(color: Colors.black),
          ),

          // TAB BAR
          bottom: TabBar(
              padding: const EdgeInsets.only(bottom: 10),
              indicatorColor: Colors.black87,
              labelPadding: const EdgeInsets.only(bottom: 0),
              unselectedLabelColor: Colors.black87,
              // labelPadding: EdgeInsets.only(top: 20),
              unselectedLabelStyle: TextStyle(fontSize: 14.sp),
              dividerColor: Colors.grey.shade300,
              labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              labelColor: Colors.black,
              splashFactory: NoSplash.splashFactory,
              tabs: const [
                Tab(
                  text: 'Sent',
                ),
                Tab(
                  text: 'Received',
                ),
              ]),
        ),
        body: TabBarView(
          children: [
            // PAYMENT SENT
            StreamBuilder<List<Payment>>(
              stream: FirestoreMethods.getPaymentBySenderId(FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                // Handle error
                if (snapshot.hasError) {
                  debugPrint('error: ${snapshot.error}');
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 100),
                    child: Column(
                      children: [
                        Center(
                          child: BuildErrorWidget(onWhiteBackground: true),
                        ),
                      ],
                    ),
                  );
                }

                // handle data
                if (snapshot.hasData && snapshot.data != null) {
                  List<Payment> listPayment = snapshot.data as List<Payment>;

                  listPayment.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                  if (listPayment.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(30),
                      height: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            height: 100,
                            empty,
                            width: double.infinity,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'You haven\'t sent money\nto anyone yet!',
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
              stream: FirestoreMethods.getPaymentByReceiverId(FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                // Handle error
                if (snapshot.hasError) {
                  debugPrint('error: ${snapshot.error}');
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 100),
                    child: Column(
                      children: [
                        Center(
                          child: BuildErrorWidget(onWhiteBackground: true),
                        ),
                      ],
                    ),
                  );
                }

                // handle data
                if (snapshot.hasData && snapshot.data != null) {
                  List<Payment> listPayment = snapshot.data as List<Payment>;

                  listPayment.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                  if (listPayment.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(30),
                      height: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            empty,
                            height: 100,
                            width: double.infinity,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'You haven\'t received money\nfrom anyone yet!',
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
