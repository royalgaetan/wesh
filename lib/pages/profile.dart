import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wesh/models/event.dart';
import 'package:wesh/pages/in.pages/people.dart';
import 'package:wesh/pages/in.pages/settings.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/utils/db.dart';
import 'package:wesh/widgets/button.dart';
import 'package:wesh/widgets/eventcard.dart';
import 'package:wesh/widgets/imagewrapper.dart';

class profilePage extends StatefulWidget {
  final String uid;

  profilePage({required this.uid});

  @override
  State<profilePage> createState() => _profilePageState();
}

class _profilePageState extends State<profilePage> {
  final int myId = 2;

  bool isMyId(String id) {
    if (widget.uid == myId) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                leading: Container(),
                backgroundColor: Colors.white,
                elevation: 0,
                // pinned: true,
                floating: false,
                toolbarHeight: MediaQuery.of(context).size.height / 2.2,

                snap: false,
                flexibleSpace: FlexibleSpaceBar(
                  expandedTitleScale: 1,
                  titlePadding: EdgeInsets.only(left: 0, bottom: 0, right: 0),
                  title: Column(
                    children: [
                      // Custom App Bar
                      AppBar(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        // leading: IconButton(
                        //   splashRadius: 25,
                        //   onPressed: () {
                        //     Navigator.pop(context);
                        //   },
                        //   icon: Icon(
                        //     Icons.arrow_back_ios_rounded,
                        //     color: Colors.black,
                        //   ),
                        // ),
                        title: Text(
                          '${currentprofile.username}',
                          style: TextStyle(color: Colors.black),
                        ),
                        actions: [
                          IconButton(
                            splashRadius: 22,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SettingPage(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.more_vert_rounded,
                              color: Colors.black,
                            ),
                          )
                        ],
                      ),

                      // HEADER PROFILE PAGE
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile Picture

                            ImageWrapper(
                              type: 'hasStories',
                              borderpadding: 3,
                              borderradius: 3,
                              picture: currentprofile.profilePicture,
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage:
                                    AssetImage(currentprofile.profilePicture),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),

                            // User Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name
                                  Text(
                                    FirebaseAuth.instance.currentUser!.uid,
                                    // '${currentprofile.name}',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),

                                  // Birthday
                                  Row(
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.cakeCandles,
                                        color: Colors.grey.shade500,
                                        size: 11,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        '${DateFormat('d MMM yyyy').format(currentprofile.birthday)}',
                                        style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),

                                  // Bio + Link in Bio
                                  SizedBox(
                                    height: 13,
                                  ),

                                  Text(
                                    '${currentprofile.bio}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black.withOpacity(0.8),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // Redirect to a specific url in In-app Browser
                                    },
                                    child: Text(
                                      '${currentprofile.linkinbio}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.lightBlue.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      // MIDDLE PROFILE PAGE

                      // Profile Stats
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            isMyId('${currentprofile.id}')
                                ? profileStat(
                                    nb: currentprofile.events!.length,
                                    label: 'Contacts',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => PeoplePage(
                                                  tabIndex: 0,
                                                )),
                                      );
                                    },
                                  )
                                : profileStat(
                                    nb: currentprofile.events!.length,
                                    label: 'Evénements',
                                    onTap: () {
                                      // EMPTY LOCATION
                                    },
                                  ),
                            profileStat(
                              nb: currentprofile.followers!.length,
                              label: 'Abonnés',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => PeoplePage(
                                            tabIndex: 1,
                                          )),
                                );
                              },
                            ),
                            profileStat(
                              nb: currentprofile.following!.length,
                              label: 'Abonnem...',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => PeoplePage(
                                            tabIndex: 2,
                                          )),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Profile Button --> Follow/Unfollow, Message | Edit Profile, Feedback, Help
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Button(
                            text: 'Modifier',
                            height: 45,
                            width: 150,
                            fontsize: 16,
                            fontColor: Colors.white,
                            color: kSecondColor,
                            prefixIcon: Icons.edit_rounded,
                            prefixIconColor: Colors.white,
                            prefixIconSize: 22,
                            onTap: () async {
                              // Go to Setting Page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => (SettingPage()),
                                ),
                              );
                            },
                          ),
                          Button(
                            text: 'Feedback',
                            height: 45,
                            width: 150,
                            fontsize: 16,
                            fontColor: Colors.black,
                            color: Colors.white,
                            isBordered: true,
                            prefixIcon: Icons.lightbulb_rounded,
                            prefixIconColor: Colors.black,
                            prefixIconSize: 22,
                            onTap: () {
                              // Launch Feedback Dialog
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            body: Column(
              children: [
                TabBar(
                  labelColor: kSecondColor,
                  unselectedLabelColor: Colors.grey.shade600,
                  indicatorColor: kSecondColor,
                  tabs: const <Widget>[
                    Tab(
                      icon: Icon(FontAwesomeIcons.splotch),
                      // text: "Vos Evénements",
                    ),
                    Tab(
                      icon: Icon(
                        Icons.timer_outlined,
                        size: 29,
                      ),
                      // text: "Vos Rappels",
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // TabBarSection 1
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 15),
                        child: ListView(
                          children: [
                            Column(
                              children: getListEvent(),
                            ),
                          ],
                        ),
                      ),

                      // TabBarSection 2
                      ListView(
                        children: [
                          Column(
                            children: [
                              currentprofile.reminders?.length == 0
                                  ? Container(
                                      height: 300,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.timer_outlined,
                                              color: Colors.grey.shade600,
                                              size: 60,
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              'Vous n\'avez aucun rappel',
                                              style: TextStyle(fontSize: 17),
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Button(
                                                text: 'Créer un rappel',
                                                height: 40,
                                                width: 150,
                                                color: kSecondColor,
                                                onTap: () {
                                                  // Redirect to Create a Reminder Page
                                                  print(
                                                      'Redirect to Create a Reminder Page');
                                                })
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      child: Text(
                                          'Display Reminders here : ${currentprofile.reminders?.length}'),
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
        ),
      ),
    );
  }
}

List<Widget> getListEvent() {
  List<Widget> _listEvents = [];
  late Event event;

  for (event in eventsList) {
    var widget = EventCard(
      trailing: event.trailing,
      title: event.title,
      caption: event.caption,
      startTime: event.startDateTime,
      endTime: event.endDateTime,
      date: event.startDateTime,
    );
    _listEvents.add(widget);
  }
  return _listEvents + _listEvents + _listEvents;
}

class profileStat extends StatelessWidget {
  final int nb;
  final String label;
  final VoidCallback onTap;

  const profileStat({
    required this.nb,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // Number
            Text(
              '$nb',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 19,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 2,
            ),

            // Label
            Text(
              '$label',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
