import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wesh/models/event.dart';
import 'package:wesh/pages/in.pages/create_or_update_event.dart';
import 'package:wesh/pages/in.pages/inbox.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/button.dart';
import 'package:wesh/widgets/reminderselector.dart';
import 'package:wesh/widgets/userposterheader.dart';

import '../utils/functions.dart';
import 'buildWidgets.dart';

class EventView extends StatefulWidget {
  late DateTime? reminderDate = null;
  final Event event;

  EventView({required this.event});

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Check if the Event Date has a Reminder
    // TO DO
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Event Trailing
          widget.event.trailing.isEmpty
              ? CircleAvatar(
                  radius: 70,
                  backgroundColor: kGreyColor,
                  backgroundImage: AssetImage(
                      'assets/images/eventtype.icons/${widget.event.type}.png'),
                )
              : CircleAvatar(
                  radius: 70,
                  backgroundColor: kGreyColor,
                  backgroundImage: NetworkImage(widget.event.trailing),
                ),

          // Event Name
          const SizedBox(height: 20),
          Text(
            widget.event.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          // Event Action Button
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // MESSAGE BUTTON OR EDIT EVENT BUTTON
              widget.event.uid != FirebaseAuth.instance.currentUser!.uid
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
                                uid: widget.event.uid,
                                eventAttached: widget.event)),
                          ),
                        );
                      },
                    )
                  : Button(
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
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => (CreateOrUpdateEventPage(
                              event: widget.event,
                            )),
                          ),
                        );
                        ;
                      },
                    ),

              const SizedBox(width: 14),

              // REMINDER BUTTON
              Button(
                text: widget.reminderDate == null ? 'Me rappeler' : 'Rappel',
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

                  Duration? selectedDuration = await showModalBottomSheet(
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
                      debugPrint(
                          'Reminder is setted at: ${widget.reminderDate}');
                    });
                  }
                  if (selectedDuration == null) {
                    setState(() {
                      widget.reminderDate = null;
                      debugPrint(
                          'Reminder is setted at: ${widget.reminderDate}');
                    });
                  }
                },
              ),
            ],
          ),

          // Event Info
          const SizedBox(height: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Date
              EventInfoRow(
                icon: FontAwesomeIcons.calendar,
                label: DateFormat('EEE, d MMM yyyy', 'fr_Fr')
                    .format(widget.event.startDateTime),
                type: 'date',
              ),

              // Event Time
              EventInfoRow(
                icon: FontAwesomeIcons.clock,
                label:
                    '${DateFormat('HH:mm', 'fr_Fr').format(widget.event.startDateTime)} à ${DateFormat('HH:mm', 'fr_Fr').format(widget.event.endDateTime)}',
                type: 'time',
              ),

              // Event Location
              widget.event.location.isNotEmpty
                  ? EventInfoRow(
                      icon: FontAwesomeIcons.locationDot,
                      label: widget.event.location,
                      type: 'location',
                    )
                  : Container(),

              // Event Link
              widget.event.link.isNotEmpty
                  ? InkWell(
                      onTap: () async {
                        final Uri url = Uri.parse(widget.event.link);

                        Uri urlToLaunch = Uri.parse(widget.event.link);

                        if (!widget.event.link.startsWith("http://") &&
                            !widget.event.link.startsWith("https://")) {
                          urlToLaunch =
                              Uri.parse("http://${widget.event.link}");
                        }

                        if (!await launchUrl(urlToLaunch)) {
                          showSnackbar(
                              context, 'Impossible de lancer cette url', null);
                          throw 'Could not launch $urlToLaunch';
                        }
                      },
                      child: EventInfoRow(
                        icon: FontAwesomeIcons.link,
                        label: widget.event.link,
                        type: 'link',
                      ),
                    )
                  : Container(),

              // Event User Poster
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: buildAvatarAndUsername(uidPoster: widget.event.uid),
              ),

              // Event Descrtiption
              widget.event.caption.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        widget.event.caption,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black87),
                      ),
                    )
                  : Container(),

              // Event CreatedAt
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // getEventStatus(widget.event.status),
                    // SizedBox(
                    //   width: 7,
                    // ),
                    Text(
                      'Crée ${(() {
                        timeago.setLocaleMessages('fr', timeago.FrMessages());
                        return timeago.format(widget.event.createdAt,
                            locale: 'fr');
                      }())}',
                      style:
                          TextStyle(fontSize: 15, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
          const SizedBox(
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
