import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:uuid/uuid.dart';
import 'package:wesh/models/event.dart';
import 'package:wesh/pages/in.pages/searchpage.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/userposterheader.dart';

import '../services/notifications_api.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  List<Event> _events = [];
  DateTime dateSelected = DateTime.now();
  late CalendarController calendarController;
  bool isLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  initState() {
    super.initState();

    calendarController = CalendarController();
    calendarController.selectedDate = dateSelected;
    calendarController.displayDate = dateSelected;

    // Refresh all events
    refreshEvents();
  }

  Future refreshEvents() async {
    _events = [];
    setState(() => isLoading = true);
    // _events = await SqlDatabase.instance.readAllEvents();
    setState(() => isLoading = false);

    return _events;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  List<Event> _getDataSource() {
    return _events;
  }

  @override
  Widget build(BuildContext context) {
    //Notice the super-call here.
    super.build(context);

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, 0.08.sh),
          child: MorphingAppBar(
            heroTag: 'homePageAppBar',
            elevation: 1,
            backgroundColor: Colors.white,
            title: GestureDetector(
              onTap: () {
                // Set selected date to Now()

                setState(() {
                  calendarController.displayDate = DateTime.now();
                });
              },
              child: SvgPicture.asset(
                weshLogoColored,
                height: 0.09.sw,
                color: kSecondColor,
              ),
            ),
            actions: [
              IconButton(
                splashRadius: 0.06.sw,
                onPressed: () {
                  // Open Search Page
                  Navigator.push(
                      context,
                      SwipeablePageRoute(
                        builder: (context) => SearchPage(),
                      ));
                },
                icon: const Icon(Icons.search, size: 30, color: Colors.black),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(40),
              child: TextButton(onPressed: () async {}, child: const Text('Show notification !')),
            ),
            Container(
              child: isLoading
                  ? LinearProgressIndicator(
                      backgroundColor: kSecondColor.withOpacity(0.2),
                      color: kSecondColor,
                    )
                  : Container(),
            ),
            Expanded(
              child: SfCalendar(
                firstDayOfWeek: DateTime.monday,
                scheduleViewMonthHeaderBuilder: (BuildContext buildContext, ScheduleViewMonthHeaderDetails details) {
                  return buildCalendarScheduleHeader(
                    details: details,
                  );
                },
                todayTextStyle: TextStyle(color: Colors.white, fontSize: 14.sp),
                view: CalendarView.schedule,
                showCurrentTimeIndicator: true,
                allowAppointmentResize: true,
                scheduleViewSettings: ScheduleViewSettings(
                  appointmentItemHeight: 0.2.sw,
                  appointmentTextStyle: TextStyle(color: Colors.white, fontSize: 10.sp),
                ),
                appointmentBuilder: ((context, calendarAppointmentDetails) {
                  final Event appointment = calendarAppointmentDetails.appointments.first;

                  return buildEventContainer(appointment: appointment);
                }),
                onTap: (calendarTapDetails) {
                  debugPrint('sfC: ${calendarTapDetails.date}');
                },
                headerHeight: 0,
                dataSource: EventDataSource(_getDataSource()),
                controller: calendarController,
              ),
            ),
          ],
        ));
  }
}

// Calendar Schedule Event Container
class buildEventContainer extends StatelessWidget {
  final Event appointment;
  const buildEventContainer({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // Show EventView Modal
        // showModalBottomSheet(
        //   enableDrag: true,
        //   isScrollControlled: true,
        //   context: context,
        //   backgroundColor: Colors.transparent,
        //   builder: ((context) => Modal(
        //         maxChildSize: 1,
        //         initialChildSize: .8,
        //         minChildSize: .8,
        //         child: EventView(eventId: appointment.eventId),
        //       )),
        // );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: eventAvailableColorsList[appointment.color],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              appointment.title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Event User poster
                const userposterheader(
                    uid: '2',
                    profilepic: 'assets/images/picture 3.jpg',
                    radius: 14,
                    spacebetween: 13,
                    usernameColor: Colors.white,
                    username: 'username'),

                // Event Time
                Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.clock,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    Text(
                      '${DateFormat('hh:mm', 'fr_Fr').format(appointment.eventDurations[0].startTime)} à ${DateFormat('hh:mm', 'fr_Fr').format(appointment.eventDurations[0].startTime)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Calendar Schedule Header
class buildCalendarScheduleHeader extends StatelessWidget {
  final ScheduleViewMonthHeaderDetails details;
  const buildCalendarScheduleHeader({required this.details});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/months.calendarscreens/${details.date.month}.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.grey.shade200, BlendMode.darken)),
          color: kPrimaryColor.withOpacity(0.5),
        ),
        child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.bottomRight, colors: [
            Colors.transparent,
            Colors.black26,
          ])),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              DateFormat('MMMM yyyy').format(details.date),
              style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w500),
            ),
          ),
        ));
  }
}

// Calendar Data Source [class]
class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Event> source) {
    appointments = source;
  }

  @override
  String getTitle(int index) {
    return appointments![index].title;
  }

  @override
  String getCaption(int index) {
    return appointments![index].caption;
  }

  String getTrailing(int index) {
    return appointments![index].trailing;
  }

  @override
  Color getColor(int index) {
    return eventAvailableColorsList[appointments![index].color];
  }

  @override
  String getLocation(int index) {
    return appointments![index].location;
  }

  @override
  String getLink(int index) {
    return appointments![index].link;
  }

  @override
  DateTime getDate(int index) {
    return appointments![index].date;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endTime;
  }
}
