import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:wesh/models/event.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/utils/db.dart';
import 'package:wesh/utils/functions.dart';
import 'package:wesh/widgets/buildWidgets.dart';
import 'package:wesh/widgets/button.dart';
import 'package:wesh/widgets/datetimebutton.dart';
import 'package:wesh/widgets/deletedecisioinmodal.dart';
import 'package:wesh/widgets/imagepickermodal.dart';
import 'package:wesh/widgets/modal.dart';
import 'package:wesh/widgets/textformfield.dart';

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
  late String coverEventController;
  late int eventColorIndexSelected;

  DateTime dateEvent = DateTime.now();
  DateTime startTimeEvent = DateTime.now();
  DateTime endTimeEvent = DateTime.now();

  final formKey = GlobalKey<FormState>();
  var otherValidation = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameEventController.text = widget.event == null ? '' : widget.event!.title;

    captionEventController.text =
        widget.event == null ? '' : widget.event!.caption;

    linkEventController.text = widget.event == null ? '' : widget.event!.link;

    locationEventController.text =
        widget.event == null ? '' : widget.event!.location;

    coverEventController = widget.event == null ? '' : widget.event!.trailing;

    eventColorIndexSelected = widget.event == null ? 1 : widget.event!.color;

    // dateEvent = widget.event == null ? DateTime.now() : widget.event!.date;
    // startTimeEvent =
    //     widget.event == null ? DateTime.now() : widget.event!.startTime;
    // endTimeEvent = widget.event == null
    //     ? DateTime.now().add(Duration(hours: 2))
    //     : widget.event!.endTime;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0,
        elevation: 0,
        leading: IconButton(
          splashRadius: 25,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        actions: [
          widget.event != null && widget.event!.uid == myId.toString()
              ? IconButton(
                  splashRadius: 25,
                  onPressed: () async {
                    // DELETE EVENT

                    // Show Delete Decision Modal
                    bool deleteDecision = await showModalBottomSheet(
                      enableDrag: true,
                      isScrollControlled: true,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: ((context) => Modal(
                            initialChildSize: .3,
                            maxChildSize: .3,
                            minChildSize: .3,
                            child: DeleteDecision(),
                          )),
                    );

                    if (deleteDecision) {
                      // Delete event confirmed !

                      // final eventToUpdated = widget.event!.copy(
                      //   id: widget.event!.id,
                      //   eventId: widget.event!.eventId,
                      //   uid: '3',
                      //   title: nameEventController.text,
                      //   caption: captionEventController.text,
                      //   link: linkEventController.text,
                      //   location: locationEventController.text,
                      //   trailing: coverEventController,
                      //   color: eventColorIndexSelected,
                      //   createdAt: DateTime.now(),
                      //   date: dateEvent,
                      //   startTime: startTimeEvent,
                      //   endTime: endTimeEvent,
                      //   status: 'deleted',
                      // );

                      // await SqlDatabase.instance.updateEvent(eventToUpdated);

                      Navigator.pop(
                        context,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: kSuccessColor,
                          content: Text(
                            'Votre évenement à bien été supprimé !',
                            style: TextStyle(color: Colors.white),
                          )));
                    }
                    ;
                  },
                  icon: const Icon(
                    Icons.delete_rounded,
                    color: kSecondColor,
                  ),
                )
              : Container(),
        ],
        title: Text(
          widget.event == null ? 'Créer un évenement' : 'Modifier l\'évenement',
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(
                top: 20,
                bottom: 5,
                left: 10,
                right: 10,
              ),
              child: ListView(
                children: [
                  // FIELDS

                  // Add Event Name
                  buildTextFormField(
                    controller: nameEventController,
                    hintText: 'Ajouter le nom de l\'évenement',
                    icon: Icon(Icons.edit_calendar_rounded),
                    validateFn: (eventName) {
                      if (eventName!.isEmpty || eventName.length > 45) {
                        return 'Veuillez entrer un nom valide (inferieur à 45 caractères)';
                      }
                      return null;
                    },
                  ),

                  // Add Event Caption
                  buildTextFormField(
                    controller: captionEventController,
                    hintText: 'Ajouter la description de l\'évenement',
                    icon: Icon(Icons.edit_note),
                    validateFn: (eventCaption) {
                      if (eventCaption!.length > 150) {
                        return 'Veuillez entrer une description valide (inferieure à 150 caractères)';
                      }
                      return null;
                    },
                  ),

                  const buildDivider(),

                  // Add Event Link
                  buildTextFormField(
                    controller: linkEventController,
                    hintText: 'Ajouter un lien à l\'évenement',
                    icon: Icon(
                      FontAwesomeIcons.link,
                      size: 17,
                    ),
                    validateFn: (eventLink) {
                      return null;
                    },
                  ),

                  // Add Event Location
                  buildTextFormField(
                    controller: locationEventController,
                    hintText: 'Ajouter le lieu de l\'évenement',
                    icon: Icon(
                      Icons.location_pin,
                    ),
                    validateFn: (eventLocation) {
                      return null;
                    },
                  ),

                  // Add Event Trailing
                  InkWell(
                    onTap: () async {
                      // Show Contact Viewer Modal
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
                        final Directory directory =
                            await getApplicationDocumentsDirectory();
                        final filename = 'eventCover_${Uuid().v4()}';
                        final path = '${directory.path}/$filename.jpg';

                        var res = file.saveTo(path).whenComplete(
                            () => print('File was saved correctly at $path'));

                        setState(() {
                          coverEventController = path;
                        });
                      } else if (file == null) {
                        setState(() {
                          coverEventController = '';
                        });

                        print('No file selected !');
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 5, 5),
                      child: Row(
                        children: [
                          Icon(Icons.image_rounded,
                              color: Colors.grey.shade600),
                          SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Text(
                              'Ajouter un cover à l\'évenement',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 18),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          coverEventController == ''
                              ? Container(
                                  height: 50,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: AssetImage(
                                            'assets/images/event_default_cover.png')),
                                  ),
                                )
                              : Container(
                                  height: 50,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: FileImage(
                                            File(coverEventController))),
                                  ),
                                )
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
                        Icon(Icons.calendar_month_rounded,
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
                          date: dateEvent,
                          type: 'date',
                          onTap: () async {
                            // Pick Date
                            DateTime? newDate =
                                await pickDate(context: context);

                            if (newDate == null) {
                              setState(() {
                                otherValidation = false;
                              });
                            } else {
                              setState(() {
                                dateEvent = newDate;
                                otherValidation = true;
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
                              Text('Heure de début'),
                              SizedBox(
                                height: 5,
                              ),
                              DateTimeButton(
                                date: startTimeEvent,
                                type: 'time',
                                onTap: () async {
                                  // Pick start time

                                  // var today = DateTime.now();
                                  // var initialHour =
                                  //     widget.event?.startTime.hour ??
                                  //         today.hour;
                                  // var initialMinute =
                                  //     widget.event?.startTime.minute ??
                                  //         today.minute;

                                  // DateTime selectedTime = await pickTime(
                                  //   context: context,
                                  //   initialTime: TimeOfDay(
                                  //       hour: initialHour,
                                  //       minute: initialMinute),
                                  // );

                                  // if (selectedTime.isAfter(DateTime(
                                  //     today.year,
                                  //     today.month,
                                  //     today.day,
                                  //     today.hour,
                                  //     today.minute))) {
                                  //   setState(() {
                                  //     startTimeEvent = selectedTime;
                                  //     otherValidation = true;
                                  //   });
                                  // } else {
                                  //   otherValidation = false;
                                  //   print('Time Error');
                                  // }
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
                              Text('Heure de fin'),
                              SizedBox(
                                height: 5,
                              ),
                              DateTimeButton(
                                date: endTimeEvent,
                                type: 'time',
                                onTap: () async {
                                  // Pick end time

                                  // var today = DateTime.now();
                                  // var initialendHour =
                                  //     widget.event?.endTime.hour ?? today.hour;
                                  // var initialendMinute =
                                  //     widget.event?.endTime.minute ??
                                  //         today.minute;

                                  // DateTime selectedTime = await pickTime(
                                  //   context: context,
                                  //   initialTime: TimeOfDay(
                                  //       hour: initialendHour + 2,
                                  //       minute: initialendMinute),
                                  // );

                                  // if (selectedTime.isAfter(DateTime(
                                  //     startTimeEvent.year,
                                  //     startTimeEvent.month,
                                  //     startTimeEvent.day,
                                  //     startTimeEvent.hour,
                                  //     startTimeEvent.minute))) {
                                  //   setState(() {
                                  //     otherValidation = true;
                                  //     endTimeEvent = selectedTime;
                                  //   });
                                  // } else {
                                  //   otherValidation = false;
                                  //   print('Time Error');
                                  // }
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
                    padding: const EdgeInsets.fromLTRB(10, 20, 5, 50),
                    child: Row(
                      children: [
                        Icon(FontAwesomeIcons.palette,
                            color: Colors.grey.shade600),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: Text(
                            'Ajouter une couleur',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 18),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Row(
                          children: List<Widget>.generate(
                            4,
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
                                  backgroundColor:
                                      eventAvailableColorsList[index],
                                  child: eventColorIndexSelected == index
                                      ? Icon(
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
            )),

            // [ACTION BUTTON] Add Event Button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Button(
                      height: 40,
                      width: 130,
                      text: widget.event == null ? 'Créer' : 'Modifier',
                      color: kSecondColor,
                      onTap: () async {
                        final isFormValid = formKey.currentState!.validate();

                        var today = DateTime.now();

                        if (isFormValid && otherValidation) {
                          // if (widget.event == null) {
                          //   // Create Event here !

                          //   final newEvent = Event(
                          //       eventId: 'event_${const Uuid().v4()}',
                          //       uid: '3',
                          //       title: nameEventController.text,
                          //       caption: captionEventController.text,
                          //       link: linkEventController.text,
                          //       location: locationEventController.text,
                          //       trailing: coverEventController,
                          //       color: eventColorIndexSelected,
                          //       createdAt: DateTime.now(),
                          //       date: dateEvent,
                          //       startTime: startTimeEvent,
                          //       endTime: endTimeEvent,
                          //       status: 'pending');

                          //   // await SqlDatabase.instance.createEvent(newEvent);
                          // }

                          // if (widget.event != null) {
                          //   final eventToUpdated = widget.event!.copy(
                          //     eventId: widget.event!.eventId,
                          //     uid: '3',
                          //     title: nameEventController.text,
                          //     caption: captionEventController.text,
                          //     link: linkEventController.text,
                          //     location: locationEventController.text,
                          //     trailing: coverEventController,
                          //     color: eventColorIndexSelected,
                          //     createdAt: DateTime.now(),
                          //     date: dateEvent,
                          //     startTime: startTimeEvent,
                          //     endTime: endTimeEvent,
                          //     status: 'pending',
                          //   );

                          //   // await SqlDatabase.instance
                          //   //     .updateEvent(eventToUpdated);
                          // }

                          // Pop the Screen once event created
                          Navigator.pop(
                            context,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: kSuccessColor,
                              content: Text(
                                widget.event == null
                                    ? 'Votre évenement à bien été crée !'
                                    : 'Votre évenement à bien été modifié !',
                                style: TextStyle(color: Colors.white),
                              )));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Veuillez vérifier vos informations !')));
                        }
                      },
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

// TIME PICKER
  Future<DateTime> pickTime(
      {required BuildContext context, required initialTime}) async {
    final newTime = await showTimePicker(
      cancelText: 'ANNULER',
      helpText: 'Selectionner une heure',
      errorInvalidText: 'Veuillez entrer une date valide',
      minuteLabelText: 'Minutes',
      hourLabelText: 'Heure',
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    return DateTime(
      dateEvent.year,
      dateEvent.month,
      dateEvent.day,
      newTime!.hour,
      newTime.minute,
    );
  }
}
