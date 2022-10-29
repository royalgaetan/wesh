import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/functions.dart';
import '../../utils/privacy_policy_data.dart';
import 'package:html/parser.dart' show parse;

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  @override
  Widget build(BuildContext context) {
    var document = parse(
        '<body>Hello world! <br> <a href="www.html5rocks.com">HTML5 rocks!');
    print(document.outerHtml);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0,
        elevation: 3,
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
          'Politique de confidentialité',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: CupertinoScrollbar(
        child: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.only(
                  top: 30, left: 15, right: 15, bottom: 40),
              child: Container()),
        ),
      ),
    );
  }
}
