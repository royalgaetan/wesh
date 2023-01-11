import 'dart:math';
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:validators/validators.dart';
import 'package:wesh/models/event.dart';
import 'package:wesh/models/event_duration_type.dart';
import 'package:wesh/services/firestorage.methods.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/utils/functions.dart';
import 'package:wesh/widgets/buildWidgets.dart';
import 'package:wesh/widgets/imagepickermodal.dart';
import 'package:wesh/widgets/modal.dart';
import 'package:wesh/widgets/textformfield.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import '../../services/firestore.methods.dart';
import '../../widgets/button.dart';
import '../../models/user.dart' as usermodel;

class CreateOrUpdateEventPage extends StatefulWidget {
  Event? event;
  final usermodel.User? userPoster;

  CreateOrUpdateEventPage({Key? key, this.event, this.userPoster}) : super(key: key);

  @override
  State<CreateOrUpdateEventPage> createState() => _CreateOrUpdateEventPageState();
}

class _CreateOrUpdateEventPageState extends State<CreateOrUpdateEventPage> {
  TextEditingController emptyController = TextEditingController();
  TextEditingController nameEventController = TextEditingController();
  TextEditingController captionEventController = TextEditingController();
  TextEditingController linkEventController = TextEditingController();
  TextEditingController locationEventController = TextEditingController();

  late PageController eventDurationTypePageController;
  String eventType = '';
  int eventColorIndexSelected = Random().nextInt(eventAvailableColorsList.length);
  String coverEventController = '';

  bool isOneDayEvent = true;
  List<EventDurationType> eventDurations = [
    EventDurationType(
      date: DateTime.now(),
      isAllTheDay: true,
      startTime: const TimeOfDay(hour: 00, minute: 00),
      endTime: const TimeOfDay(hour: 23, minute: 59),
    ),
    EventDurationType(
      date: DateTime.now().add(const Duration(days: 1)),
      isAllTheDay: true,
      startTime: const TimeOfDay(hour: 00, minute: 00),
      endTime: const TimeOfDay(hour: 23, minute: 59),
    )
  ];

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    //

    super.initState();

    if (widget.event != null) {
      eventDurationTypePageController =
          PageController(initialPage: widget.event!.eventDurationType == '1DayEvent' ? 0 : 1);
      setState(() {
        if (widget.event!.eventDurationType == '1DayEvent') {
          isOneDayEvent = true;
        } else {
          isOneDayEvent = false;
        }
      });
    } else {
      eventDurationTypePageController = PageController(initialPage: 0);
      setState(() {
        isOneDayEvent = true;
      });
    }

