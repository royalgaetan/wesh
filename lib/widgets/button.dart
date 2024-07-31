import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Button extends StatefulWidget {
  final String? text;
  final double height;
  final double width;
  final double? fontsize;
  final FontWeight? fontWeight;
  final Color? fontColor;
  final bool? isBordered;
  final Color color;
  final bool? prefixIsLoading;
  final IconData? prefixIcon;
  final Color? prefixIconColor;
  final double? prefixIconSize;
  final IconData? suffixIcon;
  final Color? suffixIconColor;
  final double? suffixIconSize;
  final Size? loaderIconSize;
  final String? shape;
  final bool? isCentered;

  final VoidCallback onTap;

  const Button({
    super.key,
    this.text,
    required this.height,
    required this.width,
    required this.color,
    required this.onTap,
    this.fontsize,
    this.isBordered,
    this.fontColor,
    this.prefixIcon,
    this.prefixIconColor,
    this.suffixIcon,
    this.suffixIconColor,
    this.prefixIconSize,
    this.suffixIconSize,
    this.prefixIsLoading,
    this.loaderIconSize,
    this.shape,
    this.isCentered,
    this.fontWeight,
  });

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  double containerOpacity = 1.0;
  Color onPressedColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: containerOpacity,
      child: GestureDetector(
        // onTapDown: (_) {
        //   // set iOS-style on Tap down
        //   debugPrint('Button tap down !');
        //   setState(() {
        //     containerOpacity = 0.7;
        //     onPressedColor = Colors.white.withOpacity(0.2);
        //   });
        // },
        // onTapUp: (_) {
        //   // set iOS-style on Tap down
        //   debugPrint('Button tap up !');
        //   setState(() {
        //     containerOpacity = 1;
        //     onPressedColor = Colors.transparent;
        //   });
        // },
        // onTapCancel: () {
        //   // set iOS-style on Tap down
        //   debugPrint('Button tap cancelled !');
        //   setState(() {
        //     containerOpacity = 1;
        //     onPressedColor = Colors.transparent;
        //   });
        // },
        onTap: widget.prefixIsLoading == true ? null : widget.onTap,
        child: Stack(
          children: [
            Container(
              height: widget.shape == 'inline' ? null : widget.height,
              width: widget.shape == 'inline' ? null : widget.width,
              padding:
                  widget.shape == 'inline' ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: widget.shape == 'inline'
                  ? null
                  : BoxDecoration(
                      color: widget.prefixIsLoading == true ? widget.color.withOpacity(0.7) : widget.color,
                      borderRadius: BorderRadius.circular(50),
                      border: widget.isBordered != null
                          ? Border.all(color: Colors.grey.shade300, width: 1)
                          : Border.all(color: Colors.white, width: 0)),
              child: Row(
                mainAxisAlignment: widget.isCentered == false ? MainAxisAlignment.start : MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                textBaseline: TextBaseline.ideographic,
                children: [
                  // PREFIX
                  widget.prefixIsLoading != null && widget.prefixIsLoading == true
                      ? FittedBox(
                          child: Container(
                            margin: EdgeInsets.only(right: widget.text != null ? 5 : 0),
                            width: widget.loaderIconSize?.height ?? 0.05.sw,
                            height: widget.loaderIconSize?.width ?? 0.05.sw,
                            child: RepaintBoundary(
                              child: CircularProgressIndicator(
                                  strokeWidth: 1.5, color: widget.prefixIconColor ?? Colors.white),
                            ),
                          ),
                        )
                      : widget.prefixIcon != null
                          ? Container(
                              margin: EdgeInsets.only(right: widget.text != null ? 5 : 0),
                              child: Icon(
                                widget.prefixIcon,
                                size: widget.prefixIconSize != null ? widget.prefixIconSize!.sp : 14.sp,
                                color: widget.prefixIconColor ?? Colors.white,
                              ),
                            )
                          : Container(),

                  // TEXT
                  Visibility(
                    visible: widget.text != null,
                    child: Text(
                      widget.text ?? '',
                      style: TextStyle(
                        color: widget.fontColor ?? Colors.white,
                        fontSize: widget.fontsize ?? 14.sp,
                        fontWeight: widget.fontWeight ?? FontWeight.w500,
                      ),
                    ),
                  ),

                  // SUFFIX
                  Visibility(
                    visible: widget.suffixIcon != null,
                    child: Container(
                      margin: EdgeInsets.only(right: widget.text != null ? 7 : 0),
                      child: Icon(
                        widget.suffixIcon,
                        size: widget.suffixIconSize ?? 14.sp,
                        // ignore: prefer_if_null_operators
                        color: widget.suffixIconColor != null ? widget.suffixIconColor : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // onPressed Cover
            Visibility(
              visible: widget.shape == null,
              child: Container(
                height: widget.height,
                // width: width,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

                decoration: BoxDecoration(
                  color: onPressedColor,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
