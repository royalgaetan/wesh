import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:story_view/widgets/story_view.dart';

class CustomStoryView {
  static StoryItem customText({
    required String title,
    required Color backgroundColor,
    Key? key,
    TextStyle? textStyle,
    double? minFontSize,
    double? maxFontSize,
    double? fontSize,
    bool shown = false,
    bool roundedTop = false,
    bool roundedBottom = false,
    EdgeInsetsGeometry? textOuterPadding,
    Duration? duration,
  }) {
    double contrast = ContrastHelper.contrast([
      backgroundColor.red,
      backgroundColor.green,
      backgroundColor.blue,
    ], [
      255,
      255,
      255
    ] /** white text */);

    return StoryItem(
      Container(
        key: key,

        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(roundedTop ? 8 : 0),
            bottom: Radius.circular(roundedBottom ? 8 : 0),
          ),
        ),
        alignment: Alignment.center,
        padding: textOuterPadding ??
            const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
        child: AutoSizeText(
          title,
          textAlign: title.length < 200 ? TextAlign.center : TextAlign.left,
          style: textStyle?.copyWith(
                color: contrast > 1.8 ? Colors.white : Colors.black,
                fontSize: fontSize ?? 18,
              ) ??
              TextStyle(
                color: contrast > 1.8 ? Colors.white : Colors.black,
                fontSize: fontSize ?? 18,
              ),
          minFontSize: minFontSize ?? 14,
          maxFontSize: maxFontSize ?? 40,
          maxLines: 12,
          overflow: TextOverflow.ellipsis,
        ),
        //color: backgroundColor,
      ),
      shown: shown,
      duration: duration ?? const Duration(seconds: 3),
    );
  }
}
