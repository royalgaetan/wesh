import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/models/contact.dart';
import 'package:wesh/pages/in.pages/create_or_update_contactpage.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/contactcard.dart';
import 'package:wesh/widgets/contactview.dart';
import 'package:wesh/widgets/modal.dart';
import 'package:wesh/widgets/usercard.dart';

import '../../utils/db.dart';

class PeoplePage extends StatefulWidget {
  int tabIndex;

  PeoplePage({this.tabIndex = 0});

  @override
  State<PeoplePage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<PeoplePage> {
  late var status = 'isfollowing';
  late var status2 = 'follower';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.tabIndex,
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: MorphingAppBar(
          heroTag: 'peoplePageAppBar',
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
          title: const Text(
            'Personnes',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            IconButton(
              splashRadius: 22,
              onPressed: () {
                //
                Navigator.push(
                  context,
                  SwipeablePageRoute(
                    builder: (_) => (CreateOrUpdateContactPage()),
                  ),
                );
              },
              icon: const Icon(
                Icons.person_add,
                color: Colors.black,
              ),
            )
          ],

          // Tab bar
          bottom: const TabBar(
              indicatorColor: Colors.black,
              unselectedLabelColor: Colors.black,
              // labelPadding: EdgeInsets.only(top: 20),
              labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              labelColor: Colors.black,
              tabs: [
                Tab(
                  text: 'Contacts',
                ),
                Tab(
                  text: 'Abonnés',
                ),
                Tab(
                  text: 'Abonnements',
                ),
              ]),
        ),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: TabBarView(
              children: [
                // Contact Section
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
                                  child: ContactView(
                                    contact: contactsList[index],
                                  ),
                                )),
                          );
                        },
                      )),
                ),

                // Followers Section
                // ListView.builder(
                //   itemCount: usersList.length,
                //   itemBuilder: ((context, index) => UserCard(
                //         status: status2,
                //         name: usersList[index].name,
                //         id: '${usersList[index].id}',
                //         username: usersList[index].username,
                //         profilePicture: usersList[index].profilePicture,
                //         onTap: () {
                //           // Remove Follower
                //           setState(() {
                //             status2 = '';
                //           });
                //         },
                //       )),
                // ),

                // Following Section
                // ListView.builder(
                //   itemCount: 2,
                //   itemBuilder: ((context, index) => UserCard(
                //         status: status,
                //         id: '${usersList[index].id}',
                //         name: usersList[index].name,
                //         username: usersList[index].username,
                //         profilePicture: usersList[index].profilePicture,
                //         onTap: () {
                //           // Follow Unfollow Status
                //           setState(() {
                //             if (status == 'notfollowing') {
                //               status = 'isfollowing';
                //             } else if (status == 'isfollowing') {
                //               status = 'notfollowing';
                //             }
                //           });
                //         },
                //       )),
                // ),
              ],
            )),
      ),
    );
  }
}
