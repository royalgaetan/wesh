import 'package:flutter/material.dart';
import 'package:wesh/utils/constants.dart';

class ImageWrapper extends StatelessWidget {
  final String type;
  final String picture;
  final double? borderradius;
  final double? borderpadding;
  final Color? bordercolor;
  final Widget child;

  const ImageWrapper({
    required this.type,
    required this.picture,
    this.borderradius,
    this.bordercolor,
    this.borderpadding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Profile has no Stories
        if (type == 'noStories') {
          final imageProvider = AssetImage(picture);
          // showImageViewer(context, imageProvider,
          //     useSafeArea: true, swipeDismissible: true, onViewerDismissed: () {
          //   debugPrint("dismissed");
          // });
        }

        // Profile has Stories
        // ---> DISPLAY STORY VIEWER
      },
      child: Container(
        padding: EdgeInsets.all(borderpadding ?? 4),
        decoration: type != "noStories"
            ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: bordercolor ?? kSecondColor, width: borderradius ?? 3),
              )
            : null,
        child: child,
      ),
    );
  }
}
