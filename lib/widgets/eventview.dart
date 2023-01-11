import 'dart:developer';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wesh/models/event.dart';
import 'package:wesh/models/reminder.dart';
import 'package:wesh/pages/in.pages/create_or_update_event.dart';
import 'package:wesh/pages/in.pages/inbox.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/button.dart';
import 'package:wesh/widgets/remindercard.dart';
import '../models/user.dart' as usermodel;
import '../models/event_duration_type.dart';
import '../pages/in.pages/create_or_update_reminder.dart';
import '../pages/profile.dart';
import '../services/firestore.methods.dart';
import '../utils/functions.dart';
import 'buildWidgets.dart';

class EventView extends StatefulWidget {
  final String eventId;

  const EventView({Key? key, required this.eventId}) : super(key: key);

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  PageController pageController = PageController(initialPage: 0);

  @override
  void initState() {
    //
    super.initState();
  }

  bool handleOnWillPop() {
    if (pageController.page == 1) {
      pageController.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var willPop = handleOnWillPop();
        return willPop;
      },
      child: ExpandablePageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // PAGE 1 : Main Event Contents
          StreamBuilder<Event>(
            stream: FirestoreMethods.getEventById(widget.eventId),
            builder: (context, snapshot) {
              // Handle error
              if (snapshot.hasError) {
                debugPrint('error: ${snapshot.error}');
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 100),
                  child: Center(
                    child: buildErrorWidget(onWhiteBackground: true),
                  ),
                );
              }

              if (snapshot.hasData && snapshot.data != null) {
                Event event = snapshot.data!;

                //
                setCurrentActivePageFromIndex(index: 6, userId: event.uid);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Event Trailing
                      event.trailing.isEmpty
                          ? CircleAvatar(
                              radius: 0.16.sw,
                              backgroundColor: kGreyColor,
                              backgroundImage: AssetImage('assets/images/eventtype.icons/${event.type}.png'),
                            )
                          : buildCachedNetworkImage(
                              url: event.trailing,
                              radius: 0.16.sw,
                              backgroundColor: kGreyColor,
                              paddingOfProgressIndicator: 10,
                            ),

                      // Event Name
                      const SizedBox(height: 20),
                      Text(
                        event.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
                      ),

                      // Outdate | IsHappening | Coming soon indicator
                      Container(
                        margin: const EdgeInsets.only(bottom: 25, top: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        // decoration: BoxDecoration(
                        //   border:
                        //       Border.all(width: 1.3, color: isOutdatedEvent(event) ? Colors.black87 : kWarningColor),
                        //   borderRadius: BorderRadius.circular(50),
                        // ),
                        child: Text(
                          getEventRelativeStartTime(event),
                          style: TextStyle(
                              fontSize: 11.sp,
                              color: isOutdatedEvent(event)
                                  ? kWarningColor
                                  : isHappeningEvent(event)
                                      ? kSecondColor
                                      : Colors.black54,
                              fontWeight: FontWeight.bold),
                        ),
                      ),

                      // Event Action Button,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // MESSAGE BUTTON OR EDIT EVENT BUTTON
                          event.uid != FirebaseAuth.instance.currentUser!.uid
                              ? Button(
                                  text: 'Message',
                                  height: 0.122.sw,
                                  width: 0.3.sw,
                                  fontsize: 14.sp,
                                  fontColor: Colors.black,
                                  color: Colors.white,
                                  isBordered: true,
                                  prefixIcon: FontAwesomeIcons.message,
                                  prefixIconColor: Colors.black54,
                                  prefixIconSize: 15.sp,
                                  onTap: () {
                                    // Redirect to Inbox /+Event Attached
                                    Navigator.push(
                                      context,
                                      SwipeablePageRoute(
                                        builder: (_) => (InboxPage(
                                          userReceiverId: event.uid,
                                          eventAttached: event,
                                        )),
                                      ),
                                    );
                                  },
                                )
                              : Button(
                                  text: 'Modifier',
                                  height: 0.122.sw,
                                  width: 0.4.sw,
                                  fontsize: 14.sp,
                                  fontColor: Colors.black,
                                  color: Colors.white,
                                  isBordered: true,
                                  prefixIcon: Icons.edit,
                                  prefixIconColor: Colors.black54,
                                  prefixIconSize: 15.sp,
                                  onTap: () async {
                                    // Get UserPoster
                                    usermodel.User? userPoster =
                                        await FirestoreMethods.getUser(FirebaseAuth.instance.currentUser!.uid);

                                    // Edit Event here !
                                    // ignore: use_build_context_synchronously
                                    Navigator.pop(context);
                                    // ignore: use_build_context_synchronously
                                    Navigator.push(
                                      context,
                                      SwipeablePageRoute(
                                        builder: (_) => (CreateOrUpdateEventPage(
                                          event: event,
                                          userPoster: userPoster,
                                        )),
                                      ),
                                    );
                                  },
                                ),

                          const SizedBox(width: 14),

                          // REMINDER BUTTON
                          StreamBuilder<List<Reminder>>(
                            stream: FirestoreMethods.getEventRemindersById(
                                widget.eventId, FirebaseAuth.instance.currentUser!.uid),
                            builder: (context, snapshot) {
                              // Handle error
                              if (snapshot.hasError) {
                                debugPrint('error: ${snapshot.error}');
                                return Button(
                                  text: 'Erreur...',
                                  height: 0.122.sw,
                                  width: 0.4.sw,
                                  fontsize: 14.sp,
                                  fontColor: Colors.white,
                                  color: kSecondColor,
                                  prefixIcon: Icons.running_with_errors_outlined,
                                  prefixIconColor: Colors.white,
                                  prefixIconSize: 15.sp,
                                  onTap: () async {
                                    // Display All Reminders setted for this event
                                    pageController.nextPage(
                                        duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
                                  },
                                );
                              }

                              // handle data
                              if (snapshot.hasData && snapshot.data != null) {
                                List<Reminder> listReminder = snapshot.data as List<Reminder>;
                                log('listReminder: $listReminder');
                                int numberOfReminders = listReminder.length;

                                return Button(
                                  text: numberOfReminders == 0
                                      ? 'Me rappeler'
                                      : '$numberOfReminders Rappel${numberOfReminders > 1 ? 's' : ''}',
                                  height: 0.122.sw,
                                  width: 0.4.sw,
                                  fontsize: 14.sp,
                                  fontColor: Colors.white,
                                  color: kSecondColor,
                                  prefixIcon: Icons.timer_outlined,
                                  prefixIconColor: Colors.white,
                                  prefixIconSize: 15.sp,
                                  onTap: () async {
                                    // Display All Reminders setted for this event
                                    pageController.nextPage(
                                        duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
                                  },
                                );
                              }

                              // Diplay Loader

                              return Button(
                                text: 'Rappels',
                                height: 0.122.sw,
                                width: 0.4.sw,
                                fontsize: 14.sp,
                                fontColor: Colors.white,
                                prefixIsLoading: true,
                                color: kSecondColor,
                                prefixIcon: Icons.timer_outlined,
                                prefixIconColor: Colors.white,
                                prefixIconSize: 15.sp,
                                onTap: () async {
                                  // Display All Reminders setted for this event
                                  pageController.nextPage(
                                      duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
                                },
                              );
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
                          // Event User Poster
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: GestureDetector(
                                  onTap: () {
                                    // Redirect to Profile Page
                                    Navigator.push(
                                        context,
                                        SwipeablePageRoute(
                                          builder: (context) => ProfilePage(uid: event.uid, showBackButton: true),
                                        ));
                                  },
                                  child: buildAvatarAndUsername(
                                    uidPoster: event.uid,
                                    radius: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Event Type
                          event.type.isNotEmpty
                              ? EventInfoRow(
                                  icon: FontAwesomeIcons.splotch,
                                  label: getEventTitle(event.type),
                                  type: 'eventType',
                                )
                              : Container(),

                          // Event Date + Time
                          ...event.eventDurations.map((eventDuration) {
                            EventDurationType eventDurationGet =
                                EventDurationType.fromJson((eventDuration as Map<String, dynamic>));

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                EventInfoRow(
                                  noTextWrappring: true,
                                  icon: isEventWithRecurrence(event) ? Icons.cake_outlined : Icons.calendar_today,
                                  label:
                                      DateFormat(isEventWithRecurrence(event) ? 'dd MMMM' : 'EEE, d MMM yyyy', 'fr_Fr')
                                          .format(eventDurationGet.date),
                                  type: 'date',
                                ),

                                Transform.translate(
                                  offset: const Offset(0, 5),
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 3, right: 3),
                                    child: Icon(Icons.navigate_next_rounded, color: kSecondColor),
                                  ),
                                ),

                                // // Event Time
                                Expanded(
                                  child: EventInfoRow(
                                    icon:
                                        eventDurationGet.isAllTheDay == true ? Icons.sunny : Icons.access_time_outlined,
                                    label: eventDurationGet.isAllTheDay
                                        ? 'Toute la journée'
                                        : '${eventDurationGet.startTime.hour.toString().padLeft(2, "0")}:${eventDurationGet.startTime.minute.toString().padLeft(2, "0")} à ${eventDurationGet.endTime.hour.toString().padLeft(2, "0")}:${eventDurationGet.endTime.minute.toString().padLeft(2, "0")}',
                                    type: 'time',
                                  ),
                                ),
                              ],
                            );
                          }).toList(),

                          // Event Location
                          event.location.isNotEmpty
                              ? EventInfoRow(
                                  icon: FontAwesomeIcons.locationDot,
                                  label: event.location,
                                  type: 'location',
                                )
                              : Container(),

                          // Event Link
                          event.link.isNotEmpty
                              ? InkWell(
                                  onTap: () async {
                                    Uri urlToLaunch = Uri.parse(event.link);

                                    if (!event.link.startsWith("http://") && !event.link.startsWith("https://")) {
                                      urlToLaunch = Uri.parse("http://${event.link}");
                                    }

                                    if (!await launchUrl(urlToLaunch)) {
                                      showSnackbar(context, 'Impossible de lancer cette url', null);
                                      throw 'Could not launch $urlToLaunch';
                                    }
                                  },
                                  child: EventInfoRow(
                                    icon: FontAwesomeIcons.link,
                                    label: event.link,
                                    type: 'link',
                                  ),
                                )
                              : Container(),

                          // Event Descrtiption
                          event.caption.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Text(
                                    event.caption,
                                    style: TextStyle(fontSize: 12.sp, color: Colors.black87),
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
                                Icon(
                                  Icons.done,
                                  size: 13.sp,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  '${event.createdAt.isBefore(event.modifiedAt) ? 'Modifié ' : 'Crée '}${getTimeAgoLongForm(event.createdAt)}',
                                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
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

              // Diplay Loader
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30, top: 20),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.grey.shade400,
                        child: CircleAvatar(
                          radius: 0.1.sw,
                        ),
                      ),
                    ),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade400,
                      child: Container(
                          margin: const EdgeInsets.only(bottom: 2),
                          width: 200,
                          height: 19,
                          color: Colors.grey.shade400),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Column(
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade200,
                          highlightColor: Colors.grey.shade400,
                          child: Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              width: 250,
                              height: 12,
                              color: Colors.grey.shade400),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade200,
                          highlightColor: Colors.grey.shade400,
                          child: Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              width: 250,
                              height: 12,
                              color: Colors.grey.shade400),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade200,
                          highlightColor: Colors.grey.shade400,
                          child: Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              width: 250,
                              height: 12,
                              color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ],
                );
              }

              return Container();
            },
          ),

          // PAGE 2 : All Event's Reminders
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      // Back Button
                      IconButton(
                        splashRadius: 0.06.sw,
                        onPressed: () {
                          pageController.previousPage(
                              duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.black,
                        ),
                      ),

                      // Modal Title
                      Text(
                        'Rappels',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17.sp,
                        ),
                      ),

                      const Spacer(),

                      // Add Reminder Button
                      Button(
                        text: 'Ajouter',
                        height: 0.12.sw,
                        width: double.infinity,
                        fontsize: 13.sp,
                        fontColor: Colors.black,
                        color: Colors.white,
                        isBordered: true,
                        prefixIcon: Icons.add,
                        prefixIconColor: Colors.black,
                        prefixIconSize: 19,
                        onTap: () async {
                          // Edit Event here !
                          Event? eventGet = await FirestoreMethods.getEventByIdAsFuture(widget.eventId);
                          // ignore: use_build_context_synchronously
                          Navigator.push(
                            context,
                            SwipeablePageRoute(
                              builder: (_) => (CreateOrUpdateReminderPage(eventAttached: eventGet)),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // REMINDERS LIST
                StreamBuilder<List<Reminder>>(
                  stream:
                      FirestoreMethods.getEventRemindersById(widget.eventId, FirebaseAuth.instance.currentUser!.uid),
                  builder: (context, snapshot) {
                    // Handle error
                    if (snapshot.hasError) {
                      debugPrint('error: ${snapshot.error}');
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 100),
                        child: Column(
                          children: const [
                            Center(
                              child: buildErrorWidget(onWhiteBackground: true),
                            ),
                          ],
                        ),
                      );
                    }

                    // handle data
                    if (snapshot.hasData && snapshot.data != null) {
                      List<Reminder> listReminder = snapshot.data as List<Reminder>;
                      log('listReminder: $listReminder');
                      listReminder.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                      if (listReminder.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(30),
                          height: 300,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                height: 150,
                                empty,
                                width: double.infinity,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Aucun rappel trouvé !',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView(
                        shrinkWrap: true,
                        children: listReminder.map((reminder) {
                          return ReminderCard(reminder: reminder);
                        }).toList(),
                      );
                    }

                    // Diplay Loader
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Shimmer.fromColors(
                            baseColor: Colors.grey.shade200,
                            highlightColor: Colors.grey.shade400,
                            child: Container(
                                margin: const EdgeInsets.only(bottom: 2),
                                width: 200,
                                height: 20,
                                color: Colors.grey.shade400),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Shimmer.fromColors(
                            baseColor: Colors.grey.shade200,
                            highlightColor: Colors.grey.shade400,
                            child: Container(
                                margin: const EdgeInsets.only(bottom: 2),
                                width: 200,
                                height: 20,
                                color: Colors.grey.shade400),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Shimmer.fromColors(
                            baseColor: Colors.grey.shade200,
                            highlightColor: Colors.grey.shade400,
                            child: Container(
                                margin: const EdgeInsets.only(bottom: 2),
                                width: 200,
                                height: 20,
                                color: Colors.grey.shade400),
                          ),
                        ],
                      );
                    }

                    return Container();
                  },
                ),
              ],
            ),
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
  final bool? noTextWrappring;

  Widget getLabelData(type) {
    if (type == 'date') {
      return Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
      );
    } else if (type == 'time') {
      return Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
      );
    } else if (type == 'location' || type == 'eventType') {
      return Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
      );
    } else if (type == 'link') {
      return Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13.sp, color: Colors.lightBlue.shade600),
      );
    }

    return const Text('');
  }

  const EventInfoRow({Key? key, required this.icon, required this.label, required this.type, this.noTextWrappring})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        children: [
          Icon(
            icon,
            size: 15.sp,
            color: Colors.grey.shade600,
          ),
          const SizedBox(
            width: 7,
          ),
          noTextWrappring == true
              ? getLabelData(type)
              : Expanded(
                  child: Wrap(
                    children: [
                      getLabelData(type),
                    ],
                  ),
                )
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
