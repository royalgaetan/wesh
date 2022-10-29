import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wesh/pages/in.pages/create_or_update_reminder.dart';
import 'package:wesh/services/firestore.methods.dart';
import '../models/reminder.dart';
import '../utils/constants.dart';
import 'button.dart';

class ReminderView extends StatefulWidget {
  final String reminderId;
  const ReminderView({super.key, required this.reminderId});

  @override
  State<ReminderView> createState() => _ReminderViewState();
}

class _ReminderViewState extends State<ReminderView> {
  bool isLoading = true;
  dynamic localReminder = '';

  Future initReminder() async {
    var rem = await FirestoreMethods().getReminderById(widget.reminderId);
    setState(() {
      isLoading = false;
      if (rem != null) {
        localReminder = rem;
      } else if (rem == null) {
        localReminder = 'error';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key("reminderView widget"),
      onVisibilityChanged: (VisibilityInfo info) {
        if (info.visibleFraction == 1.0) {
          initReminder();
          debugPrint("${info.visibleFraction} of my widget is visible");
        }
      },
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: (() {
            // While Widget is loading
            if (isLoading) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: CupertinoActivityIndicator(),
                ),
              );
            }

            // if Reminder throw error
            if (localReminder == 'error' && !isLoading) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'Une erreur s\'est produite lors du chargement',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black45,
                    ),
                  ),
                ),
              );
            }

            // Success case
            if (localReminder != 'error' && localReminder != '' && !isLoading) {
              return Column(
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rappel',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 19,
                        ),
                      ),
                      Button(
                        text: 'Modifier',
                        height: 45,
                        width: 150,
                        fontsize: 16,
                        fontColor: Colors.black,
                        color: Colors.white,
                        isBordered: true,
                        prefixIcon: Icons.edit,
                        prefixIconColor: Colors.black,
                        prefixIconSize: 22,
                        onTap: () {
                          // Edit Event here !
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => (CreateOrUpdateReminderPage(
                                  reminder: localReminder)),
                            ),
                          );
                          ;
                        },
                      ),
                    ],
                  ),
                  // BODY
                  const SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Title
                        Text(
                          localReminder.title,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 21,
                          ),
                        ),

                        const SizedBox(
                          height: 7,
                        ),

                        // ReminderFrom
                        Text(
                          'de ${DateFormat('EEE, d MMM yyyy', 'fr_Fr').format(localReminder.remindFrom)} à ${DateFormat('HH:mm', 'fr_Fr').format(localReminder.remindFrom)}',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.7),
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        // Reminder
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: 'Me rappeler ',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.7),
                              fontSize: 15,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text: localReminder.reminderDelay,
                                  style: const TextStyle(
                                      color: kSecondColor,
                                      fontWeight: FontWeight.bold)),
                              localReminder.recurrence.isNotEmpty &&
                                      localReminder.recurrence !=
                                          'Aucune récurrence'
                                  ? TextSpan(
                                      text:
                                          ', ${localReminder.recurrence.toLowerCase()}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ))
                                  : const TextSpan(),
                            ],
                          ),
                        )

                        //
                      ],
                    ),
                  )
                ],
              );
            }
          }())),
    );
  }
}
