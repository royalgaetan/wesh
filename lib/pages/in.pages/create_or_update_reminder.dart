import 'dart:math';
import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/models/event.dart';
import 'package:wesh/models/event_duration_type.dart';
import 'package:wesh/models/reminder.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/utils/functions.dart';
import 'package:wesh/widgets/eventselector.dart';
import 'package:wesh/widgets/modal.dart';
import 'package:wesh/widgets/recurrenceselector.dart';
import 'package:wesh/widgets/reminderselector.dart';
import '../../services/firestore.methods.dart';
import '../../widgets/buildWidgets.dart';
import '../../widgets/textformfield.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';

class CreateOrUpdateReminderPage extends StatefulWidget {
  final Reminder? reminder;
  final Event? eventAttached;

  const CreateOrUpdateReminderPage({Key? key, this.reminder, this.eventAttached}) : super(key: key);

  @override
  State<CreateOrUpdateReminderPage> createState() => _CreateOrUpdateReminderPageState();
}

class _CreateOrUpdateReminderPageState extends State<CreateOrUpdateReminderPage> {
  bool isLoading = false;

  TextEditingController emptyController = TextEditingController();
  TextEditingController nameReminderController = TextEditingController();

  Event? eventController;
  DateTime? customDateTime;

  DateTime reminderFrom = DateTime.now().subtract(const Duration(days: 2));
  DateTime? reminderDateController;
  String? reminderDelay;
  String recurrenceController = '';

  @override
  void initState() {
    //
    super.initState();

    // Init Controller

    initEventOrDateAttached();
    nameReminderController.text = widget.reminder == null ? '' : widget.reminder!.title;
    reminderDateController = widget.reminder == null ? null : widget.reminder!.remindAt;
    reminderDelay = widget.reminder == null ? null : widget.reminder!.reminderDelay;
    recurrenceController = widget.reminder == null ? '' : widget.reminder!.recurrence;

    dev.log('Reminder from: $reminderFrom');
    dev.log('Reminder at: $reminderDateController');
  }

  Future initEventOrDateAttached() async {
    setState(() {
      isLoading = true;
    });
    if (widget.reminder != null && widget.reminder!.eventId.isNotEmpty) {
      Event? eventAttached = await FirestoreMethods.getEventByIdAsFuture(widget.reminder!.eventId);
      eventController = eventAttached;
      // reminderFrom = eventAttached!.eventDurations[0]['date'];
      reminderDateController = widget.reminder!.remindAt;
      customDateTime = null;

      setState(() {});
      dev.log('Event attached : $eventController');
    } else if (widget.reminder != null && widget.reminder!.eventId.isEmpty) {
      reminderFrom = widget.reminder!.remindFrom;
      customDateTime = widget.reminder!.remindFrom;
      reminderDateController = widget.reminder!.remindAt;
      eventController = null;

      setState(() {});
      dev.log('Date attached : $customDateTime');
    } else if (widget.reminder == null && widget.eventAttached != null) {
      eventController = widget.eventAttached;
      // reminderFrom = eventAttached!.eventDurations[0]['date'];
      reminderDateController = null;
      customDateTime = null;

      setState(() {});
      dev.log('Event to continue with... : $eventController');
    }

    // Dismiss loader
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    //
    super.dispose();
    nameReminderController.dispose();
    emptyController.dispose();
  }

