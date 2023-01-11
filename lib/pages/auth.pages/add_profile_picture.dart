import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/button.dart';
import 'package:wesh/widgets/imagepickermodal.dart';
import 'package:wesh/widgets/modal.dart';
import '../../services/firestorage.methods.dart';
import '../../utils/functions.dart';
import 'add_friends.dart';

class AddProfilePicture extends StatefulWidget {
  const AddProfilePicture({Key? key}) : super(key: key);

  @override
  State<AddProfilePicture> createState() => _AddNameAndBirthdayPageState();
}

class _AddNameAndBirthdayPageState extends State<AddProfilePicture> {
  bool isLoading = false;
  String profilePicturePath = '';
  @override
  void initState() {
    //
    super.initState();
  }

  updateProfilePicture(context, String profilePicturePath) async {
    //
    showFullPageLoader(context: context);
    //
    if (profilePicturePath.isEmpty) {
      // Redirect to ADD_FRIEND_PAGE
      Navigator.pop(context);
      Navigator.push(
          context,
          SwipeablePageRoute(
            builder: (context) => const AddFriends(),
          ));
    } else {
      String result = await FireStorageMethods.uploadimageToProfilePic(context, profilePicturePath);
      Navigator.pop(context);
      if (result.isNotEmpty) {
        // CONTINUE
        // Redirect to ADD_FRIEND_PAGE
        // ignore: use_build_context_synchronously
        Navigator.push(
            context,
            SwipeablePageRoute(
              builder: (context) => const AddFriends(),
            ));
      }
    }
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

                dynamic file = await showModalBottomSheet(
                  enableDrag: true,
                  isScrollControlled: true,
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: ((context) => const Modal(
                        minHeightSize: 200,
                        maxHeightSize: 200,
                        child: ImagePickerModal(),
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
                        radius: 0.25.sw,
                        backgroundColor: kGreyColor,
                        backgroundImage: FileImage(File(profilePicturePath)),
                      );
                    }
                    return CircleAvatar(
                      radius: 0.25.sw,
                      backgroundColor: kGreyColor,
                      backgroundImage: const AssetImage(defaultProfilePicture),
                    );
                  }()),
                  Transform.translate(
                    offset: const Offset(-5, -5),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 0.06.sw,
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: CircleAvatar(
                          backgroundColor: kSecondColor,
                          radius: 0.06.sw,
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 17.sp,
                            ),
                          ),
                        ),
                      ),
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

                      // AND Redirect to Add_Friends_Page
                      updateProfilePicture(context, profilePicturePath);
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
                        updateProfilePicture(context, '');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Plus tard',
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
