// ignore_for_file: file_names
import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';
import 'package:rxdart/rxdart.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:wesh/models/event.dart';
import 'package:wesh/pages/in.pages/searchpage.dart';
import 'package:wesh/services/firestore.methods.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/buildWidgets.dart';
import '../models/event_duration_type.dart';
import '../models/reminder.dart';
import '../models/user.dart' as usermodel;
import '../widgets/eventview.dart';
import '../widgets/modal.dart';
import '../widgets/reminderView.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.outsideRefreshCalendar});

  final ValueNotifier<bool>? outsideRefreshCalendar;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  usermodel.User? currentUser;
  List<Appointment> appointmentList = [];
  List<String> currentUserFollowings = [FirebaseAuth.instance.currentUser!.uid];
  List<Event> eventsList = [];
  List<Reminder> remindersList = [];

  DateTime dateSelected = DateTime.now();
  late CalendarController calendarController;
  ValueNotifier<bool> isUpdating = ValueNotifier<bool>(false);
  //
  late Stream<usermodel.User> streamCurrentUser;
  late StreamSubscription<usermodel.User> streamCurrentUserSubscription;

  late CombineLatestStream<Object, List<Object>> streamEventsAndReminders;
  late StreamSubscription<List<Object>> streamEventsAndRemindersSubscription;

  @override
  initState() {
    super.initState();

    calendarController = CalendarController();
    calendarController.selectedDate = dateSelected;
    calendarController.displayDate = dateSelected;

    // INIT CALENDAR /+ Listen to incoming events and reminders
    streamCurrentUser = FirestoreMethods.getUserById(FirebaseAuth.instance.currentUser!.uid);
    streamCurrentUserSubscription = streamCurrentUser.asBroadcastStream().listen((event) {
      isUpdating.value = true;
      currentUser = event;

      currentUserFollowings = event.followings?.map((userId) => userId.toString()).toList() ?? [];

      // Add [Me] in Following --> to display also my Events
      currentUserFollowings.insert(0, FirebaseAuth.instance.currentUser!.uid);

      streamEventsAndReminders = CombineLatestStream.list([
        FirestoreMethods.getEventsByUserPosterIdInList(currentUserFollowings),
        FirestoreMethods.getRemindersByUserPosterIdInList([FirebaseAuth.instance.currentUser!.uid]),
      ]);

      streamEventsAndRemindersSubscription = streamEventsAndReminders.asBroadcastStream().listen((event) {
        eventsList = (event[0] as List<Event>);
        remindersList = (event[1] as List<Reminder>);

        initAppointmentsAndReminders(eventsList: eventsList, remindersList: remindersList);
      });
    });

    // Listen to refresh Calendar: from outside
    if (widget.outsideRefreshCalendar != null) {
      widget.outsideRefreshCalendar?.addListener(() {
        if (widget.outsideRefreshCalendar!.value) {
          refreshCalendar();
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    //
    calendarController.dispose();
    //
    streamCurrentUserSubscription.cancel();
    streamEventsAndRemindersSubscription.cancel();
  }

  List<Appointment> _getDataSource() {
    return appointmentList;
  }

  Future initAppointmentsAndReminders({required List<Event> eventsList, required List<Reminder> remindersList}) async {
    List<Appointment> appointmentItems = [];
    // FETCH EVENTS
    for (Event eventGet in eventsList) {
      // Split Event by EventDurationType => return CalendarItem
      for (var eventduration in eventGet.eventDurations) {
        EventDurationType eventDurationGet = EventDurationType.fromJson((eventduration as Map<String, dynamic>));

        // Set Reccurence Rule
        bool hasReccurence = eventAvailableTypeList.where((event) => event.key == eventGet.type).first.recurrence;
        String reccurenceRule = '';

        DateTime startTime = DateTime(
          eventDurationGet.date.year,
          eventDurationGet.date.month,
          eventDurationGet.date.day,
          eventDurationGet.startTime.hour,
          eventDurationGet.startTime.minute,
        );
        DateTime endTime = DateTime(
          eventDurationGet.date.year,
          eventDurationGet.date.month,
          eventDurationGet.date.day,
          eventDurationGet.endTime.hour,
          eventDurationGet.endTime.minute,
        );

        if (hasReccurence) {
          RecurrenceProperties recurrence = RecurrenceProperties(
            startDate: startTime,
            endDate: endTime,
            month: startTime.month,
            dayOfMonth: startTime.day,
          );
          recurrence.recurrenceType = RecurrenceType.yearly;

          reccurenceRule = SfCalendar.generateRRule(recurrence, startTime, endTime);
        }

        Appointment appointment = Appointment(
          startTime: startTime,
          endTime: endTime,
          notes: 'event:${eventGet.eventId}:${eventGet.uid}:${eventGet.type}',
          color: eventAvailableColorsList[eventGet.color],
          isAllDay: eventDurationGet.isAllTheDay,
          subject: eventGet.title,
          recurrenceRule: reccurenceRule,
        );

        appointmentItems.add(appointment);
      }
    }

    // FETCH REMINDERS
    for (Reminder reminderGet in remindersList) {
      // Get reccurence
      String reccurenceRule = '';

      if (reminderGet.recurrence != '') {
        RecurrenceProperties recurrence = RecurrenceProperties(
          startDate: reminderGet.remindAt,
          endDate: reminderGet.remindAt,
          dayOfMonth: reminderGet.remindAt.day,
          dayOfWeek: reminderGet.remindAt.weekday,
          month: reminderGet.remindAt.month,
        );

        if (reminderGet.recurrence == 'Chaque jour') {
          recurrence.recurrenceType = RecurrenceType.daily;
        } else if (reminderGet.recurrence == 'Chaque semaine') {
          recurrence.recurrenceType = RecurrenceType.weekly;
          recurrence.weekDays = [WeekDays.values[reminderGet.remindAt.weekday]];
        } else if (reminderGet.recurrence == 'Chaque mois') {
          recurrence.recurrenceType = RecurrenceType.monthly;
        } else if (reminderGet.recurrence == 'Chaque année') {
          recurrence.recurrenceType = RecurrenceType.yearly;
        }

        reccurenceRule = SfCalendar.generateRRule(recurrence, reminderGet.remindAt, reminderGet.remindAt);
      }

      Appointment appointment = Appointment(
        startTime: reminderGet.remindAt,
        endTime: reminderGet.remindAt,
        notes: 'reminder:${reminderGet.reminderId}:${reminderGet.uid}:...',
        color: Colors.blue,
        isAllDay: false,
        subject: reminderGet.title,
        recurrenceRule: reccurenceRule,
      );

      appointmentItems.add(appointment);
    }

    if (mounted) {
      setState(() {
        appointmentList = appointmentItems;
        calendarController.displayDate = DateTime.now();
      });
    }

    isUpdating.value = false;
  }

  refreshCalendar() async {
    // Set selected date to Now()
    isUpdating.value = true;
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      calendarController.displayDate = DateTime.now();
    });
    await Future.delayed(const Duration(milliseconds: 500));
    isUpdating.value = false;
  }

  @override
  Widget build(BuildContext context) {
    //Notice the super-call here.
    super.build(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 0.08.sh),
        child: MorphingAppBar(
          toolbarHeight: 46,
          scrolledUnderElevation: 0.0,
          heroTag: 'homePageAppBar',
          elevation: 1,
          backgroundColor: Colors.white,
          title: GestureDetector(
            onTap: () {
              refreshCalendar();
            },
            child: SvgPicture.asset(
              weshLogoColored,
              height: 0.09.sw,
              colorFilter: const ColorFilter.mode(kSecondColor, BlendMode.srcIn),
            ),
          ),
          actions: [
            // Loader Icon: visible only if there's something loading within this page
            ValueListenableBuilder(
              valueListenable: isUpdating,
              builder: (context, value, child) {
                return Visibility(
                  visible: isUpdating.value,
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    child: const CupertinoActivityIndicator(
                      color: Colors.black,
                      animating: true,
                    ),
                  ),
                );
              },
            ),

            // Search Icon
            IconButton(
              splashRadius: 0.06.sw,
              onPressed: () {
                // Open Search Page
                Navigator.push(
                    context,
                    SwipeablePageRoute(
                      builder: (context) => const SearchPage(),
                    ));
              },
              icon: const Icon(Icons.search, size: 30, color: Colors.black),
            ),
          ],
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              // MAIN CONTENT: Sf Calendar
              Expanded(
                child: SfCalendar(
                  firstDayOfWeek: DateTime.monday,
                  scheduleViewMonthHeaderBuilder: (BuildContext buildContext, ScheduleViewMonthHeaderDetails details) {
                    return BuildCalendarScheduleHeader(
                      currentUser: currentUser,
                      details: details,
                    );
                  },
                  todayTextStyle: TextStyle(locale: const Locale('en', 'EN'), color: Colors.white, fontSize: 14.sp),
                  view: CalendarView.schedule,
                  showCurrentTimeIndicator: true,
                  allowAppointmentResize: true,
                  scheduleViewSettings: ScheduleViewSettings(
                    hideEmptyScheduleWeek: true,
                    appointmentItemHeight: 0.12.sh,
                    appointmentTextStyle: TextStyle(color: Colors.white, fontSize: 10.sp),
                  ),
                  appointmentBuilder: ((context, calendarAppointmentDetails) {
                    final Appointment appointment = calendarAppointmentDetails.appointments.first;

                    return BuildEventContainer(appointment: appointment, currentUser: currentUser);
                  }),
                  onTap: (calendarTapDetails) {
                    log('Date tapped: ${calendarTapDetails.date}');
                  },
                  headerHeight: 0,
                  dataSource: AppointmentDataSource(_getDataSource()),
                  controller: calendarController,
                ),
              ),
            ],
          ),

          // MAIN LOADER
          ValueListenableBuilder(
            valueListenable: isUpdating,
            builder: (context, value, child) {
              return isUpdating.value
                  ? Container(
                      color: Colors.black54.withOpacity(.5),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      alignment: Alignment.center,
                    )
                  : Container();
            },
          ),
        ],
      ),
    );
  }
}

