import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wesh/models/event.dart';
import 'package:wesh/models/reminder.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/utils/functions.dart';
import 'package:wesh/widgets/eventselector.dart';
import 'package:wesh/widgets/modal.dart';
import 'package:wesh/widgets/recurrenceselector.dart';
import 'package:wesh/widgets/reminderselector.dart';
import '../../providers/user.provider.dart';
import '../../services/firestore.methods.dart';
import '../../widgets/buildWidgets.dart';
import '../../widgets/textformfield.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';

class CreateOrUpdateReminderPage extends StatefulWidget {
  final Reminder? reminder;

  CreateOrUpdateReminderPage({this.reminder});

  @override
  State<CreateOrUpdateReminderPage> createState() =>
      _CreateOrUpdateReminderPageState();
}

class _CreateOrUpdateReminderPageState
    extends State<CreateOrUpdateReminderPage> {
  TextEditingController nameReminderController = TextEditingController();
  Event? eventController;
  DateTime? customDateTime;
  DateTime reminderFrom = DateTime.now().subtract(const Duration(days: 2));
  DateTime? reminderDateController;
  String? reminderDelay;
  String recurrenceController = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Init Controller

    initEventOrDateAttached();
    nameReminderController.text =
        widget.reminder == null ? '' : widget.reminder!.title;
    reminderDateController =
        widget.reminder == null ? null : widget.reminder!.remindAt;
    reminderDelay =
        widget.reminder == null ? null : widget.reminder!.reminderDelay;
    recurrenceController =
        widget.reminder == null ? '' : widget.reminder!.recurrence;

    debugPrint('Reminder from: $reminderFrom');
    debugPrint('Reminder at: $reminderDateController');
  }

  Future initEventOrDateAttached() async {
    if (widget.reminder != null && widget.reminder!.eventId.isNotEmpty) {
      Event? eventAttached =
          await FirestoreMethods().getEventById(widget.reminder!.eventId);
      eventController = eventAttached;
      reminderFrom = eventAttached!.startDateTime;
      reminderDateController = widget.reminder!.remindAt;
      customDateTime = null;

      setState(() {});
      debugPrint('Event attached : $eventController');
    } else if (widget.reminder != null && widget.reminder!.eventId.isEmpty) {
      reminderFrom = widget.reminder!.remindFrom;
      customDateTime = widget.reminder!.remindFrom;
      reminderDateController = widget.reminder!.remindAt;
      eventController = null;

      setState(() {});
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameReminderController.dispose();
  }

  createOrUpdateReminder() async {
    bool result = false;
    //
    // Get Reminder Duration Label
    if (eventController != null && customDateTime == null) {
      //
      reminderDelay = getDurationLabel(
          eventController!.startDateTime, reminderDateController!);
    } else if (eventController == null && customDateTime != null) {
      //
      reminderDelay =
          getDurationLabel(customDateTime!, reminderDateController!);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CupertinoActivityIndicator(radius: 16, color: Colors.white),
      ),
    );

    // CREATE A NEW ONE
    if (widget.reminder == null) {
      // Modeling an event

      Map<String, Object?> newReminder = Reminder(
        title: nameReminderController.text,
        uid: FirebaseAuth.instance.currentUser!.uid,
        reminderId: '',
        reminderDelay: reminderDelay!,
        eventId: eventController != null ? eventController!.eventId : '',
        remindAt: reminderDateController!,
        recurrence: recurrenceController,
        remindFrom: reminderFrom,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
        status: '',
      ).toJson();

      debugPrint('Reminder is: $newReminder');

      //  Update Firestore Reminder Table
      result = await FirestoreMethods().createReminder(
          context, FirebaseAuth.instance.currentUser!.uid, newReminder);
    }

    // UPDATE AN EXISTING ONE

    if (widget.reminder != null) {
      // Modeling a reminder

      Map<String, Object?> reminderToUpdate = Reminder(
        title: nameReminderController.text,
        uid: FirebaseAuth.instance.currentUser!.uid,
        reminderId: widget.reminder!.reminderId,
        reminderDelay: reminderDelay!,
        eventId: eventController != null ? eventController!.eventId : '',
        remindAt: reminderDateController!,
        recurrence: recurrenceController,
        remindFrom: reminderFrom,
        createdAt: widget.reminder!.createdAt,
        modifiedAt: DateTime.now(),
        status: '',
      ).toJson();

      result = await FirestoreMethods().updateReminder(
          context, widget.reminder!.reminderId, reminderToUpdate);
    }

    // Pop the Screen once reminder created/updated
    if (result) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      showSnackbar(
          context,
          widget.reminder == null
              ? 'Votre rappel à bien été crée !'
              : 'Votre rappel à bien été modifié !',
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
            widget.reminder != null &&
                    widget.reminder!.uid ==
                        FirebaseAuth.instance.currentUser!.uid
                ? IconButton(
                    splashRadius: 25,
                    onPressed: () async {
                      // DELETE REMINDER

                      // Show Delete Decision Modal
                      bool? deleteDecision = await showModalDecision(
                        context: context,
                        header: 'Supprimer',
                        content:
                            'Voulez-vous supprimer définitivement ce rappel ?',
                        firstButton: 'Annuler',
                        secondButton: 'Supprimer',
                      );

                      if (deleteDecision == true) {
                        // Delete reminder...
                        // ignore: use_build_context_synchronously
                        bool result = await FirestoreMethods().deleteReminder(
                            context,
                            widget.reminder!.reminderId,
                            FirebaseAuth.instance.currentUser!.uid);

                        if (result) {
                          debugPrint('Reminder deleted !');
                          Navigator.pop(
                            context,
                          );
                          Navigator.pop(
                            context,
                          );

                          // ignore: use_build_context_synchronously
                          showSnackbar(
                              context,
                              'Votre rappel à bien été supprimé !',
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
            widget.reminder == null ? 'Créer un rappel' : 'Modifier un rappel',
            style: const TextStyle(color: Colors.black),
          ),
          centerTitle: false,
        ),
        body: Column(children: [
          // Field
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20,
                bottom: 5,
                left: 15,
                right: 15,
              ),
              child: ListView(
                children: [
                  // Add Event Name
                  buildTextFormField(
                    controller: nameReminderController,
                    hintText: 'Ajouter un titre au rappel',
                    icon: const Icon(FontAwesomeIcons.pen),
                    validateFn: (eventName) {
                      return null;
                    },
                    onChanged: (value) async {
                      return await null;
                    },
                  ),

                  // Add Attach to an existing Event or a Custom Date
                  Row(
                    children: [
                      // Attach Event Button
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            // Get the selected event
                            // Show Event Selector
                            Event? selectedEvent = await showModalBottomSheet(
                              isDismissible: true,
                              enableDrag: true,
                              isScrollControlled: true,
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: ((context) => Modal(
                                    minChildSize: .4,
                                    child: const EventSelector(),
                                  )),
                            );

                            // Check the Event Selected
                            if (selectedEvent != null) {
                              setState(() {
                                customDateTime = null;
                                reminderDateController = null;
                                eventController = selectedEvent;
                              });
                              debugPrint(
                                  'selected event is: ${selectedEvent.title}');
                            } else if (selectedEvent == null) {
                              setState(() {
                                eventController = null;
                              });
                              debugPrint('selected event is: $selectedEvent');
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 0, 20),
                            child: Row(
                              children: [
                                Icon(FontAwesomeIcons.splotch,
                                    color: Colors.grey.shade600),
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Text(
                                    (() {
                                      if (eventController == null &&
                                          customDateTime == null) {
                                        return 'Attacher un évenement ou une date';
                                      }

                                      if (eventController != null &&
                                          customDateTime == null) {
                                        return eventController!.title;
                                      }

                                      if (eventController == null &&
                                          customDateTime != null) {
                                        return '${DateFormat('EEE, d MMM yyyy', 'fr_Fr').format(customDateTime!)} à ${DateFormat('HH:mm', 'fr_Fr').format(customDateTime!)}';
                                      }
                                      return 'Attacher un évenement ou une date';
                                    }()),
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),

                      // Attach any Date : Button
                      Row(
                        children: [
                          // Add Date
                          InkWell(
                            onTap: () async {
                              // Pick Date
                              DateTime? newDate =
                                  await pickDate(context: context);

                              if (newDate == null) {
                                setState(() {
                                  customDateTime = null;
                                });
                              } else {
                                setState(() {
                                  eventController = null;
                                  reminderDateController = null;
                                  customDateTime = newDate;
                                  debugPrint(
                                      "Custom Date is:  $customDateTime");
                                });
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Icon(FontAwesomeIcons.calendar,
                                  color: kSecondColor),
                            ),
                          ),

                          // Add Time
                          InkWell(
                            onTap: () async {
                              // Pick Time
                              Navigator.of(context).push(
                                showPicker(
                                  context: context,
                                  value: TimeOfDay.now(),
                                  is24HrFormat: true,
                                  iosStylePicker: true,
                                  unselectedColor: Colors.black38,
                                  accentColor: Colors.black87,
                                  cancelText: 'Annuler',
                                  hourLabel: 'heures',
                                  minuteLabel: 'minutes',
                                  onChange: (timePicked) {
                                    setState(() {
                                      customDateTime ??= DateTime.now();
                                      eventController = null;
                                      reminderDateController = null;
                                      customDateTime = DateTime(
                                        customDateTime!.year,
                                        customDateTime!.month,
                                        customDateTime!.day,
                                        timePicked.hour,
                                        timePicked.minute,
                                      );
                                    });

                                    debugPrint(
                                        "Custom Picked Time is: $timePicked");
                                  },
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Icon(FontAwesomeIcons.clock,
                                  color: kSecondColor),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),

                  // Add Reminder
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 5, 5),
                    child: Row(
                      children: [
                        Icon(FontAwesomeIcons.stopwatch,
                            color: Colors.grey.shade600),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: Text(
                            'Ajouter un rappel',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 18),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () async {
                            if (eventController != null ||
                                customDateTime != null) {
                              // Get Selected Reminder
                              Duration? selectedDuration =
                                  await showModalBottomSheet(
                                      context: context,
                                      isDismissible: true,
                                      enableDrag: true,
                                      isScrollControlled: true,
                                      builder: (context) => ReminderSelector());

                              if (selectedDuration != null) {
                                // Substract SelectedDuration from Event Time or CustomDateTime
                                setState(() {
                                  if (eventController != null &&
                                      customDateTime == null) {
                                    reminderDateController = eventController!
                                        .startDateTime
                                        .subtract(selectedDuration);
                                  } else if (eventController == null &&
                                      customDateTime != null) {
                                    reminderDateController = customDateTime!
                                        .subtract(selectedDuration);
                                  }
                                });
                                debugPrint(
                                    'Reminder is setted at: $reminderDateController');
                              } else if (selectedDuration == null) {
                                setState(() {});
                                debugPrint(
                                    'selected duration is: $reminderDateController');
                              }
                            } else {
                              showSnackbar(
                                  context,
                                  'Veuillez d\'abord attacher un évenement ou une date',
                                  null);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade600),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              reminderDateController == null
                                  ? 'Aucun rappel'
                                  : (() {
                                      if (eventController != null &&
                                          customDateTime == null) {
                                        return getDurationLabel(
                                            eventController!.startDateTime,
                                            reminderDateController!);
                                      }
                                      if (eventController == null &&
                                          customDateTime != null) {
                                        return getDurationLabel(customDateTime!,
                                            reminderDateController!);
                                      }
                                      return 'Aucun rappel';
                                    }()),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  const buildDivider(),

                  // Add Recurrence : if possible
                  Visibility(
                    visible: () {
                      if (eventController != null &&
                          !getEventRecurrence(eventController!.type)) {
                        return false;
                      }
                      return true;
                    }(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 20, 5, 5),
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.repeat,
                              color: Colors.grey.shade600),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Text(
                              'Ajouter une récurrence',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 18),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: () async {
                              if (eventController != null ||
                                  customDateTime != null) {
                                // Get Selected Reminder
                                int? selectedRecurrence =
                                    await showModalBottomSheet(
                                        context: context,
                                        isDismissible: true,
                                        enableDrag: true,
                                        isScrollControlled: true,
                                        builder: (context) =>
                                            RecurrenceSelector());

                                if (selectedRecurrence != null) {
                                  // Substract SelectedDuration from Event Time or CustomDateTime
                                  setState(() {
                                    recurrenceController =
                                        recurrencesList[selectedRecurrence]
                                            .data!;
                                  });
                                  debugPrint(
                                      'Recurrence is setted at: $recurrenceController');
                                }
                              } else {
                                showSnackbar(
                                    context,
                                    'Veuillez d\'abord attacher un évenement ou une date',
                                    null);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade600),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                recurrenceController.isEmpty
                                    ? 'Aucune récurrence'
                                    : recurrenceController,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
        floatingActionButton:
            // [ACTION BUTTON] Add Reminder Button
            FloatingActionButton.extended(
                label: Text(
                  widget.reminder == null ? 'Créer' : 'Modifier',
                ),
                foregroundColor: Colors.white,
                backgroundColor: kSecondColor,
                icon: Transform.translate(
                  offset: Offset(1, -1),
                  child: widget.reminder == null
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
                  // Get ReminderFrom DateTIme
                  if (eventController != null && customDateTime == null) {
                    //
                    reminderFrom = eventController!.startDateTime;
                  } else if (eventController == null &&
                      customDateTime != null) {
                    //
                    reminderFrom = customDateTime!;
                  }

                  // Check all requirements to valide Reminder
                  if (nameReminderController.text.isNotEmpty &&
                      nameReminderController.text.length < 45) {
                    if (eventController != null || customDateTime != null) {
                      if (reminderDateController != null) {
                        // if (reminderDateController!.isAfter(DateTime.now())) {
                        // Recurrence Settled error handler : because event has recurrence
                        if (eventController != null &&
                            customDateTime == null &&
                            getEventRecurrence(eventController!.type)) {
                          debugPrint('Event with recurrence...');
                          if (recurrenceController == 'Chaque jour' ||
                              recurrenceController == 'Chaque semaine' ||
                              recurrenceController == 'Chaque mois') {
                            showSnackbar(
                                context,
                                'Impossible de vous rappeler cet évenement ${recurrenceController.toLowerCase()}',
                                null);
                            return;
                          }
                        }

                        // CONTINUE : all points checked
                        // CREATE OR UPDATE REMINDER
                        debugPrint('creating/updating reminder...');
                        createOrUpdateReminder();
                        // } else {
                        //   // Reminder Settled error handler
                        //   showSnackbar(
                        //       context,
                        //       'Impossible d\'ajouter le rappel de ${(() {
                        //         if (eventController != null &&
                        //             customDateTime == null) {
                        //           return getDurationLabel(
                        //               eventController!.startDateTime,
                        //               reminderDateController!);
                        //         }
                        //         if (eventController == null &&
                        //             customDateTime != null) {
                        //           return getDurationLabel(
                        //               customDateTime!, reminderDateController!);
                        //         }
                        //         return '';
                        //       }())}, veuillez ajouter un rappel plus court',
                        //       null);
                        // }
                      } else {
                        // Content Attached error handler
                        showSnackbar(
                            context, 'Veuillez ajouter un rappel', null);
                      }
                    } else {
                      // Content Attached error handler
                      showSnackbar(context,
                          'Veuillez attacher un évenement ou une date', null);
                    }
                  } else {
                    // Name error handler
                    showSnackbar(
                        context,
                        'Veuillez entrer un titre valide (inferieur à 45 caractères)',
                        null);
                  }
                }),
      ),
    );
  }
}
