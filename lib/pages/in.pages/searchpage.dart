import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wesh/pages/profile.dart';
import 'package:wesh/utils/db.dart';
import 'package:wesh/widgets/contactcard.dart';
import 'package:wesh/widgets/contactview.dart';
import 'package:wesh/widgets/eventview.dart';
import 'package:wesh/widgets/modal.dart';
import 'package:wesh/widgets/searcheventcard.dart';
import 'package:wesh/widgets/usercard.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchtextcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          titleSpacing: 0,
          elevation: 0,
          leading: IconButton(
            splashRadius: 25,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
            ),
          ),
          title: Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 5, right: 10, top: 0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: CupertinoSearchTextField(
                controller: _searchtextcontroller,
                onChanged: ((value) {
                  // GET SEARCH RESULT
                  // TO DO
                  // Handle empty query
                }),
                onSubmitted: ((value) {
                  // GET SEARCH RESULT
                  // TO DO
                  // Handle empty query
                }),
                prefixIcon: Container(),
                placeholder: "Rechercher un évenement, un contact...",
                backgroundColor: Color(0xFFF0F0F0),
              ),
            ),
          ),
          // Tab bar
          bottom: const TabBar(
              indicatorColor: Colors.black,
              unselectedLabelColor: Colors.black,
              // labelPadding: EdgeInsets.only(top: 20),
              labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              labelColor: Colors.black,
              tabs: [
                Tab(
                  text: 'Evénements',
                ),
                Tab(
                  text: 'Comptes',
                ),
                Tab(
                  text: 'Contacts',
                ),
              ]),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: TabBarView(
            // SEARCH RESULT VIEW
            children: [
              // Events Section --> Search Results
              ListView.builder(
                itemCount: eventsList.length,
                itemBuilder: (context, index) => SearchEventCard(
                    event: eventsList[index],
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
                      //         child:
                      //             EventView(eventId: eventsList[index].eventId),
                      //       )),
                      // );
                    }),
              ),

              // Accounts Section --> Search Results
              // ListView.builder(
              //   itemCount: usersList.length,
              //   itemBuilder: ((context, index) => UserCard(
              //         status: '',
              //         id: '${usersList[index].id}',
              //         name: usersList[index].name,
              //         username: usersList[index].username,
              //         profilePicture: usersList[index].profilePicture,
              //         onTap: () {},
              //       )),
              // ),

              // Contacts Section --> Search Results
              ListView.builder(
                itemCount: contactsList.length,
                itemBuilder: ((context, index) => ContactCard(
                      name: contactsList[index].name,
                      birthday: contactsList[index].birthday,
                      profilePicture: contactsList[index].profilePicture,
                      onTap: () {
                        // Show Contact Viewer Modal
                        showModalBottomSheet(
                          enableDrag: true,
                          isScrollControlled: true,
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: ((context) => Modal(
                                child:
                                    ContactView(contact: contactsList[index]),
                              )),
                        );
                      },
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
