import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wesh/models/event.dart';
import 'package:wesh/models/forever.dart';
import 'package:wesh/models/reminder.dart';
import 'package:wesh/pages/in.pages/create_or_update_forever.dart';
import 'package:wesh/pages/in.pages/people.dart';
import 'package:wesh/pages/in.pages/settings.dart';
import 'package:wesh/widgets/forever_card.dart';
import 'package:wesh/widgets/remindercard.dart';
import '../providers/user.provider.dart';
import 'package:wesh/widgets/eventcard.dart';
import '../utils/constants.dart';
import '../utils/functions.dart';
import 'in.pages/create_or_update_event.dart';
import 'in.pages/create_or_update_reminder.dart';
import '../models/user.dart' as UserModel;
import 'settings.pages/feedback_modal.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  final bool? showBackButton;

  const ProfilePage({Key? key, required this.uid, this.showBackButton})
      : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder(
          stream: getUserById(context, widget.uid),
          builder: (context, snapshot) {
            // Data loaded
            if (snapshot.hasData) {
              UserModel.User currentUser = snapshot.data as UserModel.User;
              return DefaultTabController(
                length: 3,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    // APP BAR
                    SliverAppBar(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      expandedHeight: 85,
                      pinned: true,
                      floating: true,
                      snap: true,
                      leading: Container(),
                      flexibleSpace: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          const SizedBox(
                            width: 200,
                            child: FlexibleSpaceBar(
                              centerTitle: false,
                              titlePadding:
                                  EdgeInsets.only(bottom: 10, left: 15),
                              title: Text(
                                'Profil',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 21),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Navigator.of(context).canPop() &&
                                  widget.showBackButton != null &&
                                  widget.showBackButton == true
                              ? IconButton(
                                  splashRadius: 25,
                                  onPressed: () {
                                    // Redirect to Settings Page
                                    Navigator.pop(context);
                                  },
                                  icon: Transform.scale(
                                    scale: 1.2,
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),

                    // TOP BODY

                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          // HEADER
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Profile Picture
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: kGreyColor,
                                  backgroundImage:
                                      NetworkImage(currentUser.profilePicture),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),

                                // User Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Name
                                      Text(
                                        currentUser.name,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),

                                      // Username
                                      Row(
                                        children: [
                                          Icon(
                                            FontAwesomeIcons.at,
                                            color: Colors.grey.shade500,
                                            size: 11,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            currentUser.username,
                                            style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
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
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            DateFormat('d MMM yyyy')
                                                .format(currentUser.birthday),
                                            style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),

                                      // Bio
                                      currentUser.bio.isNotEmpty
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 13),
                                              child: Text(
                                                currentUser.bio,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black
                                                      .withOpacity(0.8),
                                                ),
                                              ),
                                            )
                                          : Container(),

                                      // Link in Bio

                                      currentUser.linkinbio.isNotEmpty
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              child: GestureDetector(
                                                onTap: () async {
                                                  Uri urlToLaunch = Uri.parse(
                                                      currentUser.linkinbio);

                                                  if (!currentUser.linkinbio
                                                          .startsWith(
                                                              "http://") &&
                                                      !currentUser.linkinbio
                                                          .startsWith(
                                                              "https://")) {
                                                    urlToLaunch = Uri.parse(
                                                        "http://${currentUser.linkinbio}");
                                                  }

                                                  if (!await launchUrl(
                                                      urlToLaunch)) {
                                                    showSnackbar(
                                                        context,
                                                        'Impossible de lancer cette url',
                                                        null);
                                                    throw 'Could not launch $urlToLaunch';
                                                  }
                                                },
                                                child: Text(
                                                  currentUser.linkinbio,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors
                                                        .lightBlue.shade600,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),

                                      // PROFILE BUTTONS
                                      FittedBox(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20, bottom: 30),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              CupertinoButton.filled(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 3),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Row(
                                                  children: const [
                                                    Icon(Icons.settings),
                                                    SizedBox(
                                                      width: 6,
                                                    ),
                                                    Text(
                                                      'Paramètres',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                                onPressed: () {
                                                  // Redirect to Settings
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            SettingsPage(
                                                                user:
                                                                    currentUser),
                                                      ));
                                                },
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              CupertinoButton(
                                                color: const Color(0xFFF0F0F0),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 3),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Row(
                                                  children: const [
                                                    Icon(
                                                      Icons
                                                          .auto_awesome_rounded,
                                                      color: Colors.black,
                                                    ),
                                                    SizedBox(
                                                      width: 6,
                                                    ),
                                                    Text(
                                                      'Encore plus',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                onPressed: () async {
                                                  // Show to Feedback Modal
                                                  await showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return Dialog(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child:
                                                            const FeedBackModal(),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),

                          // PROFILE STATS
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: FittedBox(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  profileStat(
                                    icon: const Icon(FontAwesomeIcons.splotch,
                                        color: Colors.black54),
                                    nb: currentUser.events!.length,
                                    label: 'Evénements',
                                    onTap: () {
                                      // EMPTY LOCATION
                                    },
                                  ),
                                  profileStat(
                                    icon: const Icon(FontAwesomeIcons.userCheck,
                                        color: Colors.black54),
                                    nb: currentUser.followers!.length,
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
                                    icon: const Icon(FontAwesomeIcons.userGroup,
                                        color: Colors.black54),
                                    nb: currentUser.following!.length,
                                    label: 'Abonnements',
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
                          ),

                          // Divider
                          const SizedBox(height: 10),
                          const SizedBox(
                            width: double.infinity,
                            child: Divider(
                              height: 1,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  body: Column(
                    children: [
                      // TAB BAR
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
                              FontAwesomeIcons.clockRotateLeft,
                            ),
                            // text: "Vos Rappels",
                          ),
                          Tab(
                            icon: Icon(
                              FontAwesomeIcons.circleNotch,
                            ),
                            // text: "Vos Rappels",
                          ),
                        ],
                      ),

                      //  TAB BAR CONTENT
                      Expanded(
                        child: TabBarView(
                          children: [
                            // TabBarSection 1 : Events
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 15),
                              child: StreamBuilder<List<Event>>(
                                stream: Provider.of<UserProvider>(context)
                                    .getCurrentUserEvents(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    List<Event>? eventsList = snapshot.data;
                                    eventsList!.sort((a, b) =>
                                        b.createdAt.compareTo(a.createdAt));
                                    if (eventsList.isEmpty) {
                                      return Container(
                                        padding: const EdgeInsets.all(30),
                                        height: 300,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Lottie.asset(
                                              height: 150,
                                              'assets/animations/112136-empty-red.json',
                                              width: double.infinity,
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              widget.uid ==
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid
                                                  ? 'Vous n\'avez aucun évenement'
                                                  : 'Aucun évenement trouvé !',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black45,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            widget.uid ==
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid
                                                ? TextButton(
                                                    onPressed: () {
                                                      // Redirect to Create an event Page
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                CreateOrUpdateEventPage(),
                                                          ));
                                                    },
                                                    child: const Text(
                                                        '+ Créer un évenement'),
                                                  )
                                                : Container()
                                          ],
                                        ),
                                      );
                                    }

                                    return ListView(
                                      padding: const EdgeInsets.all(0),
                                      children: eventsList.map((event) {
                                        return EventCard(event: event);
                                      }).toList(),
                                    );
                                  }
                                  return const SizedBox(
                                    height: 100,
                                    child: CupertinoActivityIndicator(),
                                  );
                                },
                              ),
                            ),

                            // TabBarSection 2 : Reminders
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 10),
                              child: StreamBuilder<List<Reminder>>(
                                stream: Provider.of<UserProvider>(context)
                                    .getCurrentUserReminders(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    List<Reminder> listReminder =
                                        snapshot.data as List<Reminder>;

                                    listReminder.sort((a, b) =>
                                        b.createdAt.compareTo(a.createdAt));

                                    if (listReminder.length == 0) {
                                      return Container(
                                        padding: const EdgeInsets.all(30),
                                        height: 300,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Lottie.asset(
                                              height: 150,
                                              'assets/animations/112136-empty-red.json',
                                              width: double.infinity,
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              widget.uid ==
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid
                                                  ? 'Vous n\'avez aucun rappel'
                                                  : 'Aucun rappel trouvé !',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black45,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            widget.uid ==
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid
                                                ? TextButton(
                                                    onPressed: () {
                                                      // Redirect to Create a Reminder Page
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                CreateOrUpdateReminderPage(),
                                                          ));
                                                    },
                                                    child: const Text(
                                                        '+ Créer un rappel'),
                                                  )
                                                : Container()
                                          ],
                                        ),
                                      );
                                    }

                                    return ListView(
                                      children: listReminder.map((reminder) {
                                        return ReminderCard(reminder: reminder);
                                      }).toList(),
                                    );
                                  }
                                  return const SizedBox(
                                    height: 100,
                                    child: CupertinoActivityIndicator(),
                                  );
                                },
                              ),
                            ),

                            //  TabBarSection 3 : Forever
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 15),
                              child: StreamBuilder<List<Forever>>(
                                stream: Provider.of<UserProvider>(context)
                                    .getCurrentUserForevers(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    List<Forever> foreversList = snapshot.data!;

                                    // Sort forevers List
                                    foreversList.sort((a, b) =>
                                        b.modifiedAt.compareTo(a.modifiedAt));

                                    // No forever found
                                    if (foreversList.isEmpty) {
                                      return Container(
                                        padding: const EdgeInsets.all(30),
                                        height: 300,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Lottie.asset(
                                              height: 150,
                                              'assets/animations/112136-empty-red.json',
                                              width: double.infinity,
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            const Text(
                                              'Vous n\'avez aucun forever',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black45,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            widget.uid ==
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid
                                                ? TextButton(
                                                    onPressed: () {
                                                      // Redirect to Create an event Page
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const CreateOrUpdateForeverPage(),
                                                          ));
                                                    },
                                                    child: const Text(
                                                        '+ Créer un forever'),
                                                  )
                                                : Container()
                                          ],
                                        ),
                                      );
                                    }

                                    // Display all forevers
                                    return ListView(
                                      padding: const EdgeInsets.all(0),
                                      children: [
                                        // Create a new forever
                                        widget.uid ==
                                                FirebaseAuth
                                                    .instance.currentUser!.uid
                                            ? InkWell(
                                                onTap: () {
                                                  //
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const CreateOrUpdateForeverPage(),
                                                    ),
                                                  );
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(15),
                                                  child: Row(
                                                    children: const [
                                                      // Trailing Avatar
                                                      CircleAvatar(
                                                        radius: 22,
                                                        backgroundColor:
                                                            kSecondColor,
                                                        child: Icon(
                                                            FontAwesomeIcons
                                                                .circleNotch,
                                                            color:
                                                                Colors.white),
                                                      ),

                                                      //
                                                      SizedBox(
                                                        width: 15,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          'Créer un forever',
                                                          style: TextStyle(
                                                              fontSize: 17,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      // Edit Forever
                                                      Spacer(),

                                                      IconButton(
                                                        splashRadius: 25,
                                                        onPressed: null,
                                                        icon: Icon(
                                                          Icons.add,
                                                          color: Colors.black54,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Container()
                                        // All forevers
                                      ]..addAll(foreversList.map((forever) {
                                          return ForeverCard(
                                            foreversList: foreversList,
                                            initialForeverIndex:
                                                foreversList.indexOf(forever),
                                          );
                                        }).toList()),
                                    );
                                  }
                                  return const SizedBox(
                                    height: 100,
                                    child: CupertinoActivityIndicator(),
                                  );
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

            // Waiting...
            return Container();
          }),
    );
  }
}

class profileStat extends StatelessWidget {
  final int nb;
  final String label;
  final Widget icon;
  final VoidCallback onTap;

  const profileStat({
    Key? key,
    required this.nb,
    required this.label,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          // Label
          Text(
            label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade700),
          ),
          const SizedBox(
            height: 5,
          ),

          InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: const Color.fromARGB(255, 234, 234, 234).withOpacity(.6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
              child: Row(
                children: [
                  // Icon
                  Transform.scale(
                    scale: 0.8,
                    child: icon,
                  ),
                  const SizedBox(
                    width: 13,
                  ),

                  // Number
                  Text(
                    '$nb',
                    style: const TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
