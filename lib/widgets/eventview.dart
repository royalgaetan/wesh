import 'dart:io';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wesh/models/event.dart';
import 'package:wesh/models/reminder.dart';
import 'package:wesh/pages/in.pages/create_or_update_event.dart';
import 'package:wesh/pages/in.pages/inbox.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/utils/functions.dart';
import 'package:wesh/widgets/button.dart';
import 'package:wesh/widgets/reminderselector.dart';
import 'package:wesh/widgets/userposterheader.dart';

class EventView extends StatefulWidget {
  final String eventId;

  late DateTime? reminderDate = null;

  EventView({required this.eventId});

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  late Event event;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Get Event
    refreshEvent();

    // Check if the Event Date has a Reminder
    // TO DO
  }

  Future refreshEvent() async {
    setState(() => isLoading = true);
    // event = await SqlDatabase.instance.readEvent(widget.eventId);
    setState(() => isLoading = false);

    return event;
  }

  @override
  Widget build(BuildContext context) {
    const int myId = 3;
    return isLoading
        ? const Expanded(
            child: Center(
              child: Expanded(
                child: CupertinoActivityIndicator(
                  radius: 12,
                ),
              ),
            ),
          )
        : Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Event Trailing
                  event.trailing.isEmpty
                      ? CircleAvatar(
                          radius: 70,
                          backgroundImage: AssetImage(
                              'assets/images/event_default_cover.png'),
                        )
                      : CircleAvatar(
                          radius: 70,
                          backgroundImage: FileImage(File(event.trailing)),
                        ),

                  // Event Name
                  SizedBox(height: 20),
                  Text(
                    '${event.title}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  // Event Action Button
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // MESSAGE BUTTON OR EDIT EVENT BUTTON
                      event.uid != myId.toString()
                          ? Button(
                              text: 'Message',
                              height: 45,
                              width: 150,
                              fontsize: 16,
                              fontColor: Colors.black,
                              color: Colors.white,
                              isBordered: true,
                              prefixIcon: FontAwesomeIcons.message,
                              prefixIconColor: Colors.black,
                              prefixIconSize: 22,
                              onTap: () {
                                // Message for the Event
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => (InboxPage(
                                        uid: event.uid,
                                        eventIdAttached: event.eventId)),
                                  ),
                                );
                              },
                            )
                          : Button(
                              text: 'Modifier',
                              height: 40,
                              width: 150,
                              fontsize: 16,
                              fontColor: Colors.black,
                              color: Colors.white,
                              isBordered: true,
                              prefixIcon: Icons.edit,
                              prefixIconColor: Colors.black,
                              prefixIconSize: 22,
                              onTap: () {
                                // Edit Contact here !
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => (CreateOrUpdateEventPage(
                                      event: event,
                                    )),
                                  ),
                                );
                                ;
                              },
                            ),

                      SizedBox(width: 14),

                      // REMINDER BUTTON
                      Button(
                        text: widget.reminderDate == null
                            ? 'Me rappeler'
                            : 'Rappel',
                        height: 45,
                        width: 150,
                        fontsize: 16,
                        fontColor: Colors.white,
                        color: kSecondColor,
                        prefixIcon: widget.reminderDate == null
                            ? Icons.timer_outlined
                            : Icons.done,
                        prefixIconColor: Colors.white,
                        prefixIconSize: 22,
                        onTap: () async {
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
                              widget.reminderDate =
                                  DateTime.now().subtract(selectedDuration);
                              print(
                                  'Reminder is setted at: ${widget.reminderDate}');
                            });
                          }
                          if (selectedDuration == null) {
                            setState(() {
                              widget.reminderDate = null;
                              print(
                                  'Reminder is setted at: ${widget.reminderDate}');
                            });
                          }
                        },
                      ),
                    ],
                  ),

                  // Event Info
                  SizedBox(height: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Date
                      EventInfoRow(
                        icon: FontAwesomeIcons.calendar,
                        label:
                            '${DateFormat('EEE, d MMM yyyy', 'fr_Fr').format(event.startDateTime)}',
                        type: 'date',
                      ),

                      // Event Time
                      EventInfoRow(
                        icon: FontAwesomeIcons.clock,
                        label:
                            '${DateFormat('hh:mm', 'fr_Fr').format(event.startDateTime)} à ${DateFormat('hh:mm', 'fr_Fr').format(event.endDateTime)}',
                        type: 'time',
                      ),

                      // Event Location
                      EventInfoRow(
                        icon: FontAwesomeIcons.locationDot,
                        label: '${event.location}',
                        type: 'location',
                      ),

                      // Event Link
                      InkWell(
                        onTap: () async {
                          final Uri _url = Uri.parse('${event.link}');

                          if (!await launchUrl(_url)) {
                            throw 'Could not launch $_url';
                          }
                        },
                        child: EventInfoRow(
                          icon: FontAwesomeIcons.link,
                          label: '${event.link}',
                          type: 'link',
                        ),
                      ),

                      // Event User Poster
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: userposterheader(
                            uid: event.uid,
                            profilepic: 'assets/images/avatar 6.jpg',
                            radius: 15,
                            username: '${event.uid}'),
                      ),

                      // Event Descrtiption
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          '${event.caption}',
                          style: TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ),

                      // Event CreatedAt
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            getEventStatus(event.status),
                            SizedBox(
                              width: 7,
                            ),
                            Text(
                              '${timeago.format(event.createdAt, locale: 'fr')}',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          );
  }
}

// Event Row Info
class EventInfoRow extends StatelessWidget {
  final IconData icon;
  final dynamic label;
  final String type;

  getLabelData(_type) {
    if (_type == 'date') {
      return Text(
        label,
        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
      );
    } else if (_type == 'time') {
      return Text(
        label,
        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
      );
    } else if (_type == 'location') {
      return Text(
        label,
        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
      );
    } else if (_type == 'link') {
      return Text(
        label,
        style: TextStyle(fontSize: 16, color: Colors.lightBlue.shade600),
      );
    }

    return const Text('');
  }

  const EventInfoRow(
      {required this.icon, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade600,
          ),
          SizedBox(
            width: 15,
          ),
          getLabelData(type)
        ],
      ),
    );
  }
}

// Get Event Status
Widget getEventStatus(String status) {
  if (status == "pending") {
    return Icon(
      FontAwesomeIcons.clock,
      size: 16,
      color: Colors.grey.shade700,
    );
  } else if (status == "sent") {
    return Icon(
      Icons.done,
      size: 16,
      color: Colors.grey.shade700,
    );
  }

  return Container();
}
