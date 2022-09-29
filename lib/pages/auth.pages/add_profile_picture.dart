import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/button.dart';
import 'package:wesh/widgets/imagepickermodal.dart';
import 'package:wesh/widgets/modal.dart';

import '../../services/firestorage.methods.dart';
import 'add_friends.dart';

class AddProfilePicture extends StatefulWidget {
  AddProfilePicture({Key? key}) : super(key: key);

  @override
  State<AddProfilePicture> createState() => _AddNameAndBirthdayPageState();
}

class _AddNameAndBirthdayPageState extends State<AddProfilePicture> {
  bool isLoading = false;
  String profilePicturePath = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  updateProfilePicture(String profilePicturePath) async {
    await FireStorageMethods()
        .uploadimageToProfilePic(context, profilePicturePath);

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddFriends(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Ajouter une photo de profil',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(
              height: 40,
            ),

            // Profile Picture Picker
            InkWell(
                onTap: () async {
                  // Pick image
                  // TODO: check image format, size,...
                  //
                  //

                  XFile? file = await showModalBottomSheet(
                    enableDrag: true,
                    isScrollControlled: true,
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: ((context) => Modal(
                          initialChildSize: .4,
                          maxChildSize: .4,
                          minChildSize: .4,
                          child: ImagePickerModal(),
                        )),
                  );

                  if (file != null) {
                    // final Directory directory =
                    //     await getApplicationDocumentsDirectory();
                    // final filename = 'profilepicture_${const Uuid().v4()}';
                    // final path = '${directory.path}/$filename.jpg';

                    // var res = file.saveTo(path).whenComplete(
                    //     () => print('File was saved correctly at $path'));

                    setState(() {
                      profilePicturePath = file.path;
                    });
                  } else if (file == null) {
                    setState(() {
                      profilePicturePath = '';
                    });
                  }
                },
                child: profilePicturePath == ''
                    ? const CircleAvatar(
                        radius: 100,
                        backgroundImage: AssetImage(
                            'assets/images/default_profile_picture.jpg'),
                      )
                    : CircleAvatar(
                        radius: 100,
                        backgroundImage: FileImage(
                          File(profilePicturePath),
                        ),
                      )),
            const SizedBox(
              height: 27,
            ),

            const SizedBox(
              height: 27,
            ),

            // Button Action : Update Profile Picture
            Column(
              children: [
                Button(
                  height: 50,
                  width: double.infinity,
                  text: 'Ajouter la photo de profil',
                  color: kSecondColor,
                  onTap: () {
                    // Add Picture Profile

                    // AND Redirect to Add_Friends_And_Contacts_Page
                    updateProfilePicture(profilePicturePath);
                  },
                ),
                const SizedBox(
                  height: 20,
                ),

                // Ignore BUTTON : go to Add_Friends_And_Contacts_Page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        // Redirect to Add_Friends_And_Contacts_Page
                        updateProfilePicture('');
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Ignorer',
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
