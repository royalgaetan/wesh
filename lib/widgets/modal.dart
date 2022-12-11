import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:widget_size/widget_size.dart';

class Modal extends StatefulWidget {
  final Widget child;
  final double? minHeightSize;
  final double? maxHeightSize;
  Modal({required this.child, this.minHeightSize, this.maxHeightSize});

  @override
  State<Modal> createState() => _ModalState();
}

class _ModalState extends State<Modal> {
  double initChildHeight = 200;
  BorderRadiusGeometry borderRadius = const BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(24.0),
  );

  @override
  Widget build(BuildContext context) {
    return makeDismissible(
      context: context,
      child: SlidingUpPanel(
        minHeight: widget.minHeightSize ?? initChildHeight,
        maxHeight: widget.maxHeightSize ?? initChildHeight,
        borderRadius: borderRadius,
        panelBuilder: (ScrollController scrollController) {
          return WidgetSize(
            onChange: (newSize) {
              setState(() {
                initChildHeight = newSize.height;
              });
              log('initChildHeight: ${newSize.height}');
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: Colors.white,
              ),
              child: Column(
                children: [
                  // ANCHOR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          margin: const EdgeInsets.only(top: 5, bottom: 5),
                          height: 6,
                          width: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.grey.shade400,
                          )),
                    ],
                  ),

                  // MAIN CONTENT
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: widget.child,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
