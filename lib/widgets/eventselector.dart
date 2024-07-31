import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:wesh/models/event.dart';
import 'package:wesh/services/firestore.methods.dart';
import 'package:wesh/widgets/buildWidgets.dart';
import 'package:wesh/widgets/searcheventcard.dart';
import '../utils/constants.dart';

class EventSelector extends StatefulWidget {
  const EventSelector({super.key});

  @override
  State<EventSelector> createState() => _EventSelectorState();
}

class _EventSelectorState extends State<EventSelector> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Column(
        children: [
          // Search Event Bar
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
            child: CupertinoSearchTextField(
              autofocus: true,
              prefixIcon: Container(),
              padding: EdgeInsets.symmetric(horizontal: 0.04.sw, vertical: 0.04.sw),
              style: TextStyle(color: Colors.black87, fontSize: 15.sp),
              placeholderStyle: TextStyle(color: Colors.black54, fontSize: 15.sp),
              placeholder: "Search for an event...",
              backgroundColor: const Color(0xFFF0F0F0),
              onChanged: (text) {
                setState(() {
                  // Create Query Variations
                  query = text;
                });
                debugPrint('Query : $query');
              },
            ),
          ),

          // Remove any attached event
          InkWell(
            onTap: () {
              // Pop the modal
              // Send back the Selected Event
              Navigator.pop(context, 'remove');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 0.07.sw,
                    backgroundColor: Colors.grey.shade400,
                    child: Icon(
                      FontAwesomeIcons.linkSlash,
                      size: 0.04.sw,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      'Remove the current attached event',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Events List
          StreamBuilder<List<Event>>(
            stream: FirestoreMethods.getAllEvents(),
            builder: (context, snapshot) {
              // QUERY SETTLED
              if (query.isNotEmpty) {
                // Handle Errors
                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 50),
                    child: Center(
                      child: BuildErrorWidget(onWhiteBackground: true),
                    ),
                  );
                }

                // Handle Data and perform search
                if (snapshot.hasData) {
                  List<Event> result = snapshot.data!
                      .where((event) => event.title.toString().toLowerCase().contains(query.toLowerCase()))
                      .toList();

                  // DATA FOUND
                  if (result.isNotEmpty) {
                    return Column(
                      children: result.map((event) {
                        return SearchEventCard(
                          event: event,
                          onTap: () {
                            // Pop Event Selector Modal
                            // Send back Selected EventId
                            Navigator.pop(context, event);
                          },
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            empty,
                            height: 100,
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
                  height: 150,
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
        ],
      ),
    );
  }
}
