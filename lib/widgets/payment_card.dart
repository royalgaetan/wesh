import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wesh/services/firestore.methods.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/buildWidgets.dart';
import 'package:wesh/widgets/payment_viewer_modal.dart';
import '../models/user.dart' as UserModel;
import '../models/payment.dart';
import '../utils/functions.dart';
import 'modal.dart';

class PaymentCard extends StatefulWidget {
  final Payment payment;
  const PaymentCard({Key? key, required this.payment}) : super(key: key);

  @override
  State<PaymentCard> createState() => _PaymentCardState();
}

class _PaymentCardState extends State<PaymentCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Show EventView Modal
        showModalBottomSheet(
          enableDrag: true,
          isScrollControlled: true,
          context: context,
          backgroundColor: Colors.transparent,
          builder: ((context) => Modal(
                minHeightSize: 300,
                child: PaymentViewerModal(paymentId: widget.payment.paymentId),
              )),
        );
      },
      child: FutureBuilder<UserModel.User?>(
          future: FirestoreMethods().getUser(widget.payment.userSenderId),
          builder: (context, snapshot) {
            // Handle error
            if (snapshot.hasError) {}

            // Handle data
            if (snapshot.hasData && snapshot.data != null) {
              UserModel.User? userSender = snapshot.data;
              return Container(
                padding: const EdgeInsets.all(10.0),
                margin: const EdgeInsets.only(top: 5, bottom: 5, right: 10),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Trailing
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: widget.payment.userSenderId == FirebaseAuth.instance.currentUser!.uid
                              ? CircleAvatar(
                                  radius: 0.06.sw,
                                  backgroundColor: Colors.green.shade300,
                                  child: Icon(FontAwesomeIcons.dollarSign, color: Colors.white, size: 19.sp),
                                )
                              : CircleAvatar(
                                  radius: 0.06.sw,
                                  backgroundColor: kGreyColor,
                                  backgroundImage: NetworkImage(userSender!.profilePicture),
                                ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // UserSender name
                              Wrap(
                                children: [
                                  Text(
                                    widget.payment.userSenderId == FirebaseAuth.instance.currentUser!.uid
                                        ? 'Moi'
                                        : userSender!.name,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 14.sp),
                                  ),
                                ],
                              ),

                              //  Payment Info
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: widget.payment.userReceiverId == FirebaseAuth.instance.currentUser!.uid
                                    ?
                                    //
                                    Text(
                                        'vous a envoyé ${widget.payment.amount}'
                                        ' ${getPaymentMethodDevise(widget.payment.paymentMethod)}',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black.withOpacity(0.6)),
                                      )
                                    //
                                    : Row(
                                        children: [
                                          Text(
                                            '${widget.payment.amount}'
                                            ' ${getPaymentMethodDevise(widget.payment.paymentMethod)}, à ',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black.withOpacity(0.6)),
                                          ),
                                          buildUserNameToDisplay(
                                            fontSize: 12.sp,
                                            userId: widget.payment.userReceiverId,
                                          )
                                        ],
                                      ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            // Loader
            return Container();
          }),
    );
  }
}
