import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/settings.pages/ask_us_question.dart';
import 'package:wesh/utils/constants.dart';

import 'invite_someone_page.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final List<Item> _data = [
    // Help about events
    Item(
      icon: const Icon(
        FontAwesomeIcons.splotch,
        color: kSecondColor,
      ),
      header: 'Evenements',
      title: '',
      p1: const Padding(
        padding: EdgeInsets.only(bottom: 15),
        child: Text(
            'Vous pouvez créer n\'importe quel type d\'évenement (mariage, soirée, anniversaire, etc.) pour prevenir vos amis et vos abonnés'),
      ),
      p2: const Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Text('😏 Vous pouvez ainsi envoyer un message ou une story associé à votre évenement')),
      p3: const Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Text('Les événements grisés sont des événements qui se sont déjà déroulés')),
    ),

    // Help about reminders
    Item(
      icon: const Icon(
        FontAwesomeIcons.clockRotateLeft,
        color: kSecondColor,
      ),
      header: 'Rappels',
      title: '',
      p1: const Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Text(
              'Les rappels sont là pour vous simplifier la vie, ils vous permettent de vous rappeler un évenement 1 heure, 1 jour ou 1 mois avant que l\'évenement ne commence')),
      p2: const Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Text('Vous pouvez aussi automatiser vos rappels pour chaque jour, chaque année, etc. 😎')),
      p3: const Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Text('Le cas classique est le rappel de l\'anniversaire de l\'un de vos proches 🎉')),
    ),

    // Help about stories
    Item(
      icon: const Icon(
        FontAwesomeIcons.circleNotch,
        color: kSecondColor,
      ),
      header: 'Stories',
      title: '',
      p1: const Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Text(
              'Les stories sont des videos, images ou tout simplement du texte que vous partagez avec vos amis et abonnés pour leur montrer comment se déroule votre évenement, votre journée ou les coulisses de votre business')),
      p2: const Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Text('😌 Malheureusement les stories ne durent que 24 heures ⌚, puis elles disparaissent')),
      p3: const Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Text('Pour les conserver plus longtemps, vous pouvez créer des forevers, 🤩 cool non ?')),
    ),

    // Help about messages
    Item(
      icon: const Icon(
        FontAwesomeIcons.message,
        color: kSecondColor,
      ),
      header: 'Messages',
      title: '',
      p1: const Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Text(
              'Vous pouvez discuter avec n\'importe qui, en envoyant des messages textes, des notes vocales 🎵, des videos 🎬, images 📷, etc.')),
      p2: const Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Text(
              'Plus encore ! Vous pouvez également envoyer ou recevoir de l\'argent 💸 concernant un évenement quelconque, cela peut être les frais d\'entrée d\'un concert par exemple')),
    ),

    // Help about account
    Item(
      icon: const Icon(
        FontAwesomeIcons.userCheck,
        color: kSecondColor,
      ),
      header: 'Comptes et abonnements',
      title: '',
      p1: const Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Text(
              'Vous pouvez suivre une personne ou un compte qui vous interesse pour ne jamais manquer ses évenements ou ses stories ❤')),
      p2: const Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Text('Les autres comptes peuvent à leur tour vous suivre aussi')),
      p3: const Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Text('Astuce : inviter vos amis pour augmenter votre nombre d\'abonnés 😁')),
      buttonText: 'Inviter un ami ici',
      redirectTo: const InviteSomeonePage(),
    ),

    // Ask us any questions
    Item(
      icon: const Icon(
        Icons.person_pin_rounded,
        color: kSecondColor,
        size: 33,
      ),
      header: 'Encore des questions ?',
      title: '',
      p1: const Padding(
        padding: EdgeInsets.only(bottom: 15),
        child: Text(
            'Si vous avez des questions à nous poser, vous pouvez appuyer sur le bouton en bas 👇, et nous allons vous repondre très rapidement'),
      ),
      buttonText: 'Posez votre question ici',
      redirectTo: const AskUsQuestionPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MorphingAppBar(
        heroTag: 'helpCenterPageAppBar',
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
          'Centre d\'aide',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 30, left: 15, right: 15, bottom: 40),
          child: ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                _data[index].isExpanded = !isExpanded;
              });
            },
            children: _data.map<ExpansionPanel>((Item item) {
              return ExpansionPanel(
                canTapOnHeader: true,
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                    title: Text(item.header),
                  );
                },
                body: ListTile(
                    // title: Text(item.title),
                    subtitle: Column(
                      children: [
                        item.p1 ?? Container(),
                        item.p2 ?? Container(),
                        item.p3 ?? Container(),
                        item.redirectTo != null
                            ? TextButton(
                                child: Text(
                                  item.buttonText ?? '',
                                ),
                                onPressed: () {
                                  // Redirect to AskQuestionPage
                                  Navigator.push(
                                      context,
                                      SwipeablePageRoute(
                                        builder: (context) => item.redirectTo!,
                                      ));
                                })
                            : Container(),
                      ],
                    ),
                    trailing: item.icon),
                isExpanded: item.isExpanded,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class Item {
  Item({
    required this.header,
    required this.title,
    this.p1,
    this.p2,
    this.p3,
    this.redirectTo,
    this.buttonText,
    required this.icon,
    this.isExpanded = false,
  });

  String header;
  String title;
  String? buttonText;
  Widget? p1, p2, p3, redirectTo;
  Widget icon;

  bool isExpanded;
}
