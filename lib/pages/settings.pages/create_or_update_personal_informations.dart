// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:validators/validators.dart';
import '../../models/event.dart';
import '../../models/user.dart' as usermodel;
import '../../services/firestorage.methods.dart';
import '../../services/firestore.methods.dart';
import '../../services/internet_connection_checker.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/addtextmodal.dart';
import '../../widgets/buildWidgets.dart';
import '../../widgets/imagepickermodal.dart';
import '../../widgets/modal.dart';
import '../../widgets/textfieldcontainer.dart';

class CreateOrUpdatePersonalInformations extends StatefulWidget {
  final usermodel.User user;
  const CreateOrUpdatePersonalInformations({super.key, required this.user});

  @override
  State<CreateOrUpdatePersonalInformations> createState() => _CreateOrUpdatePersonalInformationsState();
}

class _CreateOrUpdatePersonalInformationsState extends State<CreateOrUpdatePersonalInformations> {
  bool isLoading = false;

  String profilePicture = '';
  TextEditingController usernameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController linkController = TextEditingController();

  int bioLimit = 180;

  @override
  void initState() {
    //
    super.initState();

    // init user personal informations
    profilePicture = widget.user.profilePicture;
    usernameController.text = widget.user.username;
    nameController.text = widget.user.name;
    bioController.text = widget.user.bio;
    linkController.text = widget.user.linkinbio;
  }

  @override
  void dispose() {
    //
    super.dispose();

    usernameController.dispose();
    nameController.dispose();
    bioController.dispose();
    linkController.dispose();
  }

