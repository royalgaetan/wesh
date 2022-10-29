import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/setting_card.dart';

class InviteSomeonePage extends StatefulWidget {
  const InviteSomeonePage({super.key});

  @override
  State<InviteSomeonePage> createState() => _InviteSomeOnePageState();
}

class _InviteSomeOnePageState extends State<InviteSomeonePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
            ),
          ),
          title: const Text(
            'Inviter un.e ami.e',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Column(
          children: [
            // Invite by Whatsapp
            SettingCard(
              onTap: () async {
                //
                onButtonTap(context, Share.whatsapp);
              },
              trailing: Container(),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: kGreyColor,
                child: Icon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.black87.withOpacity(.7),
                  size: 30,
                ),
              ),
              settingTitle: 'Inviter par Whatsapp',
              settingSubTitle: '',
            ),

            // Invite by Facebook
            SettingCard(
              onTap: () async {
                //
                onButtonTap(context, Share.facebook);
              },
              trailing: Container(),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: kGreyColor,
                child: Icon(
                  FontAwesomeIcons.facebook,
                  color: Colors.black87.withOpacity(.7),
                  size: 30,
                ),
              ),
              settingTitle: 'Inviter par Facebook',
              settingSubTitle: '',
            ),

            // Invite by Telegram
            SettingCard(
              onTap: () async {
                //
                onButtonTap(context, Share.share_telegram);
              },
              trailing: Container(),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: kGreyColor,
                child: Icon(
                  FontAwesomeIcons.telegram,
                  color: Colors.black87.withOpacity(.7),
                  size: 30,
                ),
              ),
              settingTitle: 'Inviter par Telegram',
              settingSubTitle: '',
            ),

            // Invite by sms
            SettingCard(
              onTap: () async {
                //
                onButtonTap(context, Share.sms);
              },
              trailing: Container(),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: kGreyColor,
                child: Icon(
                  FontAwesomeIcons.commentSms,
                  color: Colors.black87.withOpacity(.7),
                  size: 30,
                ),
              ),
              settingTitle: 'Inviter par sms',
              settingSubTitle: '',
            ),

            // Invite by email
            SettingCard(
              onTap: () async {
                //
                onButtonTap(context, Share.email);
              },
              trailing: Container(),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: kGreyColor,
                child: Icon(
                  FontAwesomeIcons.envelope,
                  color: Colors.black87.withOpacity(.7),
                  size: 30,
                ),
              ),
              settingTitle: 'Inviter par email',
              settingSubTitle: '',
            ),

            // Invite by [Send link]...
            SettingCard(
              onTap: () async {
                //
                onButtonTap(context, Share.share_system);
              },
              trailing: Container(),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: kGreyColor,
                child: Icon(
                  FontAwesomeIcons.share,
                  color: Colors.black87.withOpacity(.7),
                  size: 30,
                ),
              ),
              settingTitle: 'Inviter par...',
              settingSubTitle: '',
            ),
          ],
        ));
  }
}

///sharing platform
enum Share {
  facebook,
  whatsapp,
  share_telegram,
  sms,
  email,
  share_system,
}

Future<void> onButtonTap(context, Share share) async {
  String msg =
      '$appName te permet de créer et de te rappeler des évenements importants comme les anniversaires de tes proches, ou plus encore. Rejoins moi vite sur ce lien : $downloadAppUrl';

  String url = downloadAppUrl;

  String? response;
  final FlutterShareMe flutterShareMe = FlutterShareMe();
  switch (share) {
    case Share.whatsapp:
      response = await flutterShareMe.shareToWhatsApp(msg: msg);
      break;
    case Share.facebook:
      response = await flutterShareMe.shareToFacebook(url: url, msg: msg);
      break;

    case Share.share_telegram:
      response = await flutterShareMe.shareToTelegram(msg: msg);
      break;

    case Share.sms:
      // Sms

      if (!await launchUrlString('sms:?body=$msg')) {
        showSnackbar(context, 'Impossible de lancer cette url', null);
        throw 'Could not launch sms';
      }
      break;
    case Share.email:
      // Email
      if (!await launchUrlString(
          'mailto:?subject=Viens voir la nouvelle appli&body=$msg')) {
        showSnackbar(context, 'Impossible de lancer cette url', null);
        throw 'Could not launch emailto';
      }
      break;
    case Share.share_system:
      response = await flutterShareMe.shareToSystem(msg: msg);
      break;
  }
  debugPrint(response);
}
