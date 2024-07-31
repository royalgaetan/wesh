import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
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
        appBar: MorphingAppBar(
          toolbarHeight: 46,
          scrolledUnderElevation: 0.0,
          heroTag: 'inviteSomeonePageAppBar',
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
            'Invite a Friend',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Invite by Whatsapp
              SettingCard(
                onTap: () async {
                  //
                  onButtonTap(context, Share.whatsapp);
                },
                trailing: Container(),
                leading: CircleAvatar(
                  radius: 0.08.sw,
                  backgroundColor: kGreyColor,
                  child: Icon(FontAwesomeIcons.whatsapp, color: Colors.black87.withOpacity(.7), size: 22.sp),
                ),
                settingTitle: 'Invite via Whatsapp',
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
                  radius: 0.08.sw,
                  backgroundColor: kGreyColor,
                  child: Icon(FontAwesomeIcons.facebook, color: Colors.black87.withOpacity(.7), size: 22.sp),
                ),
                settingTitle: 'Invite via Facebook',
                settingSubTitle: '',
              ),

              // Invite by Telegram
              SettingCard(
                onTap: () async {
                  //
                  onButtonTap(context, Share.shareTelegram);
                },
                trailing: Container(),
                leading: CircleAvatar(
                  radius: 0.08.sw,
                  backgroundColor: kGreyColor,
                  child: Icon(FontAwesomeIcons.telegram, color: Colors.black87.withOpacity(.7), size: 22.sp),
                ),
                settingTitle: 'Invite via Telegram',
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
                  radius: 0.08.sw,
                  backgroundColor: kGreyColor,
                  child: Icon(FontAwesomeIcons.commentSms, color: Colors.black87.withOpacity(.7), size: 22.sp),
                ),
                settingTitle: 'Invite via SMS',
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
                  radius: 0.08.sw,
                  backgroundColor: kGreyColor,
                  child: Icon(FontAwesomeIcons.envelope, color: Colors.black87.withOpacity(.7), size: 22.sp),
                ),
                settingTitle: 'Invite via Email',
                settingSubTitle: '',
              ),

              // Invite by [Send link]...
              SettingCard(
                onTap: () async {
                  //
                  onButtonTap(context, Share.shareSystem);
                },
                trailing: Container(),
                leading: CircleAvatar(
                  radius: 0.08.sw,
                  backgroundColor: kGreyColor,
                  child: Icon(FontAwesomeIcons.share, color: Colors.black87.withOpacity(.7), size: 22.sp),
                ),
                settingTitle: 'Invite via...',
                settingSubTitle: '',
              ),
            ],
          ),
        ));
  }
}

///sharing platform
enum Share {
  facebook,
  whatsapp,
  shareTelegram,
  sms,
  email,
  shareSystem,
}

Future<void> onButtonTap(context, Share share) async {
  // String msg =
  //     '$appName is an app that lets you create and remember important events like the birthdays 🥳 of your loved ones, and much more. \n\n👉 Join me quickly using this link: $downloadAppUrl';

  String msg =
      "Hey! I just started using this app called $appName and it's been amazing for remembering important dates like birthdays 🥳 and other events. \n\nThought you might like it too! \n\n👉 Check it out here: $downloadAppUrl";

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

    case Share.shareTelegram:
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
      if (!await launchUrlString('mailto:?subject=Try Wesh App&body=$msg')) {
        showSnackbar(context, 'Could not launch this url', null);
        throw 'Could not launch emailto';
      }
      break;
    case Share.shareSystem:
      response = await flutterShareMe.shareToSystem(msg: msg);
      break;
  }
  debugPrint(response);
}
