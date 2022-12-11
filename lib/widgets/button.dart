import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Button extends StatefulWidget {
  final String text;
  final double height;
  final double width;
  final double? fontsize;
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

  final VoidCallback onTap;

  const Button({
    required this.text,
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
      child: InkWell(
        onTapDown: (_) {
          // set iOS-style on Tap down
          debugPrint('Button tap down !');
          setState(() {
            containerOpacity = 0.7;
            onPressedColor = Colors.white.withOpacity(0.2);
          });
        },
        onTapUp: (_) {
          // set iOS-style on Tap down
          debugPrint('Button tap up !');
          setState(() {
            containerOpacity = 1;
            onPressedColor = Colors.transparent;
          });
        },
        onTapCancel: () {
          // set iOS-style on Tap down
          debugPrint('Button tap cancelled !');
          setState(() {
            containerOpacity = 1;
            onPressedColor = Colors.transparent;
          });
        },
        borderRadius: BorderRadius.circular(50),
        onTap: widget.onTap,
        child: Stack(
          children: [
            Container(
              height: widget.height,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(50),
                  border: widget.isBordered != null
                      ? Border.all(color: Colors.grey.shade300, width: 1)
                      : Border.all(color: Colors.white, width: 0)),
              child: Center(
                child: FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    textBaseline: TextBaseline.ideographic,
                    children: [
                      widget.prefixIsLoading != null && widget.prefixIsLoading == true
                          ? FittedBox(
                              child: SizedBox(
                                width: 0.05.sw,
                                height: 0.05.sw,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: widget.prefixIconColor ?? Colors.white,
                                ),
                              ),
                            )
                          : widget.prefixIcon != null
                              ? Icon(
                                  widget.prefixIcon,
                                  size: widget.prefixIconSize != null ? widget.prefixIconSize!.sp : 14.sp,
                                  color: widget.prefixIconColor ?? Colors.white,
                                )
                              : Container(),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        widget.text,
                        style: TextStyle(
                            color: widget.fontColor ?? Colors.white,
                            fontSize: widget.fontsize ?? 14.sp,
                            fontWeight: FontWeight.w500),
                      ),
                      widget.suffixIcon != null
                          ? const SizedBox(
                              width: 5,
                            )
                          : Container(),
                      widget.suffixIcon != null
                          ? Icon(
                              widget.suffixIcon,
                              size: widget.suffixIconSize ?? 14.sp,
                              // ignore: prefer_if_null_operators
                              color: widget.suffixIconColor != null ? widget.suffixIconColor : Colors.white,
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),

            // onPressed Cover
            Container(
              height: widget.height,
              // width: width,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

              decoration: BoxDecoration(
                color: onPressedColor,
                borderRadius: BorderRadius.circular(50),
              ),
            )
          ],
        ),
      ),
    );
  }
}
