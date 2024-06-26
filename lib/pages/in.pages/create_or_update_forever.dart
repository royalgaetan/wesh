import 'dart:math';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/models/forever.dart';
import 'package:wesh/pages/in.pages/storiesViewer.dart';
import 'package:wesh/widgets/storyselector.dart';
import '../../models/stories_handler.dart';
import '../../models/story.dart';
import '../../services/firestore.methods.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/buildWidgets.dart';
import '../../widgets/textformfield.dart';
import '../../models/user.dart' as usermodel;

class CreateOrUpdateForeverPage extends StatefulWidget {
  final Forever? forever;
  const CreateOrUpdateForeverPage({super.key, this.forever});

  @override
  State<CreateOrUpdateForeverPage> createState() => _CreateOrUpdateForeverPageState();
}

class _CreateOrUpdateForeverPageState extends State<CreateOrUpdateForeverPage> {
  TextEditingController titleForeverController = TextEditingController();
  List<Story> foreverStoriesList = [];
  List foreverStoriesListWithStoryIdOnly = [];
  Story? selectedStory;

  @override
  void initState() {
    //
    super.initState();
    titleForeverController.text = widget.forever == null ? '' : widget.forever!.title;

    foreverStoriesListWithStoryIdOnly = widget.forever == null ? [] : widget.forever!.stories;
  }

