import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final double height;
  final double width;
  final double? fontsize;
  final Color? fontColor;
  final bool? isBordered;
  final Color color;
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
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        height: height,
        // width: width,
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(50),
            border: isBordered != null
                ? Border.all(color: Colors.grey.shade200, width: 2)
                : Border.all(color: Colors.white, width: 0)),
        child: Center(
          child: FittedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              textBaseline: TextBaseline.ideographic,
              children: [
                prefixIcon != null
                    ? Icon(
                        prefixIcon,
                        size: prefixIconSize != null ? prefixIconSize : 16,
                        color: prefixIconColor != null
                            ? prefixIconColor
                            : Colors.white,
                      )
                    : Container(),
                SizedBox(
                  width: 7,
                ),
                Text(
                  text,
                  style: TextStyle(
                      color: fontColor != null ? fontColor : Colors.white,
                      fontSize: fontsize != null ? fontsize : 16,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: 7,
                ),
                suffixIcon != null
                    ? Icon(
                        suffixIcon,
                        size: suffixIconSize != null ? suffixIconSize : 16,
                        color: suffixIconColor != null
                            ? suffixIconColor
                            : Colors.white,
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
