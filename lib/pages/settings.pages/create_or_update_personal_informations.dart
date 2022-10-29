import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../models/user.dart' as UserModel;
import '../../providers/user.provider.dart';
import '../../services/firestorage.methods.dart';
import '../../services/firestore.methods.dart';
import '../../services/internet_connection_checker.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/addtextmodal.dart';
import '../../widgets/imagepickermodal.dart';
import '../../widgets/modal.dart';
import '../../widgets/textfieldcontainer.dart';

class CreateOrUpdatePersonalInformations extends StatefulWidget {
  final UserModel.User user;
  const CreateOrUpdatePersonalInformations({super.key, required this.user});

  @override
  State<CreateOrUpdatePersonalInformations> createState() =>
      _CreateOrUpdatePersonalInformationsState();
}

class _CreateOrUpdatePersonalInformationsState
    extends State<CreateOrUpdatePersonalInformations> {
  bool isLoading = false;

  String profilePicture = '';
  TextEditingController usernameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController linkController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
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
    // TODO: implement dispose
    super.dispose();

    usernameController.dispose();
    nameController.dispose();
    bioController.dispose();
    linkController.dispose();
  }

  updateProfileWithPersonalInformations() async {
    bool result = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CupertinoActivityIndicator(radius: 16, color: Colors.white),
      ),
    );

    // Upload Profile Picture to Firestorage and getDownloadURL
    String downloadUrl = '';
    if (!profilePicture.contains('https://')) {
      downloadUrl = await FireStorageMethods()
          .uploadimageToProfilePic(context, profilePicture);
    } else {
      downloadUrl = widget.user.profilePicture;
    }

    // Get user birthday and update that
    bool resultAboutUserBirthdayUpdate = false;
    Event? birthday = await Provider.of<UserProvider>(context, listen: false)
        .getEventById(widget.user.events![0]);
    Map<String, Object?> eventToUpdate = Event(
      eventId: birthday!.eventId,
      uid: FirebaseAuth.instance.currentUser!.uid,
      title: 'Anniversaire de ${nameController.text}',
      caption: birthday.caption,
      type: birthday.type,
      link: birthday.link,
      location: birthday.location,
      trailing: birthday.trailing,
      createdAt: birthday.createdAt,
      modifiedAt: DateTime.now(),
      startDateTime: birthday.startDateTime,
      endDateTime: birthday.endDateTime,
      color: birthday.color,
      status: '',
    ).toJson();

    resultAboutUserBirthdayUpdate = await FirestoreMethods()
        .updateEvent(context, birthday.eventId, eventToUpdate);
    debugPrint('Birthday Event updated');

    // UPDATE AN EXISTING ONE
    if (widget.user != null &&
        downloadUrl.isNotEmpty &&
        resultAboutUserBirthdayUpdate) {
      // Modeling an user with personal informations
      Map<String, Object?> userFieldToUpdate = {
        'profilePicture': downloadUrl,
        'username': usernameController.text,
        'name': nameController.text,
        'bio': bioController.text,
        'linkinbio': linkController.text,
      };

      // ignore: use_build_context_synchronously
      result = await FirestoreMethods().updateUserWithSpecificFields(
          context, widget.user.id, userFieldToUpdate);
      debugPrint('Profile updated (with Personal informations)');
    }

    UserModel.User? user =
        // ignore: use_build_context_synchronously
        await Provider.of<UserProvider>(context, listen: false)
            .getFutureUserById(FirebaseAuth.instance.currentUser!.uid);
    // ignore: use_build_context_synchronously

    // ignore: use_build_context_synchronously
    Navigator.pop(
      context,
    );
    // Pop the Screen once profile updated
    if (result) {
      Navigator.pop(context, user);

      // ignore: use_build_context_synchronously
      showSnackbar(context, 'Votre profil à bien été modifié !', kSuccessColor);
    }
  }

  Future<bool> onWillPopHandler(context) async {
    bool? result = await showModalDecision(
      context: context,
      header: 'Abandonner ?',
      content: 'Si vous sortez, vous allez perdre toutes vos modifications',
      firstButton: 'Annuler',
      secondButton: 'Abandonner',
    );
    if (result == true) {
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
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          titleSpacing: 0,
          elevation: 0,
          leading: IconButton(
            splashRadius: 25,
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
                            // TODO: check image format, size,...
                            //
                            //

                            dynamic file = await showModalBottomSheet(
                              enableDrag: true,
                              isScrollControlled: true,
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: ((context) => Modal(
                                    initialChildSize: .3,
                                    maxChildSize: .3,
                                    minChildSize: .3,
                                    child: const ImagePickerModal(),
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
                                tag:
                                    'setting_profile_picture_tag_${widget.user.id}',
                                child: (() {
                                  if (profilePicture.contains('https://')) {
                                    return CircleAvatar(
                                      radius: 100,
                                      backgroundColor: kGreyColor,
                                      backgroundImage: NetworkImage(
                                        profilePicture,
                                      ),
                                    );
                                  } else if (profilePicture
                                      .contains('/data/user/')) {
                                    return CircleAvatar(
                                      radius: 100,
                                      backgroundColor: kGreyColor,
                                      backgroundImage:
                                          FileImage(File(profilePicture)),
                                    );
                                  }
                                  return const CircleAvatar(
                                    radius: 100,
                                    backgroundColor: kGreyColor,
                                    backgroundImage: AssetImage(
                                        'assets/images/default_profile_picture.jpg'),
                                  );
                                }()),
                              ),
                              Transform.translate(
                                offset: const Offset(0, -10),
                                child: const CircleAvatar(
                                  radius: 20,
                                  backgroundColor: kSecondColor,
                                  child: Icon(Icons.edit, color: Colors.white),
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
                          splashRadius: 22,
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
                                      maxChildSize: .3,
                                      initialChildSize: .3,
                                      minChildSize: .3,
                                      child: AddTextModal(
                                          checkUsername: true,
                                          textfieldMaxLines: 1,
                                          textfieldMaxLength: 45,
                                          hintText:
                                              'Votre nom d\'utilisateur ici...',
                                          modalTitle:
                                              'Ajouter un nom d\'utilisateur',
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
                          icon: const Icon(Icons.edit),
                        ),
                        hintText: 'Ajouter nom d\'utilisateur ici...',
                        contentPadding: const EdgeInsets.all(20),
                        label: const Text('Nom d\'utilisateur'),
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
                          splashRadius: 22,
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
                                      maxChildSize: .3,
                                      initialChildSize: .3,
                                      minChildSize: .3,
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
                          icon: const Icon(Icons.edit),
                        ),
                        hintText: 'Ajouter nom ici...',
                        contentPadding: const EdgeInsets.all(20),
                        label: const Text('Nom'),
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
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          splashRadius: 22,
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
                                      maxChildSize: .3,
                                      initialChildSize: .3,
                                      minChildSize: .3,
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
                          icon: const Icon(Icons.edit),
                        ),
                        hintText: 'Ajouter une bio ici...',
                        contentPadding: const EdgeInsets.all(20),
                        label: const Text('Bio'),
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
                          splashRadius: 22,
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
                                      maxChildSize: .3,
                                      initialChildSize: .3,
                                      minChildSize: .3,
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
                          icon: const Icon(Icons.edit),
                        ),
                        hintText: 'Ajouter un lien ici...',
                        contentPadding: const EdgeInsets.all(20),
                        label: const Text('Lien'),
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
            // Update all personal informations
            setState(() {
              isLoading = true;
            });
            var isConnected = await InternetConnection().isConnected(context);
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
            if (isConnected) {
              debugPrint("Has connection : $isConnected");
              // CONTINUE

              // Verify username
              if (usernameController.text.isNotEmpty &&
                  usernameController.text.length > 4) {
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
                showSnackbar(
                    context,
                    'Veuillez entrer un nom d\'utilisateur de plus de 4 caractères',
                    null);
              }
            } else {
              debugPrint("Has connection : $isConnected");
              // ignore: use_build_context_synchronously
              showSnackbar(
                  context, 'Veuillez vérifier votre connexion internet', null);
            }
          },
        ),
      ),
    );
  }
}
