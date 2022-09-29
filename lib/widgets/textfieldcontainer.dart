import 'package:flutter/material.dart';
import 'package:wesh/utils/constants.dart';

class TextformContainer extends StatelessWidget {
  final Widget child;

  const TextformContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: kGreyColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: child);
  }
}
