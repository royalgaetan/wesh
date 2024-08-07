// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_number/phone_number.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:telephony/telephony.dart';
import 'package:validators/sanitizers.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/buildWidgets.dart';
import 'package:wesh/widgets/textformfield.dart';
import '../../models/event.dart';
import '../../models/message.dart';
import '../../models/story.dart';
import '../../utils/functions.dart';
import '../../widgets/eventview.dart';
import '../../widgets/modal.dart';

class SendPayment extends StatefulWidget {
  final String filetype;
  final String userReceiverId;
  final String? discussionId;
  final Message? messageToReply;
  final Event? eventAttached;
  final Story? storyAttached;

  const SendPayment({
    super.key,
    required this.filetype,
    required this.userReceiverId,
    this.eventAttached,
    this.storyAttached,
    this.messageToReply,
    this.discussionId,
  });

  @override
  State<SendPayment> createState() => _SendPaymentState();
}

class _SendPaymentState extends State<SendPayment> with WidgetsBindingObserver {
  //
  bool? needPermission;
  //
  final Telephony telephony = Telephony.instance;
  StreamSubscription? ussdStreamSubscription;
  String smsMessage = '';

  int tabSelected = 0;
  TextEditingController emptyController = TextEditingController();
  TextEditingController paymentMessageController = TextEditingController();
  TextEditingController receiverPhoneNumberController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();
  //
  String phoneCode = '242';
  String regionCode = 'CG';
  String countryName = '';

  //
  String paymentMethodSelected = '';
  String transactionId = '';

  Future createPaymentMessage() async {
    log('Money sent !');

    await sendMessage(
      context: context,
      userReceiverId: widget.userReceiverId,
      messageType: 'payment',
      discussionId: widget.discussionId ?? '',
      eventId: widget.eventAttached != null ? widget.eventAttached!.eventId : '',
      storyId: widget.storyAttached != null ? widget.storyAttached!.storyId : '',
      messageTextValue: paymentMessageController.text,
      messageCaptionText: '',
      voiceNotePath: '',
      imagePath: '',
      videoPath: '',
      musicPath: '',
      isPaymentMessage: true,
      amount: int.parse(amountController.text),
      paymentMethod: paymentMethodSelected,
      transactionId: transactionId,
      receiverPhoneNumber: receiverPhoneNumberController.text,
      messageToReplyId: widget.messageToReply != null ? widget.messageToReply?.messageId ?? '' : '',
      messageToReplySenderId: widget.messageToReply != null ? widget.messageToReply?.senderId ?? '' : '',
      messageToReplyType: widget.messageToReply != null ? widget.messageToReply?.type ?? '' : '',
      messageToReplyCaption: widget.messageToReply != null ? widget.messageToReply?.caption ?? '' : '',
      messageToReplyFilename: widget.messageToReply != null ? widget.messageToReply?.filename ?? '' : '',
      messageToReplyData: widget.messageToReply != null ? widget.messageToReply?.data ?? '' : '',
      messageToReplyThumbnail: widget.messageToReply != null ? widget.messageToReply?.thumbnail ?? '' : '',
    );

    if (!mounted) return;
    showSnackbar(context, 'Votre paiement s\'est bien effectué !', kSuccessColor);
    // Dismiss loader
    if (!mounted) return;
    Navigator.of(context).pop();
    // POP SCREEN
    if (!mounted) return;
    Navigator.pop(
      context,
    );
  }