// Calendar Schedule Event Container
class BuildEventContainer extends StatefulWidget {
  final Appointment appointment;
  final usermodel.User? currentUser;
  const BuildEventContainer({super.key, required this.appointment, this.currentUser});

  @override
  State<BuildEventContainer> createState() => BuildEventContainerState();
}

class BuildEventContainerState extends State<BuildEventContainer> {
  String itemType = '';
  String contentId = '';
  String userPosterId = '';
  String eventType = '';
  bool isOutdated = false;
  //
  double containerOpacity = 1.0;
  Color onPressedColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    String notes = widget.appointment.notes ?? '';
    itemType = notes.split(':')[0];
    contentId = notes.split(':')[1];
    userPosterId = notes.split(':')[2];
    eventType = notes.split(':')[3];
    isOutdated = notes.split(':')[3] == 'true' ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: containerOpacity,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTapDown: (_) {
          // set iOS-style on Tap down
          debugPrint('Button tap down !');
          setState(() {
            containerOpacity = 0.7;
            onPressedColor = Colors.white.withOpacity(0.2);
          });
        },
        onTapUp: (_) {
          // set iOS-style on Tap down
          debugPrint('Button tap up !');
          setState(() {
            containerOpacity = 1;
            onPressedColor = Colors.transparent;
          });
        },
        onTapCancel: () {
          // set iOS-style on Tap down
          debugPrint('Button tap cancelled !');
          setState(() {
            containerOpacity = 1;
            onPressedColor = Colors.transparent;
          });
        },
        onTap: () {
          // FOR EVENTS
          if (itemType == 'event') {
            // Show EventView Modal
            showModalBottomSheet(
              enableDrag: true,
              isScrollControlled: true,
              context: context,
              backgroundColor: Colors.transparent,
              builder: ((context) => Modal(
                    minHeightSize: MediaQuery.of(context).size.height / 1.4,
                    maxHeightSize: MediaQuery.of(context).size.height,
                    child: EventView(eventId: contentId),
                  )),
            );
          }

          // FOR REMINDERS
          else if (itemType == 'reminder') {
            // Show ReminderView Modal
            showModalBottomSheet(
              enableDrag: true,
              isScrollControlled: true,
              context: context,
              backgroundColor: Colors.transparent,
              builder: ((context) => Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Modal(
                      child: ReminderView(reminderId: contentId),
                    ),
                  )),
            );
          }
        },
        child: Stack(
          children: [
            // MAIN CONTENT
            Container(
              // constraints: BoxConstraints(maxHeight:0.12.sh),
              height: 0.12.sh,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: itemType == 'reminder' ? Colors.transparent : widget.appointment.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  // For my birthday only
                  widget.currentUser != null &&
                          widget.currentUser!.id == userPosterId &&
                          itemType == 'event' &&
                          eventType == 'birthday' &&
                          DateUtils.dateOnly(DateTime(widget.currentUser!.birthday.year,
                                  widget.appointment.startTime.month, widget.appointment.startTime.day)) ==
                              DateUtils.dateOnly(widget.currentUser!.birthday)
                      ? const Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  '🎂 Your birthday 🥳',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        )
                      :

                      // Others type of events /reminders
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                // ONLY FOR [REMINDER] - TITLE
                                itemType == 'reminder'
                                    ? Padding(
                                        padding: const EdgeInsets.only(right: 5),
                                        child: Row(
                                          children: [
                                            Icon(FontAwesomeIcons.clockRotateLeft, size: 12.sp, color: Colors.black54),
                                            const SizedBox(width: 5),
                                            Text(
                                              'Reminder',
                                              style: TextStyle(
                                                  fontSize: 13.sp, color: Colors.black54, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      )
                                    :

                                    // ONLY FOR [EVENT] - TITLE
                                    Text(
                                        widget.appointment.subject,
                                        style: TextStyle(
                                            fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600),
                                      ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 7),
                              child:
                                  // ONLY FOR [REMINDER] - SUBTITLE
                                  itemType == 'reminder'
                                      ? Row(
                                          children: [
                                            Wrap(
                                              children: [
                                                Text(
                                                  widget.appointment.subject,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.black87,
                                                      fontSize: 12.sp),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      :
                                      // ONLY FOR [EVENT] - SUBTITLE
                                      Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Event User poster
                                            Container(
                                              constraints: const BoxConstraints(maxWidth: 120),
                                              child: Wrap(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      BuildAvatarAndUsername(
                                                        uidPoster: userPosterId,
                                                        radius: 0.02.sw,
                                                        loaderRadius: 0.035.sw,
                                                        fontColor: Colors.white,
                                                        fontSize: 12.sp,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Event Time
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Icon(
                                                  widget.appointment.isAllDay
                                                      ? Icons.sunny
                                                      : Icons.access_time_outlined,
                                                  size: 12.sp,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(
                                                  width: 4,
                                                ),
                                                Wrap(
                                                  children: [
                                                    Text(
                                                      widget.appointment.isAllDay
                                                          ? 'All-day'
                                                          : 'from ${widget.appointment.startTime.hour.toString().padLeft(2, "0")}:${widget.appointment.startTime.minute.toString().padLeft(2, "0")} to ${widget.appointment.endTime.hour.toString().padLeft(2, "0")}:${widget.appointment.endTime.minute.toString().padLeft(2, "0")}',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                            ),
                          ],
                        ),
            ),

            // onPressed Cover
            Container(
              height: 0.12.sh,
              width: double.infinity,
              decoration: BoxDecoration(
                color: onPressedColor,
                borderRadius: BorderRadius.circular(12),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Calendar Schedule Header
class BuildCalendarScheduleHeader extends StatelessWidget {
  final ScheduleViewMonthHeaderDetails details;
  final usermodel.User? currentUser;
  const BuildCalendarScheduleHeader({super.key, required this.details, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                  'assets/images/months.calendarscreens/${currentUser != null && currentUser!.birthday.month == details.date.month ? 13 : details.date.month}.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black87.withOpacity(.4), BlendMode.darken)),
          color: kPrimaryColor.withOpacity(0.5),
        ),
        child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.bottomRight, colors: [
            Colors.transparent,
            Colors.black26,
          ])),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                ReCase(DateFormat('MMMM yyyy', 'en_En').format(details.date)).sentenceCase,
                style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ));
  }
}

// Calendar Data Source [class]
class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(this.source);
  List<Appointment> source;

  @override
  List<dynamic> get appointments => source;

  @override
  DateTime getStartTime(int index) {
    return (appointments[index] as Appointment).startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return (appointments[index] as Appointment).endTime;
  }

  @override
  Color getColor(int index) {
    return (appointments[index] as Appointment).color;
  }

  @override
  String getRecurrenceRule(int index) {
    return (appointments[index] as Appointment).recurrenceRule ?? '';
  }

  @override
  String getSubject(int index) {
    return (appointments[index] as Appointment).subject;
  }

  @override
  bool isAllDay(int index) {
    return (appointments[index] as Appointment).isAllDay;
  }

//  @override
//  String getStartTimeZone(int index) {

//    return appointments![index].fromZone;
//  }

//  @override
//  String getEndTimeZone(int index) {
//    return appointments![index].toZone;
//  }

//  @override
//  List<DateTime> getRecurrenceExceptionDates(int index) {
//    return appointments![index].exceptionDates;
//  }
}
