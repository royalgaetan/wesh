import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// DIVIDER WITH LABEL
class buildDividerWithLabel extends StatelessWidget {
  final String label;
  const buildDividerWithLabel({
    Key? key,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: Container(
            color: Colors.grey.shade300,
            height: 1.7,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(label),
        ),
        Flexible(
          flex: 1,
          child: Container(
            color: Colors.grey.shade300,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}

// DIVIDER
class buildDivider extends StatelessWidget {
  const buildDivider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(13),
      child: Divider(
        color: Colors.grey.shade700,
        height: 1.7,
      ),
    );
  }
}

// INTRODUCTION PAGE CONTENT
class buildIntroductionPageContent extends StatelessWidget {
  final String animationPath;
  final String title;
  final String description;

  const buildIntroductionPageContent(
      {Key? key,
      required this.animationPath,
      required this.title,
      required this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 2,
          child: Center(
            child: Lottie.asset(
              animationPath,
              width: double.infinity,
            ),
          ),
        ),
        // const SizedBox(
        //   height: 30,
        // ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }
}

// 