import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wesh/models/payment.dart';

import '../services/firestore.methods.dart';
import '../utils/constants.dart';
import '../utils/functions.dart';
import 'buildWidgets.dart';

class PaymentViewerModal extends StatefulWidget {
  final String paymentId;
  const PaymentViewerModal({super.key, required this.paymentId});

  @override
  State<PaymentViewerModal> createState() => _PaymentViewerModalState();
}

class _PaymentViewerModalState extends State<PaymentViewerModal> {
  // Copy message : only Text message
  copyInfo(String info, String messageToDisplay) async {
    await Clipboard.setData(ClipboardData(text: info));
    // ignore: use_build_context_synchronously
    showSnackbar(context, messageToDisplay, kSuccessColor);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Payment>(
      stream: FirestoreMethods().getPaymentByPaymentId(widget.paymentId),
      builder: (context, snapshot) {
        // Handle error
        if (snapshot.hasError) {
          debugPrint('error: ${snapshot.error}');
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 100),
            child: Center(
              child: buildErrorWidget(onWhiteBackground: true),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          Payment payment = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //  HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Transaction',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 17.sp,
                      ),
                    ),
                  ],
                ),

                // Transaction Players
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: buildAvatarAndUsername(
                        uidPoster: payment.userSenderId,
                        radius: 20,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.arrow_forward_ios_outlined, size: 18, color: Colors.green.shade300),
                    ),
                    Expanded(
                      child: buildAvatarAndUsername(
                        uidPoster: payment.userReceiverId,
                        radius: 20,
                      ),
                    ),
                  ],
                ),

                // Payment Method Row
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10.sp,
                      backgroundColor: Colors.transparent,
                      backgroundImage: AssetImage(getPaymentMethodLogo(payment.paymentMethod)),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      payment.paymentMethod,
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
                    )
                  ],
                ),

                // Amount Row
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.dollarSign,
                      size: 13.sp,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      '${payment.amount}' ' ${getPaymentMethodDevise(payment.paymentMethod)}',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: kSecondColor),
                    )
                  ],
                ),

                // Transaction ID Row
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Copy Transaction ID
                    copyInfo(payment.transactionId, 'Le numero de la transaction a bien été copié !');
                  },
                  child: Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.hashtag,
                        size: 13.sp,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        payment.transactionId,
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
                      )
                    ],
                  ),
                ),

                // Receiver Phone Number Row
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Copy Receiver Phone Number
                    copyInfo(payment.receiverPhoneNumber, 'Le numero a bien été copié !');
                  },
                  child: Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.addressCard,
                        size: 13.sp,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        payment.receiverPhoneNumber,
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
                      )
                    ],
                  ),
                ),

                // Transaction Created Row
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.clock,
                      size: 13.sp,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Réalisée ${getTimeAgoLongForm(payment.createdAt)}',
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
                    )
                  ],
                ),
              ],
            ),
          );
        }

        // Diplay Loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade400,
                child: Container(
                    margin: const EdgeInsets.only(bottom: 2), width: 200, height: 19, color: Colors.grey.shade400),
              ),
              const SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade400,
                    child: Container(
                        margin: const EdgeInsets.only(bottom: 2), width: 250, height: 12, color: Colors.grey.shade400),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade400,
                    child: Container(
                        margin: const EdgeInsets.only(bottom: 2), width: 250, height: 12, color: Colors.grey.shade400),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade400,
                    child: Container(
                        margin: const EdgeInsets.only(bottom: 2), width: 250, height: 12, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ],
          );
        }

        return Container();
      },
    );
  }
}
