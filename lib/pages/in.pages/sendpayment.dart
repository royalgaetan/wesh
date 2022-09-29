import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/button.dart';
import 'package:wesh/widgets/textformfield.dart';

class SendPayment extends StatefulWidget {
  final String filetype;
  final String uid;
  String? eventIdAttached;

  SendPayment(
      {Key? key,
      required this.filetype,
      this.eventIdAttached,
      required this.uid})
      : super(key: key);

  @override
  State<SendPayment> createState() => _SendPaymentState();
}

class _SendPaymentState extends State<SendPayment> {
  int tabSelected = 0;
  TextEditingController receiverPhoneNumberController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
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
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
            ),
          ),
          bottom: TabBar(
              onTap: (index) {
                setState(() {
                  tabSelected = index;
                });
              },
              indicatorColor: Colors.black,
              unselectedLabelColor: Colors.black,
              // labelPadding: EdgeInsets.only(top: 20),
              labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              labelColor: Colors.black,
              tabs: const [
                Tab(
                  text: 'Mobile Money',
                ),
                Tab(
                  text: 'Airtel Money',
                ),
              ]),
          title: const Text(
            'Envoyer de l\'argent',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // FIELDS
                Expanded(
                  child: ListView(
                    children: [
                      // Add Receiver Phone Number
                      buildTextFormField(
                        controller: receiverPhoneNumberController,
                        hintText: 'Ajouter le numéro du receveur',
                        icon: Icon(Icons.contact_phone),
                        textInputType: TextInputType.phone,
                        validateFn: (phoneNumber) {
                          if (phoneNumber!.isEmpty) {
                            return 'Veuillez entrer un numéro valide';
                          }
                          return null;
                        },
                      ),

                      // Add Amount
                      buildTextFormField(
                        controller: receiverPhoneNumberController,
                        hintText: 'Ajouter le montant',
                        icon: Icon(Icons.monetization_on_rounded),
                        textInputType: TextInputType.phone,
                        validateFn: (phoneNumber) {
                          if (phoneNumber!.isEmpty) {
                            return 'Veuillez entrer un montant valide';
                          }
                          return null;
                        },
                      ),

                      // Add Pin Code
                      buildTextFormField(
                        controller: receiverPhoneNumberController,
                        hintText: 'Ajouter votre code pin',
                        icon: Icon(Icons.lock_outline_rounded),
                        textInputType: TextInputType.number,
                        validateFn: (pincode) {
                          if (pincode!.isEmpty) {
                            return 'Veuillez entrer un code pin valide';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  //
                ),

                // SEND BUTTON
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Button(
                          text: 'Envoyer',
                          color: kSecondColor,
                          onTap: () {
                            // SEND MONEY

                            // THEN CREATE MESSGE

                            // POP SCREEN
                            Navigator.pop(
                              context,
                            );
                          },
                          height: 40,
                          width: 130,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