  @override
  void dispose() {
    //
    super.dispose();

    titleForeverController.dispose();
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

  createOrUpdateForever() async {
    bool result = false;

    showFullPageLoader(context: context);

    // CREATE A NEW ONE
    if (widget.forever == null) {
      // Modeling an forever
      Map<String, dynamic> forever = Forever(
        foreverId: '',
        title: titleForeverController.text,
        uid: FirebaseAuth.instance.currentUser!.uid,
        stories: foreverStoriesListWithStoryIdOnly,
        modifiedAt: DateTime.now(),
        createdAt: DateTime.now(),
      ).toJson();

      //  Update Firestore Forevers Table
      result = await FirestoreMethods.createForever(context, FirebaseAuth.instance.currentUser!.uid, forever);
      debugPrint('Forever created (+notification) !');
    }

    // UPDATE AN EXISTING ONE

    if (widget.forever != null) {
      // Modeling a forever

      Map<String, dynamic> foreverToUpdate = Forever(
        foreverId: widget.forever!.foreverId,
        title: titleForeverController.text,
        uid: FirebaseAuth.instance.currentUser!.uid,
        stories: foreverStoriesListWithStoryIdOnly,
        modifiedAt: DateTime.now(),
        createdAt: widget.forever!.createdAt,
      ).toJson();
      // ignore: use_build_context_synchronously
      result = await FirestoreMethods.updateForever(context, widget.forever!.foreverId, foreverToUpdate);
      debugPrint('Forever updated');
    }

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    // Pop the Screen once forever created/updated
    if (result) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      showSnackbar(
          context,
          widget.forever == null ? 'Votre forever à bien été crée !' : 'Votre forever à bien été modifié !',
          kSuccessColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await onWillPopHandler(context);
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: MorphingAppBar(
            heroTag: 'foreverPageAppBar',
            backgroundColor: Colors.white,
            titleSpacing: 0,
            elevation: 0,
            leading: IconButton(
              splashRadius: 0.06.sw,
              onPressed: () async {
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
            actions: [
              widget.forever != null && widget.forever!.uid == FirebaseAuth.instance.currentUser!.uid
                  ? IconButton(
                      splashRadius: 0.06.sw,
                      onPressed: () async {
                        // DELETE FOREVER

                        // Show Delete Decision Modal
                        List deleteDecision = await showModalDecision(
                          context: context,
                          header: 'Supprimer',
                          content: 'Voulez-vous supprimer définitivement ce forever et tout ce qu\'il contient ?',
                          firstButton: 'Annuler',
                          secondButton: 'Supprimer',
                        );

                        if (deleteDecision[0] == true) {
                          // Delete forever...
                          // ignore: use_build_context_synchronously
                          bool result = await FirestoreMethods.deleteForever(
                              context, widget.forever!.foreverId, FirebaseAuth.instance.currentUser!.uid);
                          if (result) {
                            debugPrint('Forever deleted !');

                            // ignore: use_build_context_synchronously
                            Navigator.pop(
                              context,
                            );

                            // ignore: use_build_context_synchronously
                            showSnackbar(context, 'Votre forever à bien été supprimé !', kSecondColor);
                          }
                        }
                      },
                      icon: const Icon(
                        Icons.delete_rounded,
                        color: kSecondColor,
                      ),
                    )
                  : Container(),
            ],
            title: Text(
              widget.forever == null ? 'Créer un forever' : 'Modifier le forever',
              style: const TextStyle(color: Colors.black),
            ),
            centerTitle: false,
          ),
          body: Padding(
            padding: const EdgeInsets.only(
              top: 20,
              bottom: 5,
              left: 10,
              right: 10,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // FIELDS

                  // Add Forever Name
                  buildTextFormField(
                    controller: titleForeverController,
                    hintText: 'Ajouter un titre à votre forever',
                    icon: Icon(FontAwesomeIcons.alignLeft, size: 19.sp),
                    validateFn: (title) {
                      return null;
                    },
                    onChanged: (value) async {
                      return await null;
                    },
                  ),

                  const buildDivider(),

                  // Add story inside forever
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 15, 5, 15),
                    child: Row(
                      children: [
                        Icon(FontAwesomeIcons.circleNotch, color: Colors.grey.shade600, size: 19.sp),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: Text('Stories', style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp)),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            //
                            showFullPageLoader(context: context, color: Colors.white);
                            //
                            usermodel.User? userPoster =
                                await FirestoreMethods.getUserByIdAsFuture(FirebaseAuth.instance.currentUser!.uid);

                            // Dismiss loader
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop();
                            if (userPoster != null) {
                              // ignore: use_build_context_synchronously
                              Story? selectedStory = await Navigator.push(
                                  context,
                                  SwipeablePageRoute(
                                    builder: (context) => StorySelector(userPoster: userPoster),
                                  ));

                              if (selectedStory != null) {
                                if (!foreverStoriesListWithStoryIdOnly.contains(selectedStory.storyId)) {
                                  setState(() {
                                    foreverStoriesListWithStoryIdOnly.add(selectedStory.storyId);
                                  });
                                  debugPrint('foreverStoriesList: ${foreverStoriesListWithStoryIdOnly.length}');
                                } else {
                                  // Handle:  The selected story already exists
                                  // ignore: use_build_context_synchronously
                                  showSnackbar(context, 'Cette story existe déjà dans ce forever', null);
                                }
                              }
                            }

                            // Redirect to Story selector Page and get the selected story
                          },
                          child: const Text('+ Ajouter'),
                        )
                      ],
                    ),
                  ),

                  // Grid : all forever Stories
                  foreverStoriesListWithStoryIdOnly.isNotEmpty
                      ? GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 4 / 5,
                          ),
                          itemCount: foreverStoriesListWithStoryIdOnly.length,
                          itemBuilder: (context, index) {
                            return FutureBuilder(
                              future: FirestoreMethods.getStoryByIdAsFuture(foreverStoriesListWithStoryIdOnly[index]),
                              builder: (context, AsyncSnapshot snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  Story storyGotten = snapshot.data;
                                  return GestureDetector(
                                    onTap: () async {
                                      //
                                      showFullPageLoader(context: context, color: Colors.white);
                                      //

                                      usermodel.User? userPoster = await FirestoreMethods.getUserByIdAsFuture(
                                          FirebaseAuth.instance.currentUser!.uid);

                                      // Dismiss loader
                                      // ignore: use_build_context_synchronously
                                      Navigator.of(context).pop();

                                      // Build Story Handler
                                      StoriesHandler storiesHandler = StoriesHandler(
                                        avatarPath: userPoster?.profilePicture ?? '',
                                        posterId: userPoster?.id ?? '',
                                        title: userPoster?.name ?? '',
                                        origin: 'singleStory',
                                        lastStoryDateTime: storyGotten.createdAt,
                                        stories: [storyGotten],
                                      );
                                      // Preview Story
                                      // ignore: use_build_context_synchronously
                                      context.pushTransparentRoute(StoriesViewer(
                                        indexInStoriesHandlerList: 0,
                                        storiesHandlerList: [storiesHandler],
                                      ));
                                    },
                                    child: buildStoryGridPreview(
                                        footer: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              splashRadius: 0.06.sw,
                                              onPressed: () async {
                                                // Remove Story from Forever

                                                // Show Delete Decision Modal
                                                List deleteDecision = await showModalDecision(
                                                  context: context,
                                                  header: 'Retirer',
                                                  content: 'Voulez-vous retirer cette story de ce forever ?',
                                                  firstButton: 'Annuler',
                                                  secondButton: 'Retirer',
                                                );

                                                if (deleteDecision[0] == true) {
                                                  debugPrint('Story to remove : $index');
                                                  setState(() {
                                                    foreverStoriesListWithStoryIdOnly.removeAt(index);
                                                  });
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.remove_circle_outlined,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        story: storyGotten),
                                  );
                                }

                                if (snapshot.hasError) {
                                  // Handle error
                                  debugPrint('error: ${snapshot.error}');
                                  return const Center(
                                    child: Text('Une erreur s\'est produite', style: TextStyle(color: Colors.white)),
                                  );
                                }

                                // Display CircularProgressIndicator
                                return const Center(
                                  child: CupertinoActivityIndicator(color: Colors.white60, radius: 15),
                                );
                              },
                            );
                          },
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 100,
                                width: double.infinity,
                                child: Center(
                                  child: Icon(
                                    Icons.not_interested_rounded,
                                    size: 50,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Votre Forever doit contenir au moins une Story !',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14.sp, color: Colors.black45),
                              ),
                            ],
                          ),
                        )
                ],
              ),
            ),
          ),
          floatingActionButton:
              // [ACTION BUTTON] Add Event Button
              FloatingActionButton.extended(
            label: Text(
              widget.forever == null ? 'Créer' : 'Modifier',
            ),
            foregroundColor: Colors.white,
            backgroundColor: kSecondColor,
            icon: Transform.translate(
              offset: const Offset(1, -1),
              child: widget.forever == null
                  ? const Icon(
                      Icons.add,
                      color: Colors.white,
                    )
                  : Transform.rotate(
                      angle: -pi / 4,
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                      ),
                    ),
            ),
            onPressed: () async {
              // VIBRATE
              triggerVibration();

              if (titleForeverController.text.isNotEmpty && titleForeverController.text.length < 45) {
                if (foreverStoriesListWithStoryIdOnly.isNotEmpty) {
                  // CREATE OR UPDATE FOREVER
                  debugPrint('creating/updating forever...');
                  createOrUpdateForever();
                } else {
                  // Stories List error handler
                  showSnackbar(context, 'Votre Forever doit contenir au moins une Story !', null);
                }
              } else {
                // Title error handler
                showSnackbar(context, 'Veuillez entrer un titre valide (inferieur à 45 caractères)', null);
              }
            },
          )),
    );
  }
}