    // Init data on "UPDATE MODE"
    if (widget.event != null) {
      nameEventController.text = widget.event!.title;
      eventType = widget.event!.type;
      captionEventController.text = widget.event!.caption;
      linkEventController.text = widget.event!.link;
      locationEventController.text = widget.event!.location;
      coverEventController = widget.event!.trailing;
      eventColorIndexSelected = widget.event!.color;
      //
      eventDurations = widget.event!.eventDurations.map((eventDuration) {
        return EventDurationType.fromJson((eventDuration as Map<String, dynamic>));
      }).toList();

      // Check EventDurationType : if == [MultiDaysEvent] && eventDurations.length == 1 then Add One Last Event Duration
      if (eventDurations.length == 1) {
        eventDurations.add(
          EventDurationType(
            date: eventDurations[0].date.add(const Duration(days: 1)),
            isAllTheDay: true,
            startTime: const TimeOfDay(hour: 00, minute: 00),
            endTime: const TimeOfDay(hour: 23, minute: 59),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    //
    super.dispose();
    eventDurationTypePageController.dispose();

    emptyController.dispose();
    nameEventController.dispose();
    captionEventController.dispose();
    linkEventController.dispose();
    locationEventController.dispose();
  }

  resetEventDurationsList() {
    setState(() {
      eventDurations = [
        EventDurationType(
          date: DateTime.now(),
          isAllTheDay: true,
          startTime: const TimeOfDay(hour: 00, minute: 00),
          endTime: const TimeOfDay(hour: 23, minute: 59),
        ),
        EventDurationType(
          date: DateTime.now().add(const Duration(days: 1)),
          isAllTheDay: true,
          startTime: const TimeOfDay(hour: 00, minute: 00),
          endTime: const TimeOfDay(hour: 23, minute: 59),
        )
      ];
    });
  }

  createOrUpdateEvent() async {
    bool result = false;

    // Check event Durations
    if (!isMyBirthday()) {
      if (isOneDayEvent) {
        DateTime tempDateTime = DateTime(
          eventDurations[0].date.year,
          eventDurations[0].date.month,
          eventDurations[0].date.day,
          eventDurations[0].startTime.hour,
          eventDurations[0].startTime.minute,
        );

        if (widget.event == null && (tempDateTime).isBefore(DateTime.now().add(const Duration(minutes: 30))) ||
            tempDateTime.isAtSameMomentAs(DateTime.now().add(const Duration(minutes: 30)))) {
          showSnackbar(context,
              'Votre date de début doit avoir au moins plus de 30 minutes d\'avance sur l\'heure actuelle', null);

          return;
        }

        if (!isEndTimeSuperiorThanStartTime(eventDurations[0].startTime, eventDurations[0].endTime)) {
          showSnackbar(context, 'Votre heure de fin doit être en avance sur l\'heure de debut', null);

          return;
        }
      } else {
        for (var i = 0; i < eventDurations.length; i++) {
          if (i == 0) {
            DateTime temp1stDateTime = DateTime(
              eventDurations[0].date.year,
              eventDurations[0].date.month,
              eventDurations[0].date.day,
              eventDurations[0].startTime.hour,
              eventDurations[0].startTime.minute,
            );

            if (widget.event == null && temp1stDateTime.isBefore(DateTime.now().add(const Duration(minutes: 30))) ||
                temp1stDateTime.isAtSameMomentAs(DateTime.now().add(const Duration(minutes: 30)))) {
              showSnackbar(context,
                  'Votre date de début doit avoir au moins plus de 30 minutes d\'avance sur l\'heure actuelle', null);

              return;
            }
          }
          if (i < eventDurations.length - 1) {
            // Check Previous and Next Date
            if (eventDurations[i].date.isAfter(eventDurations[i + 1].date)) {
              showSnackbar(
                  context,
                  'Votre ${i + 1 == 1 ? '1er' : '${i + 1}e'} jour est en avance par rapport au ${eventDurations.length == (i + 2) ? 'dernier' : '${i + 2}e'} jour',
                  null);

              return;
            }

            if (DateUtils.dateOnly(eventDurations[i].date)
                .isAtSameMomentAs(DateUtils.dateOnly(eventDurations[i + 1].date))) {
              showSnackbar(
                  context,
                  'Votre ${i + 1 == 1 ? '1er' : '${i + 1}e'} jour doit être différent de votre ${eventDurations.length == (i + 2) ? 'dernier' : '${i + 2}e'} jour',
                  null);

              return;
            }
          }

          // Check Current Date StartTime && EndTime
          if (!isEndTimeSuperiorThanStartTime(eventDurations[i].startTime, eventDurations[i].endTime)) {
            showSnackbar(
                context,
                'Votre heure de fin du ${eventDurations.length == (i + 1) ? 'dernier' : i + 1 == 1 ? '1er' : '${i + 1}e'} jour doit être en avance sur l\'heure de debut',
                null);

            return;
          }
        }
      }
    }

    showFullPageLoader(context: context);

    bool isAllowToContinue = true;
    String downloadUrl = coverEventController;
    // Upload event Cover to Firestorage and getDownloadURL
    if (!coverEventController.contains('https://')) {
      List resultFromEventCover = await FireStorageMethods.uploadimageToEventCover(context, coverEventController);
      isAllowToContinue = resultFromEventCover[0];
      downloadUrl = resultFromEventCover[1];
    }

    if (isAllowToContinue) {
      // CREATE A NEW ONE
      if (widget.event == null) {
        // Modeling an event
        Map<String, dynamic> event = Event(
          eventId: '',
          uid: FirebaseAuth.instance.currentUser!.uid,
          title: nameEventController.text,
          caption: captionEventController.text,
          type: eventType,
          link: linkEventController.text,
          location: locationEventController.text,
          trailing: downloadUrl,
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now(),
          eventDurationType: isOneDayEvent ? '1DayEvent' : 'MultiDaysEvent',
          eventDurations: isOneDayEvent
              ? [eventDurations[0].toJson()]
              : eventDurations.map((eventDuration) => eventDuration.toJson()).toList(),
          color: eventColorIndexSelected,
          status: '',
        ).toJson();

        //  Update Firestore Event Table
        // ignore: use_build_context_synchronously
        result = await FirestoreMethods.createEvent(context, FirebaseAuth.instance.currentUser!.uid, event);
        debugPrint('Event created (+notification) !');
      }

      // UPDATE AN EXISTING ONE
      if (widget.event != null) {
        // Check whether it's user birthday or not
        if (isUserBirthday(widget.event, widget.userPoster)) {
          isOneDayEvent = true;
        }

        // Modeling an event

        Map<String, dynamic> eventToUpdate = Event(
          eventId: widget.event!.eventId,
          uid: FirebaseAuth.instance.currentUser!.uid,
          title: nameEventController.text,
          caption: captionEventController.text,
          type: eventType,
          link: linkEventController.text,
          location: locationEventController.text,
          trailing: downloadUrl,
          createdAt: widget.event!.createdAt,
          modifiedAt: DateTime.now(),
          eventDurationType: isOneDayEvent ? '1DayEvent' : 'MultiDaysEvent',
          eventDurations: isOneDayEvent
              ? [eventDurations[0].toJson()]
              : eventDurations.map((eventDuration) => eventDuration.toJson()).toList(),
          color: eventColorIndexSelected,
          status: '',
        ).toJson();

        // ignore: use_build_context_synchronously
        result = await FirestoreMethods.updateEvent(context, widget.event!.eventId, eventToUpdate);
        debugPrint('Event updated (+Related reminders)');
      }

      // ignore: use_build_context_synchronously
      Navigator.pop(
        context,
      );
      // Pop the Screen once event created/updated
      if (result) {
        // ignore: use_build_context_synchronously
        Navigator.pop(
          context,
        );

        // ignore: use_build_context_synchronously
        showSnackbar(
            context,
            widget.event == null ? 'Votre évènement à bien été crée !' : 'Votre évènement à bien été modifié !',
            kSuccessColor);
      }
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pop(
        context,
      );
    }
  }

  bool isMyBirthday() {
    if (widget.event != null &&
        widget.userPoster != null &&
        widget.userPoster!.id == FirebaseAuth.instance.currentUser!.uid &&
        widget.event!.type == 'birthday' &&
        widget.userPoster!.birthday == (widget.event?.eventDurations[0]['date'] as Timestamp).toDate().toLocal()) {
      return true;
    }
    return false;
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
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: MorphingAppBar(
            heroTag: 'createOrUpdateEventPageAppBar',
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
              widget.event != null && widget.event!.uid == FirebaseAuth.instance.currentUser!.uid
                  ? IconButton(
                      splashRadius: 0.06.sw,
                      onPressed: () async {
                        // Check if it's [My] birthday
                        if (isMyBirthday()) {
                          // ignore: use_build_context_synchronously
                          showSnackbar(context, 'Vous ne pouvez pas supprimer votre anniversaire !', null);
                          return;
                        }

                        // DELETE EVENT

                        // Show Delete Decision Modal
                        List deleteDecision = await showModalDecision(
                          context: context,
                          header: 'Supprimer',
                          content: 'Voulez-vous supprimer définitivement cet évènement ?',
                          firstButton: 'Annuler',
                          secondButton: 'Supprimer',
                        );

                        if (deleteDecision[0] == true) {
                          // Delete event...
                          // ignore: use_build_context_synchronously
                          bool result = await FirestoreMethods.deleteEvent(
                              context, widget.event!.eventId, FirebaseAuth.instance.currentUser!.uid);
                          if (result) {
                            debugPrint('Event deleted !');

                            // ignore: use_build_context_synchronously
                            Navigator.pop(
                              context,
                            );

                            // ignore: use_build_context_synchronously
                            showSnackbar(context, 'Votre évènement à bien été supprimé !', kSecondColor);
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
              widget.event == null ? 'Créer un évènement' : 'Modifier l\'évènement',
              style: const TextStyle(color: Colors.black),
            ),
            centerTitle: false,
          ),
          body: ListView(
            padding: const EdgeInsets.only(
              top: 20,
              bottom: 5,
              left: 10,
              right: 10,
            ),
            children: [
              // FIELDS

              // Add Event Name
              buildTextFormField(
                controller: nameEventController,
                hintText: 'Ajouter le nom de l\'évènement',
                icon: Icon(FontAwesomeIcons.splotch, size: 19.sp),
                validateFn: (eventName) {
                  return null;
                },
                onChanged: (value) async {
                  return await null;
                },
              ),

              // Add Event Caption
              buildTextFormField(
                controller: captionEventController,
                hintText: 'Ajouter la description de l\'évènement',
                icon: Icon(Icons.messenger_outline_sharp, size: 22.sp),
                maxLines: 4,
                maxLength: 150,
                validateFn: (eventCaption) {
                  return null;
                },
                onChanged: (value) async {
                  return await null;
                },
              ),

              // Add Event Type
              InkWell(
                onTap: () async {
                  // Check if it's [My] birthday
                  if (isMyBirthday()) {
                    // ignore: use_build_context_synchronously
                    showSnackbar(
                        context,
                        'Vous ne pouvez pas modifier le type d\'évènement car il s\'agit de votre anniversaire !',
                        null);
                    return;
                  }

                  // Pick event type from a Dialog
                  String? selectedEventType = await showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                              child: Text(
                                'Choisissez un type d\'évènement',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 1.4,
                              child: ListView.builder(
                                itemCount: eventAvailableTypeList.length,
                                itemBuilder: (context, index) => ListTile(
                                  leading: CircleAvatar(
                                      backgroundImage: AssetImage(
                                          'assets/images/eventtype.icons/${eventAvailableTypeList[index].key}.png')),
                                  horizontalTitleGap: 10,
                                  title: Text(
                                    eventAvailableTypeList[index].name,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onTap: () {
                                    // Pop the modal picker and get back selected event type
                                    Navigator.pop(
                                      context,
                                      eventAvailableTypeList[index].key,
                                    );
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );

                  if (selectedEventType != null) {
                    setState(() {
                      eventType = selectedEventType;
                    });
                  }
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 6, bottom: 0.02.sw, left: 9),
                  child: Row(
                    children: [
                      Icon(Icons.favorite_outline_rounded, size: 23.sp, color: Colors.grey.shade600),
                      SizedBox(width: 0.057.sw),
                      Expanded(
                        child: eventType.isEmpty
                            ? Text(
                                'Type d\'évènement',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                              )
                            : Text(
                                getEventTitle(eventType),
                                style: TextStyle(color: Colors.black, fontSize: 14.sp),
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              const buildDivider(),

              // Add Event Link
              buildTextFormField(
                controller: linkEventController,
                hintText: 'Ajouter un lien à l\'évènement',
                icon: Icon(FontAwesomeIcons.link, size: 19.sp),
                validateFn: (eventLink) {
                  return null;
                },
                onChanged: (value) async {
                  return await null;
                },
              ),

              // Add Event Location
              buildTextFormField(
                controller: locationEventController,
                hintText: 'Ajouter le lieu de l\'évènement',
                icon: Icon(FontAwesomeIcons.locationDot, size: 19.sp),
                validateFn: (eventLocation) {
                  return null;
                },
                onChanged: (value) async {
                  return await null;
                },
              ),

              // Add Event Trailing
              InkWell(
                onTap: () async {
                  // Show Contact Viewer Modal
                  dynamic file = await showModalBottomSheet(
                    enableDrag: true,
                    isScrollControlled: true,
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: ((context) => const Modal(
                          minHeightSize: 200,
                          maxHeightSize: 200,
                          child: ImagePickerModal(),
                        )),
                  );

                  if (file != null && file != 'remove') {
                    final Directory directory = await getApplicationDocumentsDirectory();
                    final filename = 'eventcover_${getUniqueId()}';
                    final path = '${directory.path}/$filename.jpg';

                    file.saveTo(path).whenComplete(() => dev.log('File was saved correctly at $path'));

                    setState(() {
                      coverEventController = path;
                    });
                  } else if (file == 'remove') {
                    setState(() {
                      coverEventController = '';
                    });

                    debugPrint('No file selected !');
                  }
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 6, bottom: 0.02.sw, left: 11),
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.image, size: 18.sp, color: Colors.grey.shade600),
                      SizedBox(width: 0.057.sw),
                      Expanded(
                        child: Text(
                          'Ajouter une couverture',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                        ),
                      ),

                      // Case 1
                      coverEventController.contains('https://')
                          ? buildCachedNetworkImage(
                              url: widget.event!.trailing,
                              radius: 0.07.sw,
                              backgroundColor: kGreyColor,
                              paddingOfProgressIndicator: 3,
                            )
                          : Container(),

                      // Case 2
                      coverEventController == '' &&
                              !coverEventController.contains('https://') &&
                              !coverEventController.contains('/data/user/')
                          ? CircleAvatar(
                              radius: 0.07.sw,
                              backgroundColor: kGreyColor,
                              backgroundImage: AssetImage(eventType.isNotEmpty
                                  ? 'assets/images/eventtype.icons/${eventAvailableTypeList.singleWhere((element) => element.key == eventType).key}.png'
                                  : 'assets/images/eventtype.icons/other.png'),
                            )
                          : Container(),

                      // Case 3
                      !coverEventController.contains('https://') && coverEventController.contains('/data/user/')
                          ? CircleAvatar(
                              radius: 0.07.sw,
                              backgroundColor: kGreyColor,
                              backgroundImage: FileImage(
                                File(coverEventController),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),

              const buildDivider(),

              // Add Event Date
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: buildTextFormField(
                      controller: emptyController,
                      isReadOnly: true,
                      hintText: 'Date et heure',
                      icon: Icon(Icons.edit_calendar_outlined, size: 22.sp),
                      validateFn: (_) {
                        return;
                      },
                      onChanged: (value) async {
                        return;
                      },
                    ),
                  ),
                  // Navigate between EventDurationType
                  Visibility(
                    visible: isMyBirthday() ? false : true,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Row(
                        children: [
                          // Previous Type
                          IconButton(
                            splashRadius: 0.04.sw,
                            onPressed: () async {
                              // Change Event Duration Type
                              setState(() {
                                isOneDayEvent = true;
                              });
                              eventDurationTypePageController.previousPage(
                                  duration: const Duration(milliseconds: 100), curve: Curves.fastOutSlowIn);
                            },
                            icon: Icon(Icons.navigate_before_rounded, size: 25.sp),
                          ),

                          // Next Type
                          IconButton(
                            splashRadius: 0.04.sw,
                            onPressed: () async {
                              setState(() {
                                isOneDayEvent = false;
                              });
                              // Change Event Duration Type
                              eventDurationTypePageController.nextPage(
                                  duration: const Duration(milliseconds: 100), curve: Curves.fastOutSlowIn);
                            },
                            icon: Icon(Icons.navigate_next_rounded, size: 25.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Event Duration Type

              isMyBirthday()
                  ? Center(
                      child: FittedBox(
                        child: Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black87.withOpacity(0.3),
                          ),
                          child: const Text('Vous ne pouvez pas modifier la date de votre anniversaire !',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    )
                  : ExpandablePageView(
                      onPageChanged: (currentPageIndex) {
                        if (currentPageIndex == 0) {
                          setState(() {
                            isOneDayEvent = true;
                          });
                        } else if (currentPageIndex == 1) {
                          setState(() {
                            isOneDayEvent = false;
                          });
                        }
                        dev.log('isOneDayEvent: $isOneDayEvent');
                      },
                      controller: eventDurationTypePageController,
                      children: [
                        // 1day Event
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          padding: const EdgeInsets.all(20),
                          width: double.infinity,
                          decoration:
                              BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.blue.shade600),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Wrap(
                                        children: [
                                          Text(
                                            'Evenement d\'un jour',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(50),
                                      onTap: () {
                                        resetEventDurationsList();
                                      },
                                      child: Icon(
                                        Icons.restart_alt_rounded,
                                        size: 22.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              buildEventDurationCard(
                                setDate: () async {
                                  EventDurationType firstEventDuration = eventDurations[0];
                                  // Pick Date
                                  DateTime? newDate = await pickDate(
                                      context: context,
                                      firstDate: widget.event == null ? DateTime.now() : DateTime(0),
                                      initialDate: widget.event == null ? DateTime.now() : firstEventDuration.date);

                                  if (newDate != null) {
                                    setState(() {
                                      EventDurationType eventDurationGet = eventDurations[0].copy(newDate: newDate);
                                      eventDurations[0] = eventDurationGet;

                                      dev.log("Date selected:  ${eventDurations[0].date}");
                                    });
                                  }
                                },
                                setStartTime: () {
                                  // Pick start time
                                  Navigator.of(context).push(
                                    showPicker(
                                      context: context,
                                      value: eventDurations[0].startTime,
                                      is24HrFormat: true,
                                      iosStylePicker: true,
                                      unselectedColor: Colors.black38,
                                      accentColor: Colors.black87,
                                      cancelText: 'Annuler',
                                      hourLabel: 'heures',
                                      minuteLabel: 'minutes',
                                      onChange: (timePicked) {
                                        setState(() {
                                          EventDurationType eventDurationGet =
                                              eventDurations[0].copy(newStartTime: timePicked);
                                          eventDurations[0] = eventDurationGet;

                                          dev.log("Start Time selected:  ${eventDurations[0].startTime}");
                                        });
                                      },
                                    ),
                                  );
                                },
                                setEndTime: () {
                                  // Pick end time
                                  Navigator.of(context).push(
                                    showPicker(
                                      context: context,
                                      value: eventDurations[0].endTime,
                                      is24HrFormat: true,
                                      iosStylePicker: true,
                                      unselectedColor: Colors.black38,
                                      accentColor: Colors.black87,
                                      cancelText: 'Annuler',
                                      hourLabel: 'heures',
                                      minuteLabel: 'minutes',
                                      onChange: (timePicked) {
                                        if (isEndTimeSuperiorThanStartTime(eventDurations[0].startTime, timePicked)) {
                                          setState(() {
                                            EventDurationType eventDurationGet =
                                                eventDurations[0].copy(newEndTime: timePicked);
                                            eventDurations[0] = eventDurationGet;
                                          });
                                        } else {
                                          showSnackbar(context,
                                              'Votre heure de fin doit être en avance sur l\'heure de debut', null);
                                        }
                                        dev.log("End Time selected:  ${eventDurations[0].endTime}");
                                      },
                                    ),
                                  );
                                },
                                date: eventDurations[0].date,
                                startTime: eventDurations[0].startTime,
                                endTime: eventDurations[0].endTime,
                                isAllTheDay: eventDurations[0].isAllTheDay,
                                setIsAllTheDay: (newValue) {
                                  if (newValue) {
                                    setState(() {
                                      EventDurationType eventDurationGet = eventDurations[0].copy(
                                          newStartTime: const TimeOfDay(hour: 00, minute: 00),
                                          newEndTime: const TimeOfDay(hour: 23, minute: 59),
                                          newIsAllTheDay: newValue);

                                      eventDurations[0] = eventDurationGet;
                                    });
                                  } else {
                                    setState(() {
                                      EventDurationType eventDurationGet =
                                          eventDurations[0].copy(newIsAllTheDay: newValue);

                                      eventDurations[0] = eventDurationGet;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        // MultiDays Event
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          padding: const EdgeInsets.all(20),
                          width: double.infinity,
                          decoration:
                              BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.green.shade600),
                          child: Column(
                            children: [
                              // Header
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Wrap(
                                        children: [
                                          Text(
                                            'Evenement de plusieurs jours',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(50),
                                      onTap: () {
                                        resetEventDurationsList();
                                      },
                                      child: Icon(
                                        Icons.restart_alt_rounded,
                                        size: 22.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Event Durations List

                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: eventDurations.length,
                                itemBuilder: ((context, index) {
                                  return Column(
                                    children: [
                                      const SizedBox(height: 20),

                                      // Header
                                      buildDividerWithLabel(
                                        fontColor: Colors.white70,
                                        label:
                                            '${eventDurations.length == (index + 1) ? 'Dernier' : index + 1 == 1 ? '1er' : '${index + 1}e'} jour',
                                      ),

                                      // Body
                                      buildEventDurationCard(
                                        setDate: () async {
                                          EventDurationType firstEventDuration = eventDurations[0];
                                          // Pick Date
                                          DateTime? newDate = await pickDate(
                                              context: context,
                                              firstDate: widget.event == null ? DateTime.now() : DateTime(0),
                                              initialDate:
                                                  widget.event == null ? DateTime.now() : firstEventDuration.date);

                                          if (newDate != null) {
                                            setState(() {
                                              EventDurationType eventDurationGet =
                                                  eventDurations[index].copy(newDate: newDate);
                                              eventDurations[index] = eventDurationGet;

                                              dev.log("Date selected:  ${eventDurations[index].date}");
                                            });
                                          }
                                        },
                                        setStartTime: () {
                                          // Pick start time
                                          Navigator.of(context).push(
                                            showPicker(
                                              context: context,
                                              value: eventDurations[index].startTime,
                                              is24HrFormat: true,
                                              iosStylePicker: true,
                                              unselectedColor: Colors.black38,
                                              accentColor: Colors.black87,
                                              cancelText: 'Annuler',
                                              hourLabel: 'heures',
                                              minuteLabel: 'minutes',
                                              onChange: (timePicked) {
                                                setState(() {
                                                  EventDurationType eventDurationGet =
                                                      eventDurations[index].copy(newStartTime: timePicked);
                                                  eventDurations[index] = eventDurationGet;

                                                  dev.log("Start Time selected:  ${eventDurations[index].startTime}");
                                                });
                                              },
                                            ),
                                          );
                                        },
                                        setEndTime: () {
                                          // Pick end time
                                          Navigator.of(context).push(
                                            showPicker(
                                              context: context,
                                              value: eventDurations[index].endTime,
                                              is24HrFormat: true,
                                              iosStylePicker: true,
                                              unselectedColor: Colors.black38,
                                              accentColor: Colors.black87,
                                              cancelText: 'Annuler',
                                              hourLabel: 'heures',
                                              minuteLabel: 'minutes',
                                              onChange: (timePicked) {
                                                if (isEndTimeSuperiorThanStartTime(
                                                    eventDurations[index].startTime, timePicked)) {
                                                  setState(() {
                                                    EventDurationType eventDurationGet =
                                                        eventDurations[index].copy(newEndTime: timePicked);
                                                    eventDurations[index] = eventDurationGet;
                                                  });
                                                } else {
                                                  showSnackbar(
                                                      context,
                                                      'Votre heure de fin doit être en avance sur l\'heure de debut',
                                                      null);
                                                }
                                                dev.log("End Time selected:  ${eventDurations[index].endTime}");
                                              },
                                            ),
                                          );
                                        },
                                        date: eventDurations[index].date,
                                        startTime: eventDurations[index].startTime,
                                        endTime: eventDurations[index].endTime,
                                        isAllTheDay: eventDurations[index].isAllTheDay,
                                        setIsAllTheDay: (newValue) {
                                          if (newValue) {
                                            setState(() {
                                              EventDurationType eventDurationGet = eventDurations[index].copy(
                                                  newStartTime: const TimeOfDay(hour: 00, minute: 00),
                                                  newEndTime: const TimeOfDay(hour: 23, minute: 59),
                                                  newIsAllTheDay: newValue);

                                              eventDurations[index] = eventDurationGet;
                                            });
                                          } else {
                                            setState(() {
                                              EventDurationType eventDurationGet =
                                                  eventDurations[index].copy(newIsAllTheDay: newValue);

                                              eventDurations[index] = eventDurationGet;
                                            });
                                          }
                                        },
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      )
                                    ],
                                  );
                                }),
                              ),

                              // Add Event Duration : +1 day
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Button(
                                  height: 0.12.sw,
                                  width: double.infinity,
                                  text: 'Ajouter une journée',
                                  color: Colors.white,
                                  fontColor: Colors.green.shade600,
                                  prefixIcon: Icons.add,
                                  prefixIconColor: Colors.green.shade600,
                                  onTap: () {
                                    //
                                    setState(() {
                                      eventDurations.insert(
                                        eventDurations.length - 1,
                                        EventDurationType(
                                          date: eventDurations[eventDurations.length - 2]
                                              .date
                                              .add(const Duration(days: 1)),
                                          startTime: const TimeOfDay(hour: 0, minute: 00),
                                          endTime: const TimeOfDay(hour: 23, minute: 59),
                                          isAllTheDay: true,
                                        ),
                                      );
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
              const buildDivider(),

              // Add Event Color
              buildTextFormField(
                controller: emptyController,
                isReadOnly: true,
                hintText: 'Ajouter une couleur',
                icon: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(FontAwesomeIcons.palette, size: 19.sp),
                ),
                validateFn: (_) {
                  return;
                },
                onChanged: (value) async {
                  return;
                },
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 5, 80),
                child: Row(
                  children: List<Widget>.generate(
                    eventAvailableColorsList.length,
                    (index) => Padding(
                      padding: const EdgeInsets.all(2),
                      child: GestureDetector(
                        onTap: () {
                          // Change Selected Event Color
                          setState(() {
                            eventColorIndexSelected = index;
                          });
                        },
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: eventAvailableColorsList[index],
                          child: eventColorIndexSelected == index
                              ? const Icon(
                                  Icons.done,
                                  color: Colors.white,
                                  size: 15,
                                )
                              : Container(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton:
              // [ACTION BUTTON] Add Event Button
              FloatingActionButton.extended(
            label: Text(
              widget.event == null ? 'Créer' : 'Modifier',
            ),
            foregroundColor: Colors.white,
            backgroundColor: kSecondColor,
            icon: Transform.translate(
              offset: const Offset(1, -1),
              child: widget.event == null
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

              if (nameEventController.text.isNotEmpty && nameEventController.text.length < 45) {
                if (captionEventController.text.length <= 150) {
                  if (eventType.isNotEmpty) {
                    if (linkEventController.text.isEmpty || isURL(linkEventController.text)) {
                      // if (isEndTimeSuperiorThanStartTime(startTime, endTime)) {
                      // CREATE OR UPDATE EVENT
                      debugPrint('creating/updating event...');
                      createOrUpdateEvent();
                      // } else {
                      //   // Time start-end error handler
                      //   showSnackbar(context, 'Votre heure de fin doit être en avance sur l\'heure de début', null);
                      // }
                    } else if (linkEventController.text.isNotEmpty && !isURL(linkEventController.text)) {
                      // Event link error handler
                      showSnackbar(context, 'Veuillez entrer un lien correct', null);
                    }
                  } else {
                    // Event type error handler
                    showSnackbar(context, 'Veuillez entrer un type d\'évènement', null);
                  }
                } else {
                  // Description error handler
                  showSnackbar(context, 'Veuillez entrer une description valide (inferieure à 150 caractères)', null);
                }
              } else {
                // Name error handler
                showSnackbar(context, 'Veuillez entrer un nom valide (inferieur à 45 caractères)', null);
              }
            },
          )),
    );
  }
}
