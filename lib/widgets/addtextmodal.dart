import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:validators/validators.dart';

import '../utils/constants.dart';
import '../utils/functions.dart';
import 'button.dart';
import 'textformfield.dart';

class AddTextModal extends StatefulWidget {
  final String modalTitle;
  final String initialText;
  final String hintText;
  final int? textfieldMaxLines;
  final int? textfieldMaxLength;
  final bool? checkUsername;
  final bool? checkLink;

  const AddTextModal({
    super.key,
    required this.modalTitle,
    required this.initialText,
    required this.hintText,
    this.textfieldMaxLines,
    this.textfieldMaxLength,
    this.checkUsername,
    this.checkLink,
  });

  @override
  State<AddTextModal> createState() => _AddTextModalState();
}

class _AddTextModalState extends State<AddTextModal> {
  TextEditingController textController = TextEditingController();
  bool isUsernameUsed = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    // TODO: implement dispose
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
          padding:
              const EdgeInsets.only(left: 15, right: 10, top: 13, bottom: 20),
          child: Text(
            widget.modalTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 19,
            ),
          ),
        ),

        // Modal Field.s
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: buildTextFormField(
                  inputFormatters: widget.checkUsername != null &&
                          widget.checkUsername!
                      ? [
                          FilteringTextInputFormatter.allow(RegExp("[a-z]")),
                        ]
                      : [],
                  controller: textController,
                  hintText: widget.hintText,
                  icon: const Icon(Icons.edit),
                  maxLines: widget.textfieldMaxLines ?? 3,
                  maxLength: widget.textfieldMaxLength ?? 120,
                  inputBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: kSecondColor)),
                  validateFn: (text) {
                    return null;
                  },
                  onChanged: (text) async {
                    bool isUsed = await checkIfUsernameInUse(
                        context, textController.text);
                    if (mounted) {
                      setState(() {
                        isUsernameUsed = isUsed;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              widget.checkUsername != null &&
                      widget.checkUsername! &&
                      textController.text.isNotEmpty
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
        const SizedBox(height: 5),

        // Modal ACTION BUTTON
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Button(
                text: 'Confirmer',
                height: 45,
                width: 150,
                fontsize: 16,
                fontColor: Colors.white,
                color: kSecondColor,
                prefixIcon: Icons.done,
                prefixIconColor: Colors.white,
                prefixIconSize: 22,
                onTap: () async {
                  // Check username : handle error
                  if (widget.checkUsername != null &&
                      widget.checkUsername! &&
                      isUsernameUsed) {
                    showSnackbar(
                        context, 'Ce nom d\'utilisateur est déjà pris', null);

                    return;
                  }

                  // Check link : handle error
                  if (widget.checkLink != null &&
                      widget.checkLink! &&
                      textController.text.isNotEmpty &&
                      !isURL(textController.text)) {
                    showSnackbar(
                        context, 'Veuillez entrer un lien correct', null);

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
