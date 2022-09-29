import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerModal extends StatefulWidget {
  const ImagePickerModal({Key? key}) : super(key: key);

  @override
  State<ImagePickerModal> createState() => _ImagePickerModalState();
}

class _ImagePickerModalState extends State<ImagePickerModal> {
  late XFile? file;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: const Text(
            'Choisir une image',
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
                // Take Picture From Camera
                final XFile? file =
                    await _picker.pickImage(source: ImageSource.camera);

                Navigator.pop(context, file);
              },
              child: ListTile(
                leading: Icon(Icons.camera_alt_rounded),
                title: Text('À partir de la camera'),
              ),
            ),
            InkWell(
              onTap: () async {
                // Take Picture From Gallery
                final XFile? file =
                    await _picker.pickImage(source: ImageSource.gallery);

                Navigator.pop(context, file);
              },
              child: ListTile(
                leading: Icon(Icons.image),
                title: Text('À partir de la galerie'),
              ),
            ),
            InkWell(
              onTap: () {
                // Remove image
                file = null;

                Navigator.pop(context, file);
              },
              child: ListTile(
                leading: Icon(Icons.remove_circle_outline_rounded),
                title: Text('Retirer l\'image'),
              ),
            )
          ],
        ),
      ],
    );
  }
}
