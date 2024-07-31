import 'package:flutter/material.dart';

class TextformContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Function()? onTap;

  const TextformContainer({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.grey.shade100.withOpacity(.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: child,
      ),
    );
  }
}
