import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/button.dart';
import 'package:wesh/widgets/textformfield.dart';

import '../../models/event.dart';
import '../../models/message.dart';
import '../../models/story.dart';

class Suggestions extends StatefulWidget {
  final String suggestionType;
  final String userReceiverId;
  final Message? messageToReply;
  final Event? eventAttached;
  final Story? storyAttached;

  const Suggestions({
    Key? key,
    required this.suggestionType,
    this.eventAttached,
    required this.userReceiverId,
    this.storyAttached,
    this.messageToReply,
  }) : super(key: key);

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
      appBar: MorphingAppBar(
        heroTag: 'suggestionsPageAppBar',
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
          'Suggestions',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(),
    );
  }
}