  @override
  void initState() {
    super.initState();
    //
    requestPermission();
    //
    telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) async {
          // Handle Airtel Incoming Message
          log(
            'Message listen --> body: ${message.body}, address: ${message.address}, date: ${message.date}, id: ${message.id}, serviceCenterAddress: ${message.serviceCenterAddress}, subject: ${message.subject}, subscriptionId: ${message.subscriptionId}, type: ${message.type}',
          );

          if (message.address == '161' && paymentMethodSelected == airtelMoneyLabel) {
            // Dismiss loader
            if (!mounted) return;
            Navigator.of(context).pop();

            // Handle Failed Transaction
            String body = message.body ?? '';

            // Get Airtel Money Transaction ID
            String stringList1 = body.split(':')[1];
            transactionId = stringList1.split(' ')[0];
            log('transactionId: $transactionId');

            if (body.contains('votre transaction a echoue')) {
              log('ON ERROR TRANSACTION');
              if (!mounted) return;
              showSnackbar(context, 'An error occured! !', null);
              // Dismiss loader
              if (!mounted) return;
              Navigator.of(context).pop();
            }
            // Handle Successful Transaction
            else if (body.contains('Vous avez envoye')) {
              await createPaymentMessage();
            }
          }
        },
        listenInBackground: false);
  }

  Future requestPermission() async {
    if (await Permission.sms.request().isGranted) {
      setState(() {
        needPermission = false;
      });
    } else {
      setState(() {
        needPermission = true;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    // ignore: prefer_null_aware_operators
    ussdStreamSubscription != null ? ussdStreamSubscription?.cancel() : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MorphingAppBar(
        toolbarHeight: 46,
        scrolledUnderElevation: 0.0,
        heroTag: 'sendPaymentPageAppBar',
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
          'Envoyer de l\'argent',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: needPermission == null
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(50),
                height: 100,
                child: const CupertinoActivityIndicator(),
              ),
            )
          : needPermission == true
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Nous avons besoin d\'une permission pour continuer !',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black87, fontSize: 13.sp),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () async {
                        // Request for permission in Settings
                        await openAppSettings();
                      },
                      child: const Text('Accorder la permission'),
                    )
                  ],
                )
              : Form(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // FIELDS
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.only(top: 5, bottom: 0.12.sh, left: 15, right: 15),
                          children: [
                            // Add Payment Method
                            Column(children: [
                              BuildTextFormField(
                                controller: emptyController,
                                isReadOnly: true,
                                hintText: 'Mode de paiement',
                                icon: Icon(Icons.add_card_outlined, size: 22.sp),
                                validateFn: (_) {
                                  return;
                                },
                                onChanged: (value) async {
                                  return;
                                },
                              ),
                            ]),
                            // All Payment methods available
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  BuildPaymentMethodWidget(
                                    logoPath: mtnMobileMoneyLogo,
                                    label: mtnMobileMoneyLabel,
                                    isSelected: paymentMethodSelected == mtnMobileMoneyLabel ? true : false,
                                    onTap: () {
                                      if (paymentMethodSelected == mtnMobileMoneyLabel) {
                                        setState(() {
                                          paymentMethodSelected = '';
                                        });
                                      } else {
                                        setState(() {
                                          paymentMethodSelected = mtnMobileMoneyLabel;
                                        });
                                      }
                                    },
                                  ),
                                  BuildPaymentMethodWidget(
                                    logoPath: airtelMoneyLogo,
                                    label: airtelMoneyLabel,
                                    isSelected: paymentMethodSelected == airtelMoneyLabel ? true : false,
                                    onTap: () {
                                      if (paymentMethodSelected == airtelMoneyLabel) {
                                        setState(() {
                                          paymentMethodSelected = '';
                                        });
                                      } else {
                                        setState(() {
                                          paymentMethodSelected = airtelMoneyLabel;
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),

                            paymentMethodSelected.isNotEmpty
                                ? Container(
                                    margin: const EdgeInsets.only(top: 40, bottom: 20),
                                    child: BuildDividerWithLabel(label: 'Continuer avec $paymentMethodSelected'),
                                  )
                                : Container(),

                            // Payment Method OPTIONS
                            () {
                              // MTN Mobile Money || Airtel Money
                              if (paymentMethodSelected == mtnMobileMoneyLabel ||
                                  paymentMethodSelected == airtelMoneyLabel) {
                                return Column(
                                  children: [
                                    // MESSAGE TO REPLY || EVENT ATTACHED || STORY ATTACHED
                                    Visibility(
                                      visible: widget.messageToReply == null &&
                                              widget.eventAttached == null &&
                                              widget.storyAttached == null
                                          ? false
                                          : true,
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 0.1.sw, maxWidth: 0.7.sw),
                                        padding: const EdgeInsets.only(right: 5, bottom: 5),
                                        margin: const EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(255, 228, 227, 227),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: () {
                                          // Display Message to reply
                                          if (widget.messageToReply != null &&
                                              widget.eventAttached == null &&
                                              widget.storyAttached == null) {
                                            return Wrap(
                                              children: [
                                                getMessageToReplyGridPreview(
                                                  messageToReplyId: widget.messageToReply!.messageId,
                                                  messageToReplySenderId: widget.messageToReply!.senderId,
                                                  messageToReplyType: widget.messageToReply!.type,
                                                  messageToReplyCaption: widget.messageToReply!.caption,
                                                  messageToReplyFilename: widget.messageToReply!.filename,
                                                  messageToReplyData: widget.messageToReply!.data,
                                                  messageToReplyThumbnail: widget.messageToReply!.thumbnail,
                                                ),
                                              ],
                                            );
                                          }

                                          // Display Event Attached
                                          else if (widget.eventAttached != null &&
                                              widget.storyAttached == null &&
                                              widget.messageToReply == null) {
                                            return InkWell(
                                              borderRadius: BorderRadius.circular(20),
                                              onTap: () {
                                                // Show EventViewer Modal
                                                showModalBottomSheet(
                                                  enableDrag: true,
                                                  isScrollControlled: true,
                                                  context: context,
                                                  backgroundColor: Colors.transparent,
                                                  builder: ((context) => Modal(
                                                        minHeightSize: MediaQuery.of(context).size.height / 1.4,
                                                        maxHeightSize: MediaQuery.of(context).size.height,
                                                        child: EventView(eventId: widget.eventAttached!.eventId),
                                                      )),
                                                );
                                              },
                                              child: getEventGridPreview(
                                                  eventId: widget.eventAttached!.eventId, hasDivider: false),
                                            );
                                          }

                                          // Display Story Attached
                                          else if (widget.storyAttached != null &&
                                              widget.eventAttached == null &&
                                              widget.messageToReply == null) {
                                            return getStoryGridPreview(
                                                storyId: widget.storyAttached!.storyId, hasDivider: false);
                                          }

                                          return Container();
                                        }(),
                                      ),
                                    ),

                                    // Add Payment Message
                                    BuildTextFormField(
                                      controller: paymentMessageController,
                                      hintText: 'Ecrivez un message... (facultatif)',
                                      icon: Icon(Icons.messenger_outline_sharp, size: 22.sp),
                                      textInputType: TextInputType.text,
                                      validateFn: (_) {
                                        return;
                                      },
                                      onChanged: (value) async {
                                        return;
                                      },
                                    ),

                                    // Add Receiver Phone Number
                                    BuildTextFormField(
                                      controller: receiverPhoneNumberController,
                                      hintText: 'Ajouter le numéro du receveur',
                                      icon: Icon(Icons.contact_phone, size: 22.sp),
                                      textInputType: TextInputType.phone,
                                      validateFn: (_) {
                                        return;
                                      },
                                      onChanged: (value) async {
                                        return;
                                      },
                                    ),

                                    // Add Amount
                                    BuildTextFormField(
                                      controller: amountController,
                                      hintText: 'Ajouter le montant',
                                      icon: Icon(Icons.monetization_on_rounded, size: 22.sp),
                                      textInputType: TextInputType.number,
                                      validateFn: (_) {
                                        return;
                                      },
                                      onChanged: (value) async {
                                        return;
                                      },
                                    ),

                                    // Add Pin Code
                                    BuildTextFormField(
                                      controller: pinCodeController,
                                      hintText: 'Ajoutez votre code pin',
                                      icon: Icon(Icons.lock_outline_rounded, size: 22.sp),
                                      textInputType: TextInputType.number,
                                      validateFn: (_) {
                                        return;
                                      },
                                      onChanged: (value) async {
                                        return;
                                      },
                                    ),
                                  ],
                                );
                              }

                              // Default
                              return Container();
                              // return Container(
                              //   padding: const EdgeInsets.all(20),
                              //   height: 300,
                              //   child: const Center(
                              //     child: Text(
                              //       'Veuillez selectionner un mode de payment avant de continuer...',
                              //       textAlign: TextAlign.center,
                              //       style: TextStyle(
                              //         color: Colors.black54,
                              //       ),
                              //     ),
                              //   ),
                              // );
                            }(),
                          ],
                        ),

                        //
                      ),
                    ],
                  ),
                ),
      floatingActionButton:
          // [ACTION BUTTON] Add Event Button
          FloatingActionButton.extended(
        label: Text(
          'Envoyer',
          style: TextStyle(fontSize: 14.sp),
        ),
        foregroundColor: Colors.white,
        backgroundColor: kSecondColor,
        icon: Transform.translate(
          offset: const Offset(1, -1),
          child: Transform.rotate(
            angle: -math.pi / 4,
            child: Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 14.sp,
            ),
          ),
        ),
        onPressed: () async {
          // SEND MONEY
          // VIBRATE
          triggerVibration();

          // Main Error handler
          if (paymentMethodSelected.isEmpty) {
            // paymentMethodSelected error handler
            if (!mounted) return;
            showSnackbar(context, 'Veuillez selectionner un mode de paiement !', null);
            return;
          }

          // Handle Mobile Money && Airtel Money error
          if (paymentMethodSelected == mtnMobileMoneyLabel || paymentMethodSelected == airtelMoneyLabel) {
            if (receiverPhoneNumberController.text.isEmpty) {
              // Receiver Phone Number error handler
              showSnackbar(context, 'Veuillez entrer un numéro de téléphone valide !', null);
              return;
            }

            bool isValid = await PhoneNumberUtil().validate(receiverPhoneNumberController.text, regionCode: regionCode);

            if (isValid == false) {
              showSnackbar(context, 'Le numéro entré est incorrect !', null);
              return;
            }

            if (amountController.text.isEmpty || toInt(amountController.text) <= 0) {
              // Amount error handler
              showSnackbar(context, 'Veuillez entrer un montant correct !', null);
              return;
            }
            if (pinCodeController.text.isEmpty) {
              // Amount error handler
              showSnackbar(context, 'Veuillez entrer votre code PIN', null);
              return;
            }
          }

          // [CONTINUE...]

          // Continue with MTN Mobile Money
          // if (paymentMethodSelected == mtnMobileMoneyLabel) {
          //   // STEP 1: Set the root
          //   await UssdAdvanced.multisessionUssd(code: '*105#', subscriptionId: 2);

          //   // STEP 2: Set 1 (Send money)
          //   await UssdAdvanced.sendMessage('1');

          //   // STEP 3: Set 1 (to Mobile Money Subscriber)
          //   await UssdAdvanced.sendMessage('1');
          //   // STEP 4: Set PhoneNumber (Receiver Phone Number)
          //   await UssdAdvanced.sendMessage('$phoneCode${receiverPhoneNumberController.text}');

          //   // STEP 5: Set Amount (Transactional Amount)
          //   await UssdAdvanced.sendMessage(amountController.text);

          //   // STEP 6: Set PIN CODE (Keep it secret 😉)
          //   String? finalResponse = await UssdAdvanced.sendMessage(pinCodeController.text);
          //   log('Last answer 1: $finalResponse');

          //   // STEP 7: Set # - Go to Next
          //   String? nextFinalResponse = await UssdAdvanced.sendMessage('#');
          //   log('Last answer 2: $nextFinalResponse');
          //   UssdAdvanced.cancelSession();

          //   // Handle Last Answer
          //   if (finalResponse != null && finalResponse.contains('effectue avec succes')) {
          //     // Get MTN Mobile Money Transaction ID
          //     List<String> stringList = nextFinalResponse?.split(' ') ?? [];
          //     for (String st in stringList) {
          //       String ss = st.replaceAll('.', '');
          //       if (isNumeric(ss)) {
          //         transactionId = ss;
          //       }
          //     }
          //     log('transactionId: $transactionId');
          //     await createPaymentMessage();
          //   }

          //   // On error
          //   else if (finalResponse != null && !finalResponse.contains('effectue avec succes')) {
          //     if (!mounted) return;
          //     showSnackbar(context, 'An error occured! !', null);
          //     // Dismiss loader
          //     if (!mounted) return;
          //     Navigator.of(context).pop();
          //   }

          //   // Error Handler
          //   ussdStreamSubscription = UssdAdvanced.onEnd().listen(
          //     ((event) {
          //       // Dismiss loader
          //       if (!mounted) return;
          //       Navigator.of(context).pop();
          //       log('USSD MTN Mobile Money: $event');

          //       if (event!.contains('Check your accessibility')) {
          //         if (!mounted) return;
          //         showSnackbar(
          //             context,
          //             'Nous besoin d\'une permission pour continuer, aller dans Paramètres puis Accessibilité...',
          //             null);
          //         return;
          //       }

          //       if (event.contains('Numéro incorrect')) {
          //         if (!mounted) return;
          //         showSnackbar(context, 'Le numéro entré est incorrect !', null);
          //         return;
          //       }
          //       if (event.contains('Fonds insuffisants')) {
          //         if (!mounted) return;
          //         showSnackbar(context, 'Fonds insuffisants !', null);
          //         return;
          //       }
          //       if (event.contains('meme que le numéro du destinataire')) {
          //         if (!mounted) return;
          //         showSnackbar(context, 'Le numéro de l`\'expéditeur est le meme que le numéro du destinataire', null);
          //         return;
          //       }
          //       //
          //       else {
          //         if (!mounted) return;
          //         showSnackbar(context, 'An error occured! !', null);
          //         return;
          //       }
          //     }),
          //   );
          // }

          // Continue with Airtel Money
          // if (paymentMethodSelected == airtelMoneyLabel) {
          //   //
          //   showFullPageLoader(context: context, color: Colors.white);
          //   //

          //   // STEP 1: Set the root
          //   await UssdAdvanced.multisessionUssd(code: '*128#', subscriptionId: 2);

          //   // STEP 2: Set 2 (Send money/Retrieve Money)
          //   await UssdAdvanced.sendMessage('2');

          //   // STEP 3: Set 1 (Send money)
          //   await UssdAdvanced.sendMessage('1');

          //   // STEP 4: Set 1 (Airtel Money)
          //   await UssdAdvanced.sendMessage('1');

          //   // STEP 5: Set Phone Number (Receiver Phone Number)
          //   await UssdAdvanced.sendMessage(receiverPhoneNumberController.text);

          //   // STEP 6: Set Amount (Transactional Amount)
          //   await UssdAdvanced.sendMessage(amountController.text);

          //   // STEP 7: Set PIN CODE (Keep it secret 😉)
          //   await UssdAdvanced.sendMessage(pinCodeController.text);

          //   // STEP 8: Set 2 (Would you want to add this phoneNumber as favorite ? Set to NO !)
          //   await UssdAdvanced.sendMessage('2');
          //   UssdAdvanced.cancelSession();

          //   // STEP 9: Wait For Answer : listen to incoming messages

          //   // Error Handler
          //   ussdStreamSubscription = UssdAdvanced.onEnd().listen(
          //     ((event) {
          //       // Dismiss loader
          //       if (!mounted) return;
          //       Navigator.of(context).pop();
          //       log('USSD Airtel: $event');

          //       if (event!.contains('Check your accessibility')) {
          //         if (!mounted) return;
          //         showSnackbar(
          //             context,
          //             'Nous besoin d\'une permission pour continuer, aller dans Paramètres puis Accessibilité...',
          //             null);
          //         return;
          //       }
          //       if (event.contains('Transaction en cours')) {
          //         // Just wait for the transaction
          //       }

          //       if (!mounted) return;
          //       showSnackbar(context, 'An error occured! !', null);
          //       return;
          //     }),
          //   );
          // }
        },
      ),
    );
  }
}

class BuildPaymentMethodWidget extends StatelessWidget {
  final String logoPath;
  final String label;
  final bool isSelected;
  final Function() onTap;

  const BuildPaymentMethodWidget({
    super.key,
    required this.logoPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.04.sw),
            child: Column(
              children: [
                // Payment Method Logo
                Container(
                  height: 0.17.sw,
                  width: 0.17.sw,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: isSelected ? 2 : 1,
                        color: isSelected ? kSecondColor.withOpacity(0.5) : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: Container(
                      decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(logoPath),
                      fit: BoxFit.fitWidth,
                    ),
                  )),
                ),

                // Payment method label

                Text(
                  label.length <= 12 ? label : '${label.substring(0, 9)}...',
                  style: TextStyle(
                      color: isSelected ? kSecondColor : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : null,
                      fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
