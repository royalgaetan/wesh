import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:validators/validators.dart';
import 'package:wesh/models/event.dart';
import 'package:wesh/services/firestorage.methods.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/utils/functions.dart';
import 'package:wesh/widgets/buildWidgets.dart';
import 'package:wesh/widgets/datetimebutton.dart';
import 'package:wesh/widgets/imagepickermodal.dart';
import 'package:wesh/widgets/modal.dart';
import 'package:wesh/widgets/textformfield.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import '../../services/firestore.methods.dart';

class CreateOrUpdateEventPage extends StatefulWidget {
  Event? event;

  CreateOrUpdateEventPage({this.event});

  @override
  State<CreateOrUpdateEventPage> createState() =>
      _CreateOrUpdateEventPageState();
}

class _CreateOrUpdateEventPageState extends State<CreateOrUpdateEventPage> {
  TextEditingController nameEventController = TextEditingController();
  TextEditingController captionEventController = TextEditingController();
  TextEditingController linkEventController = TextEditingController();
  TextEditingController locationEventController = TextEditingController();
  late String eventType;
  late String coverEventController;
  late int eventColorIndexSelected;

  DateTime startDateTime = DateTime.now();
  DateTime endDateTime = DateTime.now();
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now();
  // .replacing(hour: startTime.hour + 2, minute: startTime.minute);

  final formKey = GlobalKey<FormState>();
  var isAllowedToContinue = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameEventController.text = widget.event == null ? '' : widget.event!.title;
    eventType = widget.event == null ? '' : widget.event!.type;

    captionEventController.text =
        widget.event == null ? '' : widget.event!.caption;

    linkEventController.text = widget.event == null ? '' : widget.event!.link;

    locationEventController.text =
        widget.event == null ? '' : widget.event!.location;

    coverEventController = widget.event == null ? '' : widget.event!.trailing;

    eventColorIndexSelected = widget.event == null ? 1 : widget.event!.color;

    startDateTime =
        widget.event == null ? DateTime.now() : widget.event!.startDateTime;
    endDateTime = widget.event == null
        ? DateTime.now().add(Duration(hours: 2))
        : widget.event!.endDateTime;

