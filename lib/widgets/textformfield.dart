import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wesh/utils/constants.dart';

// TEXT FORM FIELD
class buildTextFormField extends StatelessWidget {
  const buildTextFormField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.validateFn,
    required this.onChanged,
    this.textInputType,
    this.maxLines,
    this.maxLength,
    this.inputBorder,
    this.inputFormatters,
    this.isReadOnly,
    this.onTap,
    this.suffixIcon,
    this.padding,
    this.fontSize,
  }) : super(key: key);

  final TextEditingController controller;
  final String hintText;
  final Widget icon;
  final Widget? suffixIcon;
  final String? Function(String?) validateFn;
  final Future<String?> Function(String?) onChanged;
  final InputBorder? inputBorder;
  final TextInputType? textInputType;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool? isReadOnly;
  final Function()? onTap;
  final EdgeInsets? padding;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: padding ?? EdgeInsets.only(bottom: 0.02.sw),
              child: TextFormField(
                readOnly: isReadOnly ?? false,
                inputFormatters: inputFormatters,
                controller: controller,
                validator: validateFn,
                onChanged: onChanged,
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.black, fontSize: fontSize ?? 14.sp),
                maxLines: maxLines ?? 1,
                minLines: 1,
                autofocus: false,
                maxLength: maxLength,
                keyboardType: textInputType ?? TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(right: 0.02.sw, bottom: 6),
                    child: icon,
                  ),
                  prefixIconColor: kSecondColor,
                  suffixIcon: Padding(
                    padding: EdgeInsets.only(right: 0.06.sw, bottom: 6),
                    child: suffixIcon,
                  ),
                  suffixIconColor: Colors.black87,
                  border: inputBorder ?? InputBorder.none,
                  hintText: hintText,
                  counterText: '',
                  hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
