import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';
import 'buildWidgets.dart';

class ImagePickerModal extends StatefulWidget {
  const ImagePickerModal({super.key});

  @override
  State<ImagePickerModal> createState() => _ImagePickerModalState();
}

class _ImagePickerModalState extends State<ImagePickerModal> {
  late dynamic file;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 13, bottom: 20),
          child: Text(
            'Choose an image',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 15.sp,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Camera Picker
            ButtonPicker(
              icon: Icon(
                FontAwesomeIcons.camera,
                color: Colors.white,
                size: 20.sp,
              ),
              label: 'Camera',
              widgetColor: kSecondColor,
              function: () async {
                // Take Picture From Camera
                file = await _picker.pickImage(source: ImageSource.camera);

                // ignore: use_build_context_synchronously
                Navigator.pop(context, file);
              },
            ),

            // Image Picker
            ButtonPicker(
              icon: Icon(FontAwesomeIcons.image, color: Colors.white, size: 20.sp),
              label: 'Galerie',
              widgetColor: Colors.green,
              function: () async {
                // Take Picture From Gallery
                file = await _picker.pickImage(source: ImageSource.gallery);

                // ignore: use_build_context_synchronously
                Navigator.pop(context, file);
              },
            ),

            // Remove Image
            ButtonPicker(
              icon: Icon(FontAwesomeIcons.trash, color: Colors.white, size: 20.sp),
              label: 'Remove',
              widgetColor: Colors.grey,
              function: () {
                // Remove image

                file = 'remove';

                Navigator.pop(context, file);
              },
            ),
          ],
        ),
      ],
    );
  }
}
