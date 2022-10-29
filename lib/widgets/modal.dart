import 'package:flutter/material.dart';

class Modal extends StatelessWidget {
  final Widget child;
  final double? initialChildSize;
  final double? minChildSize;
  final double? maxChildSize;
  Modal(
      {required this.child,
      this.initialChildSize,
      this.minChildSize,
      this.maxChildSize});

  @override
  Widget build(BuildContext context) {
    return makeDismissible(
      context: context,
      child: DraggableScrollableSheet(
          initialChildSize: initialChildSize ?? .7,
          minChildSize: minChildSize ?? .7,
          maxChildSize: maxChildSize ?? .9,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  )),
              child: ListView(
                controller: scrollController,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: child,
                  )
                ],
              ),
            );
          }),
    );
  }
}

Widget makeDismissible({required Widget child, required BuildContext context}) {
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => Navigator.of(context).pop(),
    child: GestureDetector(
      child: child,
      onTap: () {},
    ),
  );
}
