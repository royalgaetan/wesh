import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:validators/validators.dart';
import 'package:wesh/widgets/textformfield.dart';
import '../services/auth.methods.dart';
import '../utils/constants.dart';
import '../utils/functions.dart';
import 'button.dart';

class AddTextModal extends StatefulWidget {
  final String modalTitle;
  final String initialText;
  final String hintText;
  final int? textfieldMaxLines;
  final int? textfieldMinLines;
  final int? textfieldMaxLength;
  final bool? checkUsername;
  final bool? checkLink;
  final TextInputType? keyboardType;

  const AddTextModal({
    super.key,
    required this.modalTitle,
    required this.initialText,
    required this.hintText,
    this.textfieldMaxLines,
    this.textfieldMaxLength,
    this.checkUsername,
    this.checkLink,
    this.keyboardType,
    this.textfieldMinLines,
  });

  @override
  State<AddTextModal> createState() => _AddTextModalState();
}

class _AddTextModalState extends State<AddTextModal> {
  TextEditingController textController = TextEditingController();
  bool isUsernameUsed = false;

  @override
  void initState() {
    //
    super.initState();
    textController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    //
    super.dispose();
    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Modal Title
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 10, top: 7, bottom: 10),
          child: Text(
            widget.modalTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 17.sp,
            ),
          ),
        ),

        // Modal Field.s
        SizedBox(
          width: 1.sw,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: BuildTextFormField(
                  inputFormatters: widget.checkUsername != null && widget.checkUsername!
                      ? [
                          FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9_]')),
                        ]
                      : [],
                  controller: textController,
                  hintText: widget.hintText,
                  fontSize: 14.sp,
                  icon: Transform.translate(
                    offset: const Offset(0, 5),
                    child: Icon(widget.checkLink == true ? FontAwesomeIcons.link : FontAwesomeIcons.alignJustify,
                        size: 16.sp),
                  ),
                  maxLines: widget.textfieldMaxLines ?? 3,
                  minLines: widget.textfieldMinLines ?? 1,
                  maxLength: widget.textfieldMaxLength ?? 120,
                  inputBorder: InputBorder.none,
                  textInputType: widget.keyboardType,
                  validateFn: (text) {
                    return null;
                  },
                  onChanged: (text) async {
                    if (widget.checkUsername != null && widget.checkUsername!) {
                      textController.text = text!.toLowerCase();
                    }
                    bool isUsed = await AuthMethods.checkIfUsernameInUse(context, textController.text);
                    if (mounted) {
                      setState(() {
                        isUsernameUsed = isUsed;
                      });
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              widget.checkUsername != null && widget.checkUsername! && textController.text.isNotEmpty
                  ? Expanded(
                      flex: 1,
                      child: isUsernameUsed
                          ? const Icon(Icons.close, color: kSecondColor)
                          : const Icon(Icons.done, color: Colors.green),
                    )
                  : Container()
            ],
          ),
        ),
        const SizedBox(height: 7),

        // Modal ACTION BUTTON
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Button(
                text: 'Confirm',
                height: 0.11.sw,
                width: 0.30.sw,
                fontsize: 12.sp,
                fontColor: Colors.white,
                color: kSecondColor,
                prefixIcon: Icons.done,
                prefixIconColor: Colors.white,
                prefixIconSize: 16.sp,
                onTap: () async {
                  // Check username: handle error
                  if (widget.checkUsername != null && widget.checkUsername! && isUsernameUsed) {
                    showSnackbar(context, 'This username is already taken', null);
                    return;
                  }

                  // Check link: handle error
                  if (widget.checkLink != null &&
                      widget.checkLink! &&
                      textController.text.isNotEmpty &&
                      !isURL(textController.text)) {
                    showSnackbar(context, 'Please enter a valid link', null);
                    return;
                  }

                  // Give back data and pop the modal
                  Navigator.pop(context, textController.text);
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}
