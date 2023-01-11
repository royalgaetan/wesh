import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
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
        bool resultAboutUserBirthdayUpdate = false;

        Event? birthday = await FirestoreMethods.getEventByIdAsFuture(widget.user.events!.first);

        if (birthday != null) {
          Map<String, dynamic> eventToUpdate = Event(
            eventId: birthday.eventId,
            uid: FirebaseAuth.instance.currentUser!.uid,
            title: 'Anniversaire de ${nameController.text}',
            caption: birthday.caption,
            type: birthday.type,
            link: birthday.link,
            location: birthday.location,
            trailing: birthday.trailing,
            createdAt: birthday.createdAt,
            modifiedAt: DateTime.now(),
            eventDurationType: '1DatEvent',
            eventDurations: [birthday.eventDurations[0]],
            color: birthday.color,
            status: '',
          ).toJson();

          log('CC: $result');
          // ignore: use_build_context_synchronously
          resultAboutUserBirthdayUpdate = await FirestoreMethods.updateEvent(context, birthday.eventId, eventToUpdate);
          log('Birthday Event updated');
        }
      }

      // UPDATE AN EXISTING ONE
      if (widget.user != null && downloadUrl.isNotEmpty) {
        // Modeling an user with personal informations
        Map<String, dynamic> userFieldToUpdate = {
          'profilePicture': downloadUrl,
          'username': usernameController.text,
          'name': nameController.text,
          'bio': bioController.text,
          'linkinbio': linkController.text,
        };
        // ignore: use_build_context_synchronously
        result = await FirestoreMethods.updateUserWithSpecificFields(context, widget.user.id, userFieldToUpdate);

        log('Profile updated (with Personal informations)');
      }

      usermodel.User? user = await FirestoreMethods.getUserByIdAsFuture(FirebaseAuth.instance.currentUser!.uid);

      // ignore: use_build_context_synchronously
      Navigator.pop(context, user);
      setState(() {
        isLoading = false;
      });

      // Pop the Screen once profile updated
      if (result) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context, user);

        // ignore: use_build_context_synchronously
        showSnackbar(context, 'Votre profil à bien été modifié !', kSuccessColor);
      }
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }

  Future<bool> onWillPopHandler(context) async {
    List result = await showModalDecision(
      context: context,
      header: 'Abandonner ?',
      content: 'Si vous sortez, vous allez perdre toutes vos modifications',
      firstButton: 'Annuler',
      secondButton: 'Abandonner',
    );
    if (result[0] == true) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await onWillPopHandler(context);
      },
      child: Stack(
        children: [
          // MAIN CONTENT
          Scaffold(
            backgroundColor: Colors.white,
            appBar: MorphingAppBar(
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
                    // ignore: use_build_context_synchronously
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
                'Modifier le profil',
                style: TextStyle(color: Colors.black),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Edit Profile Picture
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
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
                                        return buildCachedNetworkImage(
                                          url: profilePicture,
                                          radius: 0.25.sw,
                                          backgroundColor: kGreyColor,
                                          paddingOfProgressIndicator: 20,
                                        );
                                      } else if (profilePicture.contains('/data/user/')) {
                                        return CircleAvatar(
                                          radius: 0.25.sw,
                                          backgroundColor: kGreyColor,
                                          backgroundImage: FileImage(File(profilePicture)),
                                        );
                                      }
                                      return CircleAvatar(
                                        radius: 0.25.sw,
                                        backgroundColor: kGreyColor,
                                        backgroundImage: const AssetImage(defaultProfilePicture),
                                      );
                                    }()),
                                  ),
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
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 27,
                    ),

                    // Edit username
                    TextformContainer(
                      child: TextField(
                        controller: usernameController,
                        readOnly: true,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              splashRadius: 0.06.sw,
                              onPressed: () async {
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
                                              hintText: 'Votre nom d\'utilisateur ici...',
                                              modalTitle: 'Ajouter un nom d\'utilisateur',
                                              initialText: usernameController.text),
                                        ),
                                      )),
                                );

                                if (textresult != null) {
                                  setState(() {
                                    usernameController.text = textresult;
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.edit,
                                size: 16.sp,
                              ),
                            ),
                            hintText: 'Ajouter nom d\'utilisateur ici...',
                            hintStyle: TextStyle(fontSize: 13.sp),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            label: Text(
                              'Nom d\'utilisateur',
                              style: TextStyle(fontSize: 13.sp),
                            ),
                            border: InputBorder.none),
                      ),
                    ),

                    // Edit name
                    const SizedBox(
                      height: 20,
                    ),
                    TextformContainer(
                      child: TextField(
                        controller: nameController,
                        readOnly: true,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              splashRadius: 0.06.sw,
                              onPressed: () async {
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
                                              hintText: 'Votre nom ici...',
                                              modalTitle: 'Ajouter un nom',
                                              initialText: nameController.text),
                                        ),
                                      )),
                                );

                                if (textresult != null) {
                                  setState(() {
                                    nameController.text = textresult;
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.edit,
                                size: 16.sp,
                              ),
                            ),
                            hintText: 'Ajouter nom ici...',
                            hintStyle: TextStyle(fontSize: 13.sp),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            label: Text(
                              'Nom',
                              style: TextStyle(fontSize: 13.sp),
                            ),
                            border: InputBorder.none),
                      ),
                    ),

                    // Edit bio
                    const SizedBox(
                      height: 20,
                    ),
                    TextformContainer(
                      child: TextField(
                        controller: bioController,
                        readOnly: true,
                        maxLines: 3,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              splashRadius: 0.06.sw,
                              onPressed: () async {
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
                                              hintText: 'Votre bio ici...',
                                              modalTitle: 'Ajouter votre bio',
                                              initialText: bioController.text),
                                        ),
                                      )),
                                );

                                if (textresult != null) {
                                  setState(() {
                                    bioController.text = textresult;
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.edit,
                                size: 16.sp,
                              ),
                            ),
                            hintText: 'Ajouter une bio ici...',
                            hintStyle: TextStyle(fontSize: 13.sp),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            label: Text(
                              'Bio',
                              style: TextStyle(fontSize: 13.sp),
                            ),
                            border: InputBorder.none),
                      ),
                    ),

                    // Edit Link
                    const SizedBox(
                      height: 20,
                    ),
                    TextformContainer(
                      child: TextField(
                        controller: linkController,
                        readOnly: true,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              splashRadius: 0.06.sw,
                              onPressed: () async {
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
                                              checkLink: true,
                                              hintText: 'Votre lien ici...',
                                              modalTitle: 'Ajouter un lien',
                                              initialText: linkController.text),
                                        ),
                                      )),
                                );

                                if (textresult != null) {
                                  setState(() {
                                    linkController.text = textresult;
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.edit,
                                size: 16.sp,
                              ),
                            ),
                            hintText: 'Ajouter un lien ici...',
                            hintStyle: TextStyle(fontSize: 13.sp),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            label: Text(
                              'Lien',
                              style: TextStyle(fontSize: 13.sp),
                            ),
                            border: InputBorder.none),
                      ),
                    ),
                    const SizedBox(
                      height: 80,
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton:
                // [ACTION BUTTON] Add Event Button
                FloatingActionButton(
              foregroundColor: Colors.white,
              backgroundColor: kSecondColor,
              child: Transform.translate(
                  offset: const Offset(1, -1),
                  child: const Icon(
                    Icons.done,
                    color: Colors.white,
                  )),
              onPressed: () async {
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
                  log("Has connection : $isConnected");
                  // CONTINUE

                  // Verify username
                  if (usernameController.text.isNotEmpty && usernameController.text.length > 4) {
                    // Verify name
                    if (nameController.text.isNotEmpty) {
                      // CONTINUE
                      updateProfileWithPersonalInformations();
                    } else {
                      // ignore: use_build_context_synchronously
                      showSnackbar(context, 'Veuillez entrer votre vrai nom', null);
                    }
                  } else {
                    // ignore: use_build_context_synchronously
                    showSnackbar(context, 'Veuillez entrer un nom d\'utilisateur de plus de 4 caractères', null);
                  }
                } else {
                  log("Has connection : $isConnected");
                  // ignore: use_build_context_synchronously
                  showSnackbar(context, 'Veuillez vérifier votre connexion internet', null);
                }
              },
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
