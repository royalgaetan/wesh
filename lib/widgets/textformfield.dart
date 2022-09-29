import 'package:flutter/material.dart';
import 'package:wesh/utils/constants.dart';

// TEXT FORM FIELD
class buildTextFormField extends StatelessWidget {
  const buildTextFormField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.validateFn,
    this.textInputType,
  }) : super(key: key);

  final TextEditingController controller;
  final String hintText;
  final Widget icon;
  final String? Function(String?) validateFn;
  final TextInputType? textInputType;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: TextFormField(
          controller: controller,
          validator: validateFn,
          cursorColor: Colors.black,
          style: TextStyle(color: Colors.black, fontSize: 18),
          maxLines: 1,
          minLines: 1,
          autofocus: false,
          keyboardType: textInputType ?? TextInputType.text,
          decoration: InputDecoration(
            prefixIcon: icon,
            prefixIconColor: kSecondColor,
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
