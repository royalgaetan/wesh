import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/button.dart';
import 'package:wesh/widgets/textformfield.dart';

import '../../models/event.dart';

class Suggestions extends StatefulWidget {
  final String suggestionType;
  final String uid;
  Event? eventAttached;

  Suggestions(
      {Key? key,
      required this.suggestionType,
      this.eventAttached,
      required this.uid})
      : super(key: key);

  @override
  State<Suggestions> createState() => _SuggestionsState();
}

class _SuggestionsState extends State<Suggestions> {
  int tabSelected = 0;
  TextEditingController receiverPhoneNumberController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();

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
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Suggestions',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(),
    );
  }
}
