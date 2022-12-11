import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
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
    await FireStorageMethods().uploadimageToProfilePic(context, profilePicturePath);

    // ignore: use_build_context_synchronously
    Navigator.push(
        context,
        SwipeablePageRoute(
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
            Text(
              'Ajouter une photo de profil',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
            ),
            SizedBox(height: 0.12.sw),

            // Profile Picture Picker
            InkWell(
              onTap: () async {
                // Pick image
                // TODO: check image format, size,...
                //
                //

                dynamic file = await showModalBottomSheet(
                  enableDrag: true,
                  isScrollControlled: true,
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: ((context) => Modal(
                        child: const ImagePickerModal(),
                      )),
                );

                if (file != null && file != 'remove') {
                  setState(() {
                    profilePicturePath = file.path;
                  });
                } else if (file == 'remove') {
                  setState(() {
                    profilePicturePath = '';
                  });
                }
              },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  (() {
                    if (profilePicturePath.contains('/data/user/')) {
                      return CircleAvatar(
                        radius: 70,
                        backgroundColor: kGreyColor,
                        backgroundImage: FileImage(File(profilePicturePath)),
                      );
                    }
                    return const CircleAvatar(
                      radius: 70,
                      backgroundColor: kGreyColor,
                      backgroundImage: AssetImage('assets/images/default_profile_picture.jpg'),
                    );
                  }()),
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: kSecondColor,
                      child: Icon(Icons.edit, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 0.24.sw),

            // Button Action : Update Profile Picture
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Button(
                    height: 0.12.sw,
                    width: double.infinity,
                    text: 'Confirmer',
                    color: kSecondColor,
                    onTap: () {
                      // Add Picture Profile

                      // AND Redirect to Add_Friends_And_Contacts_Page
                      updateProfilePicture(profilePicturePath);
                    },
                  ),
                ),
                SizedBox(height: 0.07.sw),

                // Ignore BUTTON : go to Add_Friends_And_Contacts_Page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        // Redirect to Add_Friends_And_Contacts_Page
                        updateProfilePicture('');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Ignorer',
                          style: TextStyle(fontSize: 14.sp, color: Colors.black54, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
            SizedBox(height: 0.12.sw),
          ],
        ),
      ),
    );
  }
}
