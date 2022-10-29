import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  }) : super(key: key);

  final TextEditingController controller;
  final String hintText;
  final Widget icon;
  final String? Function(String?) validateFn;
  final Future<String?> Function(String?) onChanged;
  final InputBorder? inputBorder;
  final TextInputType? textInputType;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: TextFormField(
              inputFormatters: inputFormatters,
              controller: controller,
              validator: validateFn,
              onChanged: onChanged,
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.black, fontSize: 18),
              maxLines: maxLines ?? 1,
              minLines: 1,
              autofocus: false,
              maxLength: maxLength,
              keyboardType: textInputType ?? TextInputType.text,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(right: 9),
                  child: icon,
                ),
                prefixIconColor: kSecondColor,
                border: inputBorder ?? InputBorder.none,
                hintText: hintText,
                counterText: '',
                hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