  createOrUpdateReminder() async {
    bool result = false;
    //
    // Get Reminder Duration Label
    if (eventController != null && customDateTime == null) {
      //
      reminderDelay =
          getDurationLabel(getCompleteDateTimeFromFirstEventDuration(eventController), reminderDateController!);
    } else if (eventController == null && customDateTime != null) {
      //
      reminderDelay = getDurationLabel(customDateTime!, reminderDateController!);
    }

    showFullPageLoader(context: context);

    // CREATE A NEW ONE
    if (widget.reminder == null) {
      // Modeling an event

      Map<String, dynamic> newReminder = Reminder(
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
      result = await FirestoreMethods.createReminder(context, FirebaseAuth.instance.currentUser!.uid, newReminder);
    }

    // UPDATE AN EXISTING ONE

    if (widget.reminder != null) {
      // Remove recurrence when possible
      if (eventController != null && !getEventRecurrence(eventController!.type)) {
        recurrenceController = '';
      }

      // Modeling a reminder
      Map<String, dynamic> reminderToUpdate = Reminder(
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

      // ignore: use_build_context_synchronously
      result = await FirestoreMethods.updateReminder(context, widget.reminder!.reminderId, reminderToUpdate);
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
          widget.reminder == null ? 'Votre rappel à bien été crée !' : 'Votre rappel à bien été modifié !',
          kSuccessColor);
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
          // MAIN SCREEN
          Scaffold(
            backgroundColor: Colors.white,
            appBar: MorphingAppBar(
              heroTag: 'createOrUpdateReminderPageAppBar',
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
                widget.reminder != null && widget.reminder!.uid == FirebaseAuth.instance.currentUser!.uid
                    ? IconButton(
                        splashRadius: 0.06.sw,
                        onPressed: () async {
                          // DELETE REMINDER

                          // Show Delete Decision Modal
                          List deleteDecision = await showModalDecision(
                            context: context,
                            header: 'Supprimer',
                            content: 'Voulez-vous supprimer définitivement ce rappel ?',
                            firstButton: 'Annuler',
                            secondButton: 'Supprimer',
                          );

                          if (deleteDecision[0] == true) {
                            // Delete reminder...
                            // ignore: use_build_context_synchronously
                            bool result = await FirestoreMethods.deleteReminder(
                                context, widget.reminder!.reminderId, FirebaseAuth.instance.currentUser!.uid);

                            if (result) {
                              debugPrint('Reminder deleted !');
                              // ignore: use_build_context_synchronously
                              Navigator.pop(
                                context,
                              );
                              // ignore: use_build_context_synchronously
                              Navigator.pop(
                                context,
                              );

                              // ignore: use_build_context_synchronously
                              showSnackbar(context, 'Votre rappel à bien été supprimé !', kSecondColor);
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
                child: ListView(
                  padding: const EdgeInsets.only(top: 20, bottom: 5, left: 10, right: 10),
                  children: [
                    // Add Reminder Name
                    buildTextFormField(
                      controller: nameReminderController,
                      hintText: 'Ajouter un titre au rappel',
                      icon: Icon(FontAwesomeIcons.alignLeft, size: 17.sp),
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
                              if (widget.eventAttached == null) {
                                // Get the selected event
                                // Show Event Selector
                                var selectedEvent = await showModalBottomSheet(
                                  isDismissible: true,
                                  enableDrag: true,
                                  isScrollControlled: true,
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: ((context) => Modal(
                                        minHeightSize: MediaQuery.of(context).size.height / 1.4,
                                        maxHeightSize: MediaQuery.of(context).size.height,
                                        child: const EventSelector(),
                                      )),
                                );

                                // Check the Event Selected
                                if (selectedEvent != null && selectedEvent != 'remove') {
                                  setState(() {
                                    customDateTime = null;
                                    reminderDateController = null;
                                    eventController = selectedEvent;
                                  });
                                  dev.log('selected event is: ${selectedEvent.title}');
                                }
                                //
                                else if (selectedEvent == 'remove') {
                                  setState(() {
                                    eventController = null;
                                  });
                                  dev.log('selected event is: $selectedEvent');
                                }
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.only(top: 6, bottom: 0.02.sw, left: 14),
                              child: Row(
                                children: [
                                  Icon(FontAwesomeIcons.splotch, size: 17.sp, color: Colors.grey.shade600),
                                  SizedBox(width: 0.05.sw),
                                  Expanded(
                                    child: Text(
                                      (() {
                                        if (eventController == null && customDateTime == null) {
                                          return 'Attacher un évènement ou une date';
                                        }

                                        if (eventController != null && customDateTime == null) {
                                          return eventController!.title;
                                        }

                                        if (eventController == null && customDateTime != null) {
                                          return '${DateFormat('EEE, d MMM yyyy', 'fr_Fr').format(customDateTime!)} à ${DateFormat('HH:mm', 'fr_Fr').format(customDateTime!)}';
                                        }
                                        return 'Attacher un évènement ou une date';
                                      }()),
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
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

                        // Attach any Date && Time : Button
                        Visibility(
                          visible: widget.eventAttached == null,
                          child: Row(
                            children: [
                              // Add Date
                              InkWell(
                                onTap: () async {
                                  // Pick Date
                                  DateTime? newDate = await pickDate(context: context, firstDate: DateTime(1700));

                                  if (newDate == null) {
                                    setState(() {
                                      customDateTime = null;
                                    });
                                  } else {
                                    setState(() {
                                      eventController = null;
                                      reminderDateController = null;
                                      customDateTime = newDate;
                                      dev.log("Custom Date is:  $customDateTime");
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Icon(
                                    FontAwesomeIcons.calendar,
                                    color: kSecondColor,
                                    size: 17.sp,
                                  ),
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

                                        debugPrint("Custom Picked Time is: $timePicked");
                                      },
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Icon(
                                    FontAwesomeIcons.clock,
                                    color: kSecondColor,
                                    size: 17.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Add Reminder
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        buildTextFormField(
                          padding: const EdgeInsets.all(0),
                          controller: emptyController,
                          isReadOnly: true,
                          hintText: 'Ajouter un rappel',
                          icon: Icon(Icons.timer_outlined, size: 22.sp),
                          validateFn: (_) {
                            return;
                          },
                          onChanged: (value) async {
                            return;
                          },
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () async {
                            if (eventController != null || customDateTime != null) {
                              // Get Selected Reminder
                              Duration? selectedDuration = await showModalBottomSheet(
                                  context: context,
                                  isDismissible: true,
                                  enableDrag: true,
                                  isScrollControlled: true,
                                  builder: (context) => ReminderSelector());

                              if (selectedDuration != null) {
                                // Substract SelectedDuration from Event Time or CustomDateTime
                                setState(() {
                                  if (eventController != null && customDateTime == null) {
                                    //  BUILD COMPLETE DATETIME

                                    reminderDateController = getCompleteDateTimeFromFirstEventDuration(eventController)
                                        .subtract(selectedDuration);
                                  }
                                  //
                                  else if (eventController == null && customDateTime != null) {
                                    reminderDateController = customDateTime!.subtract(selectedDuration);
                                  }
                                });
                                dev.log('Reminder is setted at: $reminderDateController');
                              } else if (selectedDuration == null) {
                                setState(() {});
                                dev.log('selected duration is: $reminderDateController');
                              }
                            } else {
                              showSnackbar(context, 'Veuillez d\'abord attacher un évènement ou une date', null);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade600),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              reminderDateController == null
                                  ? 'Aucun rappel'
                                  : (() {
                                      if (eventController != null && customDateTime == null) {
                                        return getDurationLabel(
                                            getCompleteDateTimeFromFirstEventDuration(eventController),
                                            reminderDateController!);
                                      }
                                      if (eventController == null && customDateTime != null) {
                                        return getDurationLabel(customDateTime!, reminderDateController!);
                                      }
                                      return 'Aucun rappel';
                                    }()),
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const buildDivider(),

                    // Add Recurrence : if possible
                    Visibility(
                      visible: () {
                        if (eventController != null && !getEventRecurrence(eventController!.type)) {
                          return false;
                        }
                        return true;
                      }(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          buildTextFormField(
                            padding: const EdgeInsets.all(0),
                            controller: emptyController,
                            isReadOnly: true,
                            hintText: 'Ajouter une recurrence',
                            icon: Icon(Icons.event_repeat_rounded, size: 22.sp),
                            validateFn: (_) {
                              return;
                            },
                            onChanged: (value) async {
                              return;
                            },
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: () async {
                              if (eventController != null || customDateTime != null) {
                                // Get Selected Reminder
                                int? selectedRecurrence = await showModalBottomSheet(
                                    context: context,
                                    isDismissible: true,
                                    enableDrag: true,
                                    isScrollControlled: true,
                                    builder: (context) => RecurrenceSelector());

                                if (selectedRecurrence != null) {
                                  // Substract SelectedDuration from Event Time or CustomDateTime
                                  setState(() {
                                    recurrenceController = recurrencesList[selectedRecurrence].data!;
                                  });
                                  dev.log('Recurrence is setted at: $recurrenceController');
                                }
                              } else {
                                showSnackbar(context, 'Veuillez d\'abord attacher un évènement ou une date', null);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade600),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                recurrenceController.isEmpty ? 'Aucune récurrence' : recurrenceController,
                                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
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
                      offset: const Offset(1, -1),
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
                      // VIBRATE
                      triggerVibration();

                      // Get ReminderFrom DateTIme
                      if (eventController != null && customDateTime == null) {
                        //
                        reminderFrom = getCompleteDateTimeFromFirstEventDuration(eventController);
                      } else if (eventController == null && customDateTime != null) {
                        //
                        reminderFrom = customDateTime!;
                      }

                      // Check all requirements to valide Reminder
                      if (nameReminderController.text.isNotEmpty && nameReminderController.text.length < 45) {
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
                                    'Impossible de vous rappeler cet évènement ${recurrenceController.toLowerCase()}, essayez chaque année !',
                                    null);
                                return;
                              }
                            }

                            // CONTINUE : all points checked
                            // CREATE OR UPDATE REMINDER
                            dev.log('creating/updating reminder...');
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
                            showSnackbar(context, 'Veuillez ajouter un rappel', null);
                          }
                        } else {
                          // Content Attached error handler
                          showSnackbar(context, 'Veuillez attacher un évènement ou une date', null);
                        }
                      } else {
                        // Name error handler
                        showSnackbar(context, 'Veuillez entrer un titre valide (inferieur à 45 caractères)', null);
                      }
                    }),
          ),

          // LOADER
          isLoading
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(
                    child: CupertinoActivityIndicator(radius: 16, color: Colors.white),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
