import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wesh/utils/constants.dart';

class DeleteDecision extends StatefulWidget {
  const DeleteDecision({Key? key}) : super(key: key);

  @override
  State<DeleteDecision> createState() => _DeleteDecisionState();
}

class _DeleteDecisionState extends State<DeleteDecision> {
  late XFile? file;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: const Text(
            'Confirmer la suppression',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 19,
            ),
          ),
        ),
        Column(
          children: [
            InkWell(
              onTap: () async {
                // Take Picture From Gallery

                Navigator.pop(context, true);
              },
              child: const ListTile(
                leading: Icon(
                  Icons.delete_forever_rounded,
                  color: kSecondColor,
                ),
                title: Text(
                  'Supprimer définitivement',
                  style: TextStyle(
                    color: kSecondColor,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context, false);
              },
              child: const ListTile(
                leading: Icon(Icons.remove_circle_outline_rounded),
                title: Text('Annuler'),
              ),
            )
          ],
        ),
      ],
    );
  }
}
