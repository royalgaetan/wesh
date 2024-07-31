import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:wesh/models/event_duration_type.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/eventview.dart';
import 'package:wesh/widgets/modal.dart';
import 'package:wesh/widgets/searcheventcard.dart';
import 'package:wesh/widgets/usercard.dart';
import '../../models/user.dart' as usermodel;
import '../../models/event.dart';
import '../../services/firestore.methods.dart';
import '../../utils/functions.dart';

class SearchPage extends StatefulWidget {
  final int? initialPageIndex;
  const SearchPage({super.key, this.initialPageIndex});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchTextController = TextEditingController();
  String _searchQuery = '';
  List<int> monthsFilters = [];
  DateTime? dayFilter;
  bool showFilters = false;

  removeFilters() {
    setState(() {
      dayFilter = null;
      monthsFilters = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialPageIndex ?? 0,
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 46,
          scrolledUnderElevation: 0.0,
          backgroundColor: Colors.white,
          titleSpacing: 0,
          elevation: 0,
          leading: IconButton(
            splashRadius: 0.06.sw,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
            ),
          ),
          title: Container(
            margin: const EdgeInsets.only(right: 10, top: 0),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(15),
            ),
            child: CupertinoSearchTextField(
              controller: searchTextController,
              onChanged: ((value) {
                // GET SEARCH RESULT
                // TO DO
                // Handle empty query
                setState(() {
                  _searchQuery = removeDiacritics(value.trim());
                });
              }),
              onSubmitted: ((value) {
                // GET SEARCH RESULT
                // TO DO
                // Handle empty query
              }),
              padding: EdgeInsets.symmetric(horizontal: 0.03.sw, vertical: 0.03.sw),
              prefixIcon: Container(),
              style: TextStyle(color: Colors.black87, fontSize: 15.sp),
              placeholderStyle: TextStyle(color: Colors.black54, fontSize: 15.sp),
              placeholder: "Search for an event, a person...",
              backgroundColor: const Color(0xFFF0F0F0),
            ),
          ),
          actions: [
            // SHOW FILTER BUTTON FILTER
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Tooltip(
                  message: showFilters ? 'Remove filters' : 'Add Filters',
                  child: IconButton(
                    splashRadius: 0.06.sw,
                    onPressed: () {
                      //
                      setState(() {
                        if (showFilters) {
                          removeFilters();
                        }
                        showFilters = !showFilters;
                      });
                    },
                    icon: Icon(
                      Icons.calendar_month_sharp,
                      color: showFilters ? Colors.black : Colors.black45,
                    ),
                  ),
                ),

                // BUBBLE INDICATOR
                monthsFilters.isNotEmpty || dayFilter != null
                    ? Transform.translate(
                        offset: const Offset(-11, -11),
                        child: const CircleAvatar(radius: 4, backgroundColor: kSecondColor))
                    : Container(),
              ],
            ),
          ],

          // Tab bar
          bottom: TabBar(
              padding: const EdgeInsets.only(bottom: 10),
              indicatorColor: Colors.black87,
              labelPadding: const EdgeInsets.only(bottom: 0),
              unselectedLabelColor: Colors.black87,
              // labelPadding: EdgeInsets.only(top: 20),
              unselectedLabelStyle: TextStyle(fontSize: 14.sp),
              dividerColor: Colors.grey.shade300,
              labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              labelColor: Colors.black,
              splashFactory: NoSplash.splashFactory,
              tabs: const [
                Tab(
                  text: 'Events',
                ),
                Tab(
                  text: 'People',
                ),
              ]),
        ),
        body: Column(
          children: [
            // SEARCH FILTERS
            Visibility(
              visible: showFilters,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // REMOVE ALL FILTERS
                      Tooltip(
                        message: 'Remove all filters',
                        child: IconButton(
                          splashRadius: 0.06.sw,
                          onPressed: () {
                            removeFilters();
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      // DAY FILTERS
                      GestureDetector(
                        onTap: () async {
                          // Pick Date
                          DateTime? dateSelected = await pickDate(context: context, firstDate: DateTime(1700));

                          if (dateSelected != null) {
                            setState(() {
                              dayFilter = dateSelected;
                              monthsFilters = [];
                            });
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: Chip(
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            backgroundColor: dayFilter != null ? kSecondColor : Colors.grey.shade200,
                            label: Text(
                              dayFilter != null ? DateFormat('d MMM yyyy', 'en_En').format(dayFilter!) : 'Specific day',
                              style: TextStyle(color: dayFilter != null ? Colors.white : null, fontSize: 12.sp),
                            ),
                          ),
                        ),
                      ),

                      // Divider
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        height: 20,
                        width: 2,
                        color: Colors.grey.shade300,
                      ),

                      // MONTHS_FILTERS
                      ...List.generate(
                        12,
                        (monthIndex) => GestureDetector(
                          onTap: () {
                            setState(() {
                              dayFilter = null;
                              if (monthsFilters.contains(monthIndex)) {
                                monthsFilters.remove(monthIndex);
                              } else {
                                monthsFilters.add(monthIndex);
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: Chip(
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              backgroundColor: monthsFilters.contains(monthIndex) ? kSecondColor : Colors.grey.shade200,
                              label: Text(
                                monthsList[monthIndex],
                                style: TextStyle(
                                    color: monthsFilters.contains(monthIndex) ? Colors.white : null, fontSize: 12.sp),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // SEARCH RESULTS
            Expanded(
              child: TabBarView(
                // SEARCH RESULT VIEW
                children: [
                  // EVENTS RESULTS
                  SingleChildScrollView(
                    child: StreamBuilder<List<Event>>(
                      stream: FirestoreMethods.getAllEvents(),
                      builder: (context, snapshot) {
                        // QUERY SETTLED
                        if (_searchQuery.isNotEmpty) {
                          // Handle Errors
                          if (snapshot.hasError) {
                            return Container(
                              padding: const EdgeInsets.all(50),
                              height: 300,
                              child: const Text(
                                'An error occured!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black45,
                                ),
                              ),
                            );
                          }

                          // Handle Data and perform search
                          if (snapshot.hasData) {
                            List<Event> result = snapshot.data!
                                .where((event) =>
                                    removeDiacritics(event.title).toLowerCase().contains(_searchQuery.toLowerCase()))
                                .toList();

                            // ADD FILTER 1: dayFilter
                            if (showFilters && dayFilter != null && monthsFilters.isEmpty) {
                              result = result.where((event) {
                                // Get Current Event Durations
                                for (var eventDuration in event.eventDurations) {
                                  EventDurationType currentEventDuration = EventDurationType.fromJson(eventDuration);

                                  // ONLY FOR EVENT WITH RECURRENCE
                                  if (isEventWithRecurrence(event)) {
                                    if (currentEventDuration.date.month == dayFilter!.month &&
                                        currentEventDuration.date.day == dayFilter!.day) {
                                      return true;
                                    }
                                  } else {
                                    if (DateUtils.dateOnly(currentEventDuration.date) ==
                                        DateUtils.dateOnly(dayFilter!)) {
                                      return true;
                                    }
                                  }
                                }
                                return false;
                              }).toList();
                            }

                            // ADD FILTER 2: monthsFilters
                            if (showFilters && dayFilter == null && monthsFilters.isNotEmpty) {
                              result = result.where((event) {
                                // Get Current Event Durations
                                for (var eventDuration in event.eventDurations) {
                                  EventDurationType currentEventDuration = EventDurationType.fromJson(eventDuration);

                                  if (monthsFilters.contains(currentEventDuration.date.month - 1)) {
                                    return true;
                                  }
                                }
                                return false;
                              }).toList();
                            }

                            // DATA FOUND
                            if (result.isNotEmpty) {
                              return Column(
                                children: result.map((event) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                    child: SearchEventCard(
                                      event: event,
                                      onTap: () {
                                        // Show EventView Modal
                                        showModalBottomSheet(
                                          enableDrag: true,
                                          isScrollControlled: true,
                                          context: context,
                                          backgroundColor: Colors.transparent,
                                          builder: ((context) => Modal(
                                                minHeightSize: MediaQuery.of(context).size.height / 1.4,
                                                maxHeightSize: MediaQuery.of(context).size.height,
                                                child: EventView(eventId: event.eventId),
                                              )),
                                        );
                                      },
                                    ),
                                  );
                                }).toList(),
                              );
                            }

                            // NO DATA FOUND
                            else {
                              return Container(
                                padding: const EdgeInsets.all(50),
                                height: 300,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Lottie.asset(
                                      height: 100,
                                      empty,
                                      width: double.infinity,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      'No events found',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }

                          // Display Loading while waiting
                          return Container(
                            padding: const EdgeInsets.all(50),
                            height: 100,
                            child: const CupertinoActivityIndicator(),
                          );
                        }

                        // QUERY EMPTY
                        else {
                          return Container(
                            padding: const EdgeInsets.all(50),
                            height: 300,
                            child: Center(
                              child: Text(
                                'Enter the name of an event',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black45,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  // ACCOUNT RESULTS
                  SingleChildScrollView(
                    child: StreamBuilder<List<usermodel.User>>(
                      stream: FirestoreMethods.getAllUsers(),
                      builder: (context, snapshot) {
                        // QUERY SETTLED
                        if (_searchQuery.isNotEmpty) {
                          // Handle Errors
                          if (snapshot.hasError) {
                            return Container(
                              padding: const EdgeInsets.all(50),
                              height: 300,
                              child: const Text(
                                'An error occured!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black45,
                                ),
                              ),
                            );
                          }

                          // Handle Data and perform search
                          if (snapshot.hasData) {
                            List<usermodel.User?> result = snapshot.data!
                                .where((user) =>
                                    removeDiacritics(user.name).toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                    removeDiacritics(user.username).toLowerCase().contains(_searchQuery.toLowerCase()))
                                .toList();

                            // ADD FILTER 1: dayFilter
                            if (showFilters && dayFilter != null && monthsFilters.isEmpty) {
                              result = result.where((user) {
                                if (user != null) {
                                  // Get Current User Birthday
                                  if (user.birthday.month == dayFilter!.month && user.birthday.day == dayFilter!.day) {
                                    return true;
                                  }
                                  return false;
                                }

                                return false;
                              }).toList();
                            }

                            // ADD FILTER 2: monthsFilters
                            if (showFilters && dayFilter == null && monthsFilters.isNotEmpty) {
                              result = result.where((user) {
                                if (user != null) {
                                  //
                                  if (monthsFilters.contains(user.birthday.month - 1)) {
                                    return true;
                                  }
                                  return false;
                                }

                                return false;
                              }).toList();
                            }

                            // DATA FOUND
                            if (result.isNotEmpty) {
                              return Column(
                                children: result.map((user) {
                                  if (user != null) {
                                    return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                        child: UserCard(
                                          user: user,
                                          status: 'followUnfollow',
                                          onTap: () {},
                                        ));
                                  }
                                  return Container();
                                }).toList(),
                              );
                            }

                            // NO DATA FOUND
                            else {
                              return Container(
                                padding: const EdgeInsets.all(50),
                                height: 300,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Lottie.asset(
                                      height: 100,
                                      empty,
                                      width: double.infinity,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      'No accounts found!',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }

                          // Display Loading while waiting
                          return Container(
                            padding: const EdgeInsets.all(50),
                            height: 100,
                            child: const CupertinoActivityIndicator(),
                          );
                        }

                        // QUERY EMPTY
                        else {
                          return Container(
                            padding: const EdgeInsets.all(50),
                            height: 300,
                            child: Center(
                              child: Text(
                                'Enter a person\'s name',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black45,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
