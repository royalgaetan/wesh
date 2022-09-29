import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:wesh/models/event.dart';
import 'package:wesh/models/reminder.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/utils/functions.dart';
import 'package:wesh/widgets/button.dart';
import 'package:wesh/widgets/datetimebutton.dart';
import 'package:wesh/widgets/eventselector.dart';
import 'package:wesh/widgets/modal.dart';
import 'package:wesh/widgets/reminderselector.dart';

class CreateOrUpdateReminderPage extends StatefulWidget {
  CreateOrUpdateReminderPage();

  @override
  State<CreateOrUpdateReminderPage> createState() =>
      _CreateOrUpdateReminderPageState();
}

class _CreateOrUpdateReminderPageState
    extends State<CreateOrUpdateReminderPage> {
  Event? eventController;
  Duration? reminderDurationController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Init Controller
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
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Créer un rappel',
          style: TextStyle(color: Colors.black),
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
                              child: EventSelector(),
                            )),
                      );

                      // Check the Event Selected
                      if (selectedEvent != null) {
                        setState(() {
                          eventController = selectedEvent;
                        });
                        print('selected event is: $selectedEvent');
                      } else if (selectedEvent == null) {
                        setState(() {
                          eventController = null;
                        });
                        print('selected event is: $selectedEvent');
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 30, 0, 30),
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.splotch,
                              color: Colors.grey.shade600),
                          SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Text(
                              eventController == null
                                  ? 'Ajouter un évenement'
                                  : eventController!.title,
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 18),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Add Event Reminder
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 5, 5),
                  child: Row(
                    children: [
                      Icon(Icons.timer_outlined, color: Colors.grey.shade600),
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Text(
                          'Ajouter un rappel',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () async {
                          // Get Selected Reminder

                          // Set a reminder to an Event

                          Duration? selectedDuration =
                              await showModalBottomSheet(
                                  context: context,
                                  isDismissible: true,
                                  enableDrag: true,
                                  isScrollControlled: true,
                                  builder: (context) => ReminderSelector());

                          // Substract SelectedDuration from Event Time
                          // TO DO

                          if (selectedDuration != null) {
                            setState(() {
                              reminderDurationController = selectedDuration;
                            });
                            print(
                                'Reminder is setted at: $reminderDurationController');
                          } else if (selectedDuration == null) {
                            setState(() {
                              reminderDurationController = null;
                            });
                            print('selected duration is: $selectedDuration');
                          }
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade600),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            reminderDurationController == null
                                ? 'Aucun rappel'
                                : getDurationLabel(reminderDurationController!),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Add Event Button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Button(
                  text: 'Créer',
                  color: kSecondColor,
                  onTap: () async {
                    if (eventController != null) {
                      // Create a reminder
                      var remindAt = eventController?.createdAt
                          .subtract(reminderDurationController!);

                      print('Reminding Date is : $remindAt');

                      final newReminder = Reminder(
                          reminderId: 'reminder_${const Uuid().v4()}',
                          eventId: 'event_${const Uuid().v4()}',
                          remindAt: remindAt!,
                          status: 'saved');

                      // await SqlDatabase.instance.createReminder(newReminder);

                      // Pop the Screen once event created
                      Navigator.pop(
                        context,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: kSuccessColor,
                          content: const Text(
                            'Votre rappel à bien été crée !',
                            style: TextStyle(color: Colors.white),
                          )));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text('Veuillez vérifier vos informations !')));
                    }
                  },
                  height: 40,
                  width: 130,
                )
              ],
            ),
          ),
        )
      ]),
    );
  }
}