  updateProfileWithPersonalInformations() async {
    bool result = false;

    showFullPageLoader(context: context);

    // Upload Profile Picture to Firestorage and getDownloadURL
    String downloadUrl = '';
    if (!profilePicture.contains('https://')) {
      downloadUrl = await FireStorageMethods.uploadimageToProfilePic(context, profilePicture);
      result = true;
    } else {
      downloadUrl = widget.user.profilePicture;
      result = true;
    }

    // ONLY IF PROFILE PICTURE HAS BEEN CORRECTLY UPLOADED
    if (downloadUrl.isNotEmpty) {
      if (widget.user.events != null && widget.user.events!.isNotEmpty) {
        // Get user birthday and update that

        Event? birthday = await FirestoreMethods.getEventByIdAsFuture(widget.user.events!.first);

        if (birthday != null) {
          Map<String, dynamic> eventToUpdate = Event(
            eventId: birthday.eventId,
            uid: FirebaseAuth.instance.currentUser!.uid,
            title: '${nameController.text}\'s birthday',
            caption: birthday.caption.trim(),
            type: birthday.type,
            link: birthday.link.trim(),
            location: birthday.location.trim(),
            trailing: birthday.trailing,
            createdAt: birthday.createdAt,
            modifiedAt: DateTime.now(),
            eventDurationType: '1DatEvent',
            eventDurations: [birthday.eventDurations[0]],
            color: birthday.color,
            status: '',
          ).toJson();

          log('Result: $result');
          if (!mounted) return;
          await FirestoreMethods.updateEvent(context, birthday.eventId, eventToUpdate);
          log('Birthday Event updated');
        }
      }

      // UPDATE AN EXISTING ONE
      if (widget.user.id.isNotEmpty && downloadUrl.isNotEmpty) {
        // Modeling an user with personal informations
        Map<String, dynamic> userFieldToUpdate = {
          'profilePicture': downloadUrl,
          'username': usernameController.text.trim(),
          'name': nameController.text.trim(),
          'bio': bioController.text.trim(),
          'linkinbio': linkController.text.trim(),
        };
        if (!mounted) return;
        result = await FirestoreMethods.updateUserWithSpecificFields(context, widget.user.id, userFieldToUpdate);

        log('Profile updated (with Personal informations)');
      }

      usermodel.User? user = await FirestoreMethods.getUserByIdAsFuture(FirebaseAuth.instance.currentUser!.uid);

      if (!mounted) return;
      Navigator.pop(context, user);
      setState(() {
        isLoading = false;
      });

      // Pop the Screen once profile updated
      if (result) {
        if (!mounted) return;
        Navigator.pop(context, user);

        if (!mounted) return;
        showSnackbar(context, 'Your profile has been updated successfully!', kSuccessColor);
      }
    } else {
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  Future<bool> onWillPopHandler(context) async {
    List result = await showModalDecision(
      context: context,
      header: 'Discard?',
      content: 'If you exit, you will lose all your changes',
      firstButton: 'Cancel',
      secondButton: 'Discard',
    );
    if (result[0] == true) {
      Navigator.pop(context);
    }
    return false;
  }

  handleCTAButton() async {
    // VIBRATE
    triggerVibration();

    // Update all personal informations
    setState(() {
      isLoading = true;
    });
    var isConnected = await InternetConnection.isConnected(context);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    if (isConnected) {
      log("Has connection: $isConnected");
      // CONTINUE
      // Verify username
      if (usernameController.text.isNotEmpty && usernameController.text.length > 4) {
        // Verify name
        if (nameController.text.isNotEmpty && nameController.text.length < 46) {
          //Verify Bio length: if set
          if (bioController.text.isNotEmpty && bioController.text.length > bioLimit) {
            showSnackbar(context, 'Your bio exceeds the $bioLimit character limit. Please shorten it.', null);
            return;
          }

          // Verify link: is set
          if (linkController.text.isNotEmpty && !isURL(linkController.text)) {
            showSnackbar(context, 'Please enter a valid link', null);
            return;
          }
          // CONTINUE
          updateProfileWithPersonalInformations();
          //
        } else {
          showSnackbar(context, 'Please enter your real name  (less than 45 characters)', null);
        }
      } else {
        showSnackbar(context, 'Please enter a username with more than 4 characters', null);
      }
    } else {
      log("Has connection: $isConnected");
      showSnackbar(context, 'Please check your internet connection', null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        onWillPopHandler(context);
      },
      child: Stack(
        children: [
          // MAIN CONTENT
          Scaffold(
            backgroundColor: Colors.white,
            appBar: MorphingAppBar(
              toolbarHeight: 46,
              scrolledUnderElevation: 0.0,
              heroTag: 'createOrUpdatePersonalInformationsPageAppBar',
              backgroundColor: Colors.white,
              titleSpacing: 0,
              elevation: 0,
              leading: IconButton(
                splashRadius: 0.06.sw,
                onPressed: () async {
                  //
                  bool result = await onWillPopHandler(context);
                  if (result) {
                    Navigator.pop(context);
                  } else {
                    //
                  }
                },
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.black,
                ),
              ),
              title: const Text(
                'Edit Profile',
                style: TextStyle(color: Colors.black),
              ),
              actions: [
                // CTA Button Create or Edit Reminder
                GestureDetector(
                  onTap: () {
                    handleCTAButton();
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 5, 15, 10),
                    child: Text(
                      'Save',
                      style: TextStyle(fontSize: 16.sp, color: kSecondColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Edit Profile Picture
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                                    profilePicture = (file as XFile).path;
                                  });
                                } else if (file == 'remove') {
                                  setState(() {
                                    profilePicture = '';
                                  });
                                }
                              },
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Hero(
                                    tag: 'setting_profile_picture_tag_${widget.user.id}',
                                    child: (() {
                                      if (profilePicture.contains('https://')) {
                                        return BuildCachedNetworkImage(
                                          url: profilePicture,
                                          radius: 0.17.sw,
                                          backgroundColor: kGreyColor,
                                          paddingOfProgressIndicator: 20,
                                        );
                                      } else if (profilePicture.contains('/data/user/')) {
                                        return CircleAvatar(
                                          radius: 0.17.sw,
                                          backgroundColor: kGreyColor,
                                          backgroundImage: FileImage(File(profilePicture)),
                                        );
                                      }
                                      return CircleAvatar(
                                        radius: 0.17.sw,
                                        backgroundColor: kGreyColor,
                                        backgroundImage: const AssetImage(defaultProfilePicture),
                                      );
                                    }()),
                                  ),
                                  Transform.translate(
                                    offset: const Offset(-2, -2),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 0.04.sw,
                                      child: Padding(
                                        padding: const EdgeInsets.all(3),
                                        child: CircleAvatar(
                                          backgroundColor: kSecondColor,
                                          radius: 0.04.sw,
                                          child: Padding(
                                            padding: const EdgeInsets.all(3),
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 12.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),

                    // Edit username
                    TextformContainer(
                      onTap: () async {
                        // Show AddTextModal
                        var textresult = await showModalBottomSheet(
                          enableDrag: true,
                          isScrollControlled: true,
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: ((context) => Scaffold(
                                backgroundColor: Colors.transparent,
                                body: Modal(
                                  minHeightSize: 190,
                                  maxHeightSize: 190,
                                  child: AddTextModal(
                                      checkUsername: true,
                                      textfieldMaxLines: 1,
                                      textfieldMaxLength: 45,
                                      hintText: 'Enter your username...',
                                      modalTitle: 'Add a username',
                                      initialText: usernameController.text),
                                ),
                              )),
                        );

                        if (textresult != null) {
                          setState(() {
                            usernameController.text = (textresult as String).trim();
                          });
                        }
                      },
                      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.alternate_email_rounded,
                                color: Colors.grey.shade600,
                                size: 10.sp,
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              Text(
                                'Username',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            usernameController.text.isEmpty ? 'Enter your username...' : usernameController.text,
                            style: TextStyle(
                                fontSize: 13.sp,
                                color: usernameController.text.isEmpty ? Colors.black54 : Colors.black),
                          ),
                        ],
                      ),
                    ),

                    // Edit name
                    const SizedBox(
                      height: 20,
                    ),
                    TextformContainer(
                      onTap: () async {
                        // Show AddTextModal
                        var textresult = await showModalBottomSheet(
                          enableDrag: true,
                          isScrollControlled: true,
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: ((context) => Scaffold(
                                backgroundColor: Colors.transparent,
                                body: Modal(
                                  minHeightSize: 190,
                                  maxHeightSize: 190,
                                  child: AddTextModal(
                                      textfieldMaxLines: 1,
                                      textfieldMaxLength: 45,
                                      hintText: 'Enter your real name...',
                                      modalTitle: 'Add a name',
                                      initialText: nameController.text),
                                ),
                              )),
                        );

                        if (textresult != null) {
                          setState(() {
                            nameController.text = (textresult as String).trim();
                          });
                        }
                      },
                      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: Colors.grey.shade600,
                                size: 10.sp,
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              Text(
                                'Name',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            nameController.text.isEmpty ? 'Enter your real name...' : nameController.text,
                            style: TextStyle(
                                fontSize: 13.sp, color: nameController.text.isEmpty ? Colors.black54 : Colors.black),
                          ),
                        ],
                      ),
                    ),

                    // Edit bio
                    const SizedBox(
                      height: 20,
                    ),
                    TextformContainer(
                      onTap: () async {
                        // Show AddTextModal
                        var textresult = await showModalBottomSheet(
                          enableDrag: true,
                          isScrollControlled: true,
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: ((context) => Scaffold(
                                backgroundColor: Colors.transparent,
                                body: Modal(
                                  minHeightSize: 190,
                                  maxHeightSize: 190,
                                  child: AddTextModal(
                                      textfieldMinLines: 3,
                                      textfieldMaxLines: 3,
                                      textfieldMaxLength: bioLimit,
                                      keyboardType: TextInputType.multiline,
                                      hintText: 'Enter your bio...',
                                      modalTitle: 'Add a bio',
                                      initialText: bioController.text),
                                ),
                              )),
                        );

                        if (textresult != null) {
                          setState(() {
                            bioController.text = (textresult as String).trim();
                          });
                        }
                      },
                      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.tag,
                                color: Colors.grey.shade600,
                                size: 10.sp,
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              Text(
                                'Bio',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            bioController.text.isEmpty ? 'Enter your bio...' : bioController.text,
                            style: TextStyle(
                                fontSize: 13.sp, color: bioController.text.isEmpty ? Colors.black54 : Colors.black),
                          ),
                        ],
                      ),
                    ),

                    // Edit Link
                    const SizedBox(
                      height: 20,
                    ),
                    TextformContainer(
                      onTap: () async {
                        // Show AddTextModal
                        var textresult = await showModalBottomSheet(
                          enableDrag: true,
                          isScrollControlled: true,
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: ((context) => Scaffold(
                                backgroundColor: Colors.transparent,
                                body: Modal(
                                  minHeightSize: 190,
                                  maxHeightSize: 190,
                                  child: AddTextModal(
                                      keyboardType: TextInputType.url,
                                      textfieldMaxLines: 1,
                                      textfieldMaxLength: 45,
                                      checkLink: true,
                                      hintText: 'Enter a link',
                                      modalTitle: 'Add a link',
                                      initialText: linkController.text),
                                ),
                              )),
                        );

                        if (textresult != null) {
                          setState(() {
                            linkController.text = (textresult as String).trim();
                          });
                        }
                      },
                      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.link,
                                color: Colors.grey.shade600,
                                size: 8.sp,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Link',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            linkController.text.isEmpty ? 'Add a link...' : formatUrlToSlug(linkController.text),
                            style: TextStyle(
                                fontSize: 13.sp, color: linkController.text.isEmpty ? Colors.black54 : Colors.black),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 80,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // LOADER
          isLoading
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.4),
                  child: Center(
                    child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.white),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
