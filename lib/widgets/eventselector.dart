import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wesh/models/discussion.dart';
import 'package:wesh/models/event.dart';
import 'package:wesh/utils/db.dart';
import 'package:wesh/widgets/discussioncard.dart';
import 'package:wesh/widgets/searcheventcard.dart';

class EventSelector extends StatefulWidget {
  final String? uid;
  const EventSelector({this.uid});

  @override
  State<EventSelector> createState() => _EventSelectorState();
}

class _EventSelectorState extends State<EventSelector> {
  List<Widget> getEventsResults() {
    List<Widget> eventsResultsWidgets = [];
    Event event;

    for (var event in eventsList) {
      var eventwidget = GestureDetector(
        child: SearchEventCard(
            event: event,
            onTap: () {
              // Pop Event Selector Modal
              // Send back Selected EventId
              Navigator.pop(context, event);
            }),
      );

      if (widget.uid != null && widget.uid == event.uid) {
        eventsResultsWidgets.add(eventwidget);
      } else if (widget.uid == null) {
        eventsResultsWidgets.add(eventwidget);
      }
    }

    return eventsResultsWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Event Bar
        Visibility(
          visible: widget.uid != null ? false : true,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.all(10),
              child: CupertinoSearchTextField(
                prefixIcon: Container(),
                placeholder: "Rechercher un évenement...",
                backgroundColor: Color(0xFFF0F0F0),
              ),
            ),
          ),
        ),

        Visibility(
          visible: widget.uid == null ? false : true,
          child: Padding(
            padding: EdgeInsets.only(bottom: 12, top: 20),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: Text(
                'Evénements de ${widget.uid}',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 25),
              ),
            ),
          ),
        ),

        // Remove any attached event
        InkWell(
          onTap: () {
            // Pop the modal
            // Send back the Selected Event
            Navigator.pop(context, null);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade400,
                  child: Icon(
                    FontAwesomeIcons.linkSlash,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact name
                      Text(
                        'Retirer l\'évenement attaché',
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w700,
                            fontSize: 17),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
              ],
            ),
          ),
        ),

        // Events List

        Column(
          children: getEventsResults(),
        )
        // ListView(children: [
        //   SearchEventCard(
        //     event: eventsList[0],
        //     onTap: () {
        //       // Pop the modal
        //       // Send back the Selected Event
        //       Navigator.pop(context, eventsList[0].eventId);
        //     },
        //   )
        // ])
      ],
    );
  }
}