    startTime = widget.event == null
        ? TimeOfDay.now()
        : TimeOfDay.fromDateTime(widget.event!.startDateTime);
    // .replacing(hour: startDateTime.hour, minute: startDateTime.minute);
    endTime = widget.event == null
        ? TimeOfDay.now()
        : TimeOfDay.fromDateTime(widget.event!.endDateTime);
    // .replacing(hour: endDateTime.hour + 2, minute: endDateTime.minute);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    nameEventController.dispose();
    captionEventController.dispose();
    linkEventController.dispose();
    locationEventController.dispose();
  }

  createOrUpdateEvent() async {
    bool result = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CupertinoActivityIndicator(radius: 16, color: Colors.white),
      ),
    );

    DateTime finalStartDateTime = DateTime(
      startDateTime.year,
      startDateTime.minute,
      startDateTime.day,
      startTime.hour,
      startTime.minute,
    );

    DateTime finalEndDateTime = DateTime(
      startDateTime.year,
      startDateTime.minute,
      startDateTime.day,
      endTime.hour,
      endTime.minute,
    );

    // Upload event Cover to Firestorage and getDownloadURL
    String downloadUrl = await FireStorageMethods()
        .uploadimageToEventCover(context, coverEventController);

    // CREATE A NEW ONE
    if (widget.event == null) {
      // Modeling an event
      Map<String, Object?> event = Event(
        eventId: '',
        uid: FirebaseAuth.instance.currentUser!.uid,
        title: nameEventController.text,
        caption: captionEventController.text,
        type: eventType,
        link: linkEventController.text,
        location: locationEventController.text,
        trailing: downloadUrl,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
        startDateTime: finalStartDateTime,
        endDateTime: finalEndDateTime,
        color: eventColorIndexSelected,
        status: '',
      ).toJson();

      //  Update Firestore Event Table
      result = await FirestoreMethods()
          .createEvent(context, FirebaseAuth.instance.currentUser!.uid, event);
      debugPrint('Event created (+notification) !');
    }

    // UPDATE AN EXISTING ONE

    if (widget.event != null) {
      // Modeling an event

      Map<String, Object?> eventToUpdate = Event(
        eventId: widget.event!.eventId,
        uid: FirebaseAuth.instance.currentUser!.uid,
        title: nameEventController.text,
        caption: captionEventController.text,
        type: eventType,
        link: linkEventController.text,
        location: locationEventController.text,
        trailing: downloadUrl,
        createdAt: widget.event!.createdAt,
        modifiedAt: DateTime.now(),
        startDateTime: finalStartDateTime,
        endDateTime: finalEndDateTime,
        color: eventColorIndexSelected,
        status: '',
      ).toJson();

      result = await FirestoreMethods()
          .updateEvent(context, widget.event!.eventId, eventToUpdate);
      debugPrint('Event updated (+Related reminders)');
    }

    Navigator.pop(
      context,
    );
    // Pop the Screen once event created/updated
    if (result) {
      Navigator.pop(
        context,
      );

      showSnackbar(
          context,
          widget.event == null
              ? 'Votre évenement à bien été crée !'
              : 'Votre évenement à bien été modifié !',
          kSuccessColor);
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
            actions: [
              widget.event != null &&
                      widget.event!.uid ==
                          FirebaseAuth.instance.currentUser!.uid
                  ? IconButton(
                      splashRadius: 25,
                      onPressed: () async {
                        // DELETE EVENT

                        // Show Delete Decision Modal
                        bool? deleteDecision = await showModalDecision(
                          context: context,
                          header: 'Supprimer',
                          content:
                              'Voulez-vous supprimer définitivement cet évenement ?',
                          firstButton: 'Annuler',
                          secondButton: 'Supprimer',
                        );

                        if (deleteDecision == true) {
                          // Delete event...
                          // ignore: use_build_context_synchronously
                          bool result = await FirestoreMethods().deleteEvent(
                              context,
                              widget.event!.eventId,
                              FirebaseAuth.instance.currentUser!.uid);
                          if (result) {
                            debugPrint('Event deleted !');

                            // ignore: use_build_context_synchronously
                            Navigator.pop(
                              context,
                            );

                            // ignore: use_build_context_synchronously
                            showSnackbar(
                                context,
                                'Votre évenement à bien été supprimé !',
                                kSecondColor);
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
              widget.event == null
                  ? 'Créer un évenement'
                  : 'Modifier l\'évenement',
              style: const TextStyle(color: Colors.black),
            ),
            centerTitle: false,
          ),
          body: ListView(
            padding: const EdgeInsets.only(
              top: 20,
              bottom: 5,
              left: 10,
              right: 10,
            ),
            children: [
              // FIELDS

              // Add Event Name
              buildTextFormField(
                controller: nameEventController,
                hintText: 'Ajouter le nom de l\'évenement',
                icon: const Icon(FontAwesomeIcons.splotch),
                validateFn: (eventName) {
                  return null;
                },
                onChanged: (value) async {
                  return await null;
                },
              ),

              // Add Event Caption
              buildTextFormField(
                controller: captionEventController,
                hintText: 'Ajouter la description de l\'évenement',
                icon: const Icon(FontAwesomeIcons.filePen),
                validateFn: (eventCaption) {
                  return null;
                },
                onChanged: (value) async {
                  return await null;
                },
              ),

              // Add Event Type
              InkWell(
                onTap: () async {
                  // Pick event type from a Dialog
                  String? selectedEventType = await showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 20),
                              const Text(
                                'Choisissez un type d\'événement',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 19),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                height: 300,
                                child: ListView.builder(
                                  itemCount: eventAvailableTypeList.length,
                                  itemBuilder: (context, index) => ListTile(
                                    leading: CircleAvatar(
                                        backgroundImage: AssetImage(
                                            'assets/images/eventtype.icons/${eventAvailableTypeList[index].key}.png')),
                                    horizontalTitleGap: 20,
                                    title: Text(
                                      eventAvailableTypeList[index].name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onTap: () {
                                      // Pop the modal picker and get back selected event type
                                      Navigator.pop(
                                        context,
                                        eventAvailableTypeList[index].key,
                                      );
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );

                  if (selectedEventType != null) {
                    setState(() {
                      eventType = selectedEventType;
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 13, 5, 13),
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.heart, color: Colors.grey.shade600),
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Text(
                          eventType.isEmpty
                              ? 'Type d\'événement'
                              : getEventTitle(eventType),
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const buildDivider(),

              // Add Event Link
              buildTextFormField(
                controller: linkEventController,
                hintText: 'Ajouter un lien à l\'évenement',
                icon: const Icon(FontAwesomeIcons.link),
                validateFn: (eventLink) {
                  return null;
                },
                onChanged: (value) async {
                  return await null;
                },
              ),

              // Add Event Location
              buildTextFormField(
                controller: locationEventController,
                hintText: 'Ajouter le lieu de l\'évenement',
                icon: const Icon(FontAwesomeIcons.locationDot),
                validateFn: (eventLocation) {
                  return null;
                },
                onChanged: (value) async {
                  return await null;
                },
              ),

              // Add Event Trailing
              InkWell(
                onTap: () async {
                  // Show Contact Viewer Modal
                  dynamic file = await showModalBottomSheet(
                    enableDrag: true,
                    isScrollControlled: true,
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: ((context) => Modal(
                          initialChildSize: .3,
                          maxChildSize: .3,
                          minChildSize: .3,
                          child: ImagePickerModal(),
                        )),
                  );

                  if (file != null && file != 'remove') {
                    final Directory directory =
                        await getApplicationDocumentsDirectory();
                    final filename = 'eventCover_${Uuid().v4()}';
                    final path = '${directory.path}/$filename.jpg';

                    var res = file.saveTo(path).whenComplete(
                        () => debugPrint('File was saved correctly at $path'));

                    setState(() {
                      coverEventController = path;
                    });
                  } else if (file == 'remove') {
                    setState(() {
                      coverEventController = '';
                    });

                    debugPrint('No file selected !');
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 5, 5),
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.image, color: Colors.grey.shade600),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Text(
                          'Ajouter une couverture',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 18),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),

                      // Case 1
                      coverEventController.contains('https://')
                          ? Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image:
                                        NetworkImage(widget.event!.trailing)),
                              ),
                            )
                          : Container(),

                      // Case 2
                      coverEventController == '' &&
                              !coverEventController.contains('https://') &&
                              !coverEventController.contains('/data/user/')
                          ? Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage(eventType.isNotEmpty
                                        ? 'assets/images/eventtype.icons/${eventAvailableTypeList.singleWhere((element) => element.key == eventType).key}.png'
                                        : 'assets/images/eventtype.icons/other.png')),
                              ),
                            )
                          : Container(),

                      // Case 3
                      !coverEventController.contains('https://') &&
                              coverEventController.contains('/data/user/')
                          ? Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(
                                    File(coverEventController),
                                  ),
                                ),
                              ),
                            )
                          : Container(),

                      //
                    ],
                  ),
                ),
              ),

              const buildDivider(),

              // Add Event Date
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 5, 5),
                child: Row(
                  children: [
                    Icon(FontAwesomeIcons.calendarPlus,
                        color: Colors.grey.shade600),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Text(
                        'Ajouter une date',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 18),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    DateTimeButton(
                      date: startDateTime,
                      type: 'date',
                      onTap: () async {
                        // Pick Date
                        DateTime? newDate = await pickDate(context: context);

                        if (newDate == null) {
                          setState(() {
                            isAllowedToContinue = false;
                          });
                        } else {
                          setState(() {
                            startDateTime = newDate;
                            debugPrint("Event Date is:  $startDateTime");
                            isAllowedToContinue = true;
                          });
                        }
                      },
                    )
                  ],
                ),
              ),

              // Add Event Hours
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 25, 5, 1),
                child: Row(
                  children: [
                    // Add  Event Start Time
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          const Text('Heure de début'),
                          const SizedBox(
                            height: 5,
                          ),
                          DateTimeButton(
                            timeOfDay: startTime,
                            type: 'time',
                            onTap: () async {
                              // Pick start time
                              Navigator.of(context).push(
                                showPicker(
                                  context: context,
                                  value: startTime,
                                  is24HrFormat: true,
                                  iosStylePicker: true,
                                  unselectedColor: Colors.black38,
                                  accentColor: Colors.black87,
                                  cancelText: 'Annuler',
                                  hourLabel: 'heures',
                                  minuteLabel: 'minutes',
                                  onChange: (timePicked) {
                                    setState(() {
                                      startTime = timePicked;
                                    });
                                    // debugPrint(dateTime);
                                    debugPrint("Start Time is: $startTime");
                                  },
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    // Add Event End Time
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          const Text('Heure de fin'),
                          const SizedBox(
                            height: 5,
                          ),
                          DateTimeButton(
                            date: endDateTime,
                            timeOfDay: endTime,
                            type: 'time',
                            onTap: () async {
                              // Pick end time
                              Navigator.of(context).push(
                                showPicker(
                                  context: context,
                                  value: endTime,
                                  is24HrFormat: true,
                                  iosStylePicker: true,
                                  unselectedColor: Colors.black38,
                                  accentColor: Colors.black87,
                                  cancelText: 'Annuler',
                                  hourLabel: 'heures',
                                  minuteLabel: 'minutes',
                                  onChange: (timePicked) {
                                    setState(() {
                                      endTime = timePicked;
                                    });
                                    if (isEndTimeSuperiorThanStartTime(
                                        startTime, endTime)) {
                                      setState(() {
                                        endTime = timePicked;
                                      });
                                    } else {
                                      showSnackbar(
                                          context,
                                          'Votre heure de fin doit être en avance sur l\'heure de debut',
                                          null);
                                    }

                                    // debugPrint(dateTime);
                                    debugPrint("End Time is: $endTime");
                                  },
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const buildDivider(),

              // Add Event Color
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 5, 100),
                child: Row(
                  children: [
                    Icon(FontAwesomeIcons.palette, color: Colors.grey.shade600),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Text(
                        'Ajouter une couleur',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 18),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Row(
                      children: List<Widget>.generate(
                        5,
                        (index) => Padding(
                          padding: const EdgeInsets.all(2),
                          child: GestureDetector(
                            onTap: () {
                              // Change Selected Event Color
                              setState(() {
                                eventColorIndexSelected = index;
                              });
                            },
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: eventAvailableColorsList[index],
                              child: eventColorIndexSelected == index
                                  ? const Icon(
                                      Icons.done,
                                      color: Colors.white,
                                      size: 15,
                                    )
                                  : Container(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton:
              // [ACTION BUTTON] Add Event Button
              FloatingActionButton.extended(
            label: Text(
              widget.event == null ? 'Créer' : 'Modifier',
            ),
            foregroundColor: Colors.white,
            backgroundColor: kSecondColor,
            icon: Transform.translate(
              offset: Offset(1, -1),
              child: widget.event == null
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
              if (nameEventController.text.isNotEmpty &&
                  nameEventController.text.length < 45) {
                if (captionEventController.text.length <= 150) {
                  if (eventType.isNotEmpty) {
                    if (linkEventController.text.isEmpty ||
                        isURL(linkEventController.text)) {
                      if (isEndTimeSuperiorThanStartTime(startTime, endTime)) {
                        // CREATE OR UPDATE EVENT
                        debugPrint('creating/updating event...');
                        createOrUpdateEvent();
                      } else {
                        // Time start-end error handler
                        showSnackbar(
                            context,
                            'Votre heure de fin doit être en avance sur l\'heure de début',
                            null);
                      }
                    } else if (linkEventController.text.isNotEmpty &&
                        !isURL(linkEventController.text)) {
                      // Event link error handler
                      showSnackbar(
                          context, 'Veuillez entrer un lien correct', null);
                    }
                  } else {
                    // Event type error handler
                    showSnackbar(
                        context, 'Veuillez entrer un type d\'évenement', null);
                  }
                } else {
                  // Description error handler
                  showSnackbar(
                      context,
                      'Veuillez entrer une description valide (inferieure à 150 caractères)',
                      null);
                }
              } else {
                // Name error handler
                showSnackbar(
                    context,
                    'Veuillez entrer un nom valide (inferieur à 45 caractères)',
                    null);
              }
            },
          )),
    );
  }
}
