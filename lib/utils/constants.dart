import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:timeago/timeago.dart';
import 'package:wesh/services/notifications_api.dart';
import 'package:wesh/widgets/buildWidgets.dart';
import '../models/eventtype.dart';
import '../models/feedbacktype.dart';
import '../pages/settings.pages/help_center_page.dart';

// Links and ref
const String appName = 'Wesh';
const String appVersion = '0.2';
final String year = DateTime.now().year.toString();
const String appEmail = 'app.wesh@gmail.com';
const String downloadAppUrl = 'https://wesh.grwebsite.com/';
const String privacyPolicyUrl = 'https://wesh.grwebsite.com/politique-de-confidentialite-en';

// ENV && App var
// fileLimitSize : 15MB
const int fileLimitSize15MB = 15000000;
const int fileLimitSize10MB = 10000000;
const int fileLimitSize5MB = 5000000;
const int fileLimitSize2MB = 2000000;

// Notifications Channels
List<NotificationChannel> notificationsChannelList = [
  NotificationChannel(
    channelId: '0',
    channelName: 'Messages',
    channelDescription: 'Receive notifications for messages addressed to you',
    channelImportance: Importance.max,
    channelPriority: Priority.defaultPriority,
    audioAttributesUsage: AudioAttributesUsage.notification,
  ),
  NotificationChannel(
    channelId: '1',
    channelName: 'Events',
    channelDescription: 'Receive notifications for events that concern you',
    channelImportance: Importance.max,
    channelPriority: Priority.high,
    audioAttributesUsage: AudioAttributesUsage.notificationEvent,
  ),
  NotificationChannel(
    channelId: '2',
    channelName: 'Reminders',
    channelDescription: 'Receive notifications for reminders you set up',
    channelImportance: Importance.max,
    channelPriority: Priority.max,
    audioAttributesUsage: AudioAttributesUsage.alarm,
  ),
  NotificationChannel(
    channelId: '3',
    channelName: 'Stories',
    channelDescription: 'Receive notifications for new stories',
    channelImportance: Importance.max,
    channelPriority: Priority.defaultPriority,
    audioAttributesUsage: AudioAttributesUsage.notification,
  ),
];

// Colors
const kPrimaryColor = Color(0xFF68002C);
const kSecondColor = Color(0xFFE02F66);
const kWarningColor = Color.fromARGB(255, 255, 190, 50);
final kSuccessColor = Colors.green.shade400;
final kInfoColor = Colors.lightBlue.shade600;
const kGreyColor = Color(0xFFF0F0F0);
const kDark = Color(0xFF1F2A36);

// Constants : Payment Method
const mtnMobileMoneyLabel = 'Mobile Money';
const airtelMoneyLabel = 'Airtel Money';

// Useful Logos
const String weshLogoBlack = 'assets/images/useful.logos/wesh_logo_black.svg';
const String weshLogoColored = 'assets/images/useful.logos/wesh_logo_colored.svg';
const String weshFaviconPic = 'assets/images/useful.logos/wesh_favicon.png';
const String weshLogoPic = 'assets/images/useful.logos/wesh_logo.png';
const String googleLogo = 'assets/images/useful.logos/google_logo.svg';
const String phoneLogo = 'assets/images/useful.logos/phone_logo.svg';
const String facebookLogo = 'assets/images/useful.logos/facebook_logo.svg';
const String mtnMobileMoneyLogo = 'assets/images/useful.logos/mtn_mobile_money_logo.png';
const String airtelMoneyLogo = 'assets/images/useful.logos/airtel_money_logo.png';

// Core Assets
const String defaultProfilePicture = 'assets/images/core.assets/default_profile_picture.png';
const String darkBackground = 'assets/images/core.assets/dark_background.png';
const String gift = 'assets/images/core.assets/gift.png';
const String music = 'assets/images/core.assets/music.png';
const String ballons = 'assets/images/core.assets/ballons.png';
const String bell = 'assets/images/core.assets/bell.png';
const String soundWaves = 'assets/images/core.assets/sound_waves.png';

// Audio Assets
const String christmasCrowdCheer = 'assets/audios/christmas_crowd_cheer.mp3';

// Animations | Lottie, JSON
const String happyBirthday = 'assets/animations/happy_birthday.json';
const String empty = 'assets/animations/empty.json';
const String waves = 'assets/animations/waves.json';
const String selfie = 'assets/animations/selfie.json';
const String smartPhoneMoney = 'assets/animations/smartphone_money.json';
const String star = 'assets/animations/star.json';

const List<String> monthsList = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];

// Time ago messages
class EnMessagesShortsform implements LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'just now';
  @override
  String aboutAMinute(int minutes) => '1min';
  @override
  String minutes(int minutes) => '${minutes}min';
  @override
  String aboutAnHour(int minutes) => '1h';
  @override
  String hours(int hours) => '${hours}h';
  @override
  String aDay(int hours) => '1d';
  @override
  String days(int days) => '${days}d';
  @override
  String aboutAMonth(int days) => '1mo';
  @override
  String months(int months) => '${months}mo';
  @override
  String aboutAYear(int year) => '1y';
  @override
  String years(int years) => '${years}y';
  @override
  String wordSeparator() => ' ';
}

// Reminders
final remindersList = [
  Text(
    'as soon as it starts',
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 16.sp, color: Colors.black),
  ),
  Text(
    '10min before',
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 16.sp, color: Colors.black),
  ),
  Text(
    '1h before',
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 16.sp, color: Colors.black),
  ),
  Text(
    '1 day before',
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 16.sp, color: Colors.black),
  ),
  Text(
    '3 days before',
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 16.sp, color: Colors.black),
  ),
  Text(
    '1 week before',
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 16.sp, color: Colors.black),
  ),
  Text(
    '1 month before',
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 16.sp, color: Colors.black),
  ),
];

const recurrencesList = [
  Text(
    'No recurrence',
    style: TextStyle(color: Colors.black, fontSize: 14),
  ),
  Text(
    'Every day',
    style: TextStyle(color: Colors.black, fontSize: 14),
  ),
  Text(
    'Every week',
    style: TextStyle(color: Colors.black, fontSize: 14),
  ),
  Text(
    'Every month',
    style: TextStyle(color: Colors.black, fontSize: 14),
  ),
  Text(
    'Every year',
    style: TextStyle(color: Colors.black, fontSize: 14),
  ),
];

// Feedback Available Type
List<FeedBackType> feedbackAvailableTypeList = [
  FeedBackType(index: 1, emoji: '😞', title: 'Disappointed'),
  FeedBackType(index: 2, emoji: '😒', title: 'Not cool'),
  FeedBackType(index: 3, emoji: '🙄', title: 'I don\'t know'),
  FeedBackType(index: 4, emoji: '😊', title: 'I like it'),
  FeedBackType(index: 5, emoji: '🥰', title: 'Awesome'),
];

// Event Available Type
List<EventType> eventAvailableTypeList = [
  EventType(
    key: 'birthday',
    name: 'Birthday',
    recurrence: true,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'baptismbirthday',
    name: 'Baptism Birthday',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'weddingbirthday',
    name: 'Wedding Anniversary',
    recurrence: true,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'communion',
    name: 'Communion',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'concert',
    name: 'Concert',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'conference',
    name: 'Conference',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'courses',
    name: 'Courses',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'burial',
    name: 'Burial',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'exam',
    name: 'Exam',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'exposition',
    name: 'Exposition',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'fashionshow',
    name: 'Fashion Show',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'festival',
    name: 'Festival',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'party',
    name: 'Party',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'inauguration',
    name: 'Inauguration',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'religiousday',
    name: 'Religious Day',
    recurrence: true,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'specialday',
    name: 'Special Day',
    recurrence: true,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'internationalday',
    name: 'International Day',
    recurrence: true,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'nationalday',
    name: 'National Day',
    recurrence: true,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'productlaunch',
    name: 'Product Launch',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'masterclass',
    name: 'Master Class',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'picnic',
    name: 'Picnic',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'mourningwithdrawal',
    name: 'Mourning Withdrawal',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'meeting',
    name: 'Meeting',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'tradeshow',
    name: 'Trade Show',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'seminar',
    name: 'Seminar',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'show',
    name: 'Show',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'gala',
    name: 'Gala',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'privateparty',
    name: 'Private Party',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'poll',
    name: 'Poll',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'teambuilding',
    name: 'Team Building',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'hiring',
    name: 'Hiring',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'visioconference',
    name: 'Video Conference',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'dot',
    name: 'Dowry',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'predot',
    name: 'Pre-dowry',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'wedding',
    name: 'Wedding',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'other',
    name: 'Other',
    recurrence: true,
    iconPath: '',
    description: '',
  ),
];

// Event Available Colors
const eventAvailableColorsList = [
  Color.fromARGB(255, 239, 79, 133),
  Color(0xFFFF6347),
  Color.fromARGB(255, 248, 210, 61),
  Color.fromARGB(255, 19, 186, 64),
  Color.fromARGB(255, 15, 80, 134),
  Color.fromARGB(255, 147, 13, 220),
  Color(0xFF4B4E53),
];

// Stories Text BackGround Available Colors
const storiesAvailableColorsList = [
  Color(0xFF16A085),
  Color(0xFF27AE60),
  Color(0xFF1A73E8),
  Color(0xFF2980B9),
  Color(0xFF2C3E50),
  Color(0xFF8E44AD),
  Color(0xFF9B59B6),
  Color(0xFFF39C12),
  Color(0xFFD35400),
  Color(0xFFC0392B),
  Color(0xFF7F8C8D),
];

// Stories Text Available Fonts
const storiesAvailableFontsList = [
  'Calibri',
  'Comic Sans MS',
  'Helvetica',
  'Moderat',
  'Parnaso',
  'Roboto',
  'Simula',
];

// Introduction Pages
List<PageViewModel> listPagesViewModel = [
  PageViewModel(
    title: "Welcome to $appName",
    bodyWidget: const BuildIntroductionPageContent(
      animationPath: star,
      title: 'Create events',
      description: 'Alert your friends about important dates\nlike your birthday 🎉🎈',
    ),
  ),
  PageViewModel(
    title: "",
    bodyWidget: const BuildIntroductionPageContent(
      animationPath: selfie,
      title: 'Share Stories',
      description: 'Show live updates to your friends\non how your event is going 🔥',
    ),
  ),
  PageViewModel(
    title: "",
    bodyWidget: const BuildIntroductionPageContent(
      animationPath: smartPhoneMoney,
      title: 'Chat in real time',
      description: 'Receive gifts, messages, or money 💰\nfrom your friends regarding your event',
    ),
  ),
];

/////////////////////////////////////
// HELP DATA
/////////////////////////////////////
final helpDB = [
  HelpItem(
    title: 'Get Started',
    icon: Icon(Icons.flag, color: Colors.white, size: 24.sp),
    content: [
      const HelpItemContent(
        subHeader: 'Create an Account',
        contentList: [
          TextSpan(
            text:
                'To get started, download the Wesh app (available here) and create an account on the Sign-Up page right after installation 📲\n\n',
          ),
          TextSpan(
            text: 'Creating an account is simple: you can use your ',
          ),
          WidgetSpan(
            child: Icon(Icons.email, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' email address, ',
          ),
          WidgetSpan(
            child: Icon(FontAwesomeIcons.google, size: 13, color: Colors.black87),
          ),
          TextSpan(
            text: ' Google, or ',
          ),
          WidgetSpan(
            child: Icon(FontAwesomeIcons.facebook, size: 13, color: Colors.black87),
          ),
          TextSpan(
            text: ' Facebook\n\n',
          ),
          TextSpan(
            text: 'Next, enter your birthday 🎂 (this will be your default event and cannot be changed later)\n\n',
          ),
          TextSpan(
            text: 'For account security, you\'ll also need to set a ',
          ),
          WidgetSpan(
            child: Icon(Icons.lock, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' password 🔒\n\n',
          ),
          TextSpan(
              text: 'And voilà! Your account is live and ready! 🎉\n\n\n',
              style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(
            text:
                'First, Wesh will introduce you to the app with quick tutorial pages. You\'ll then be prompted to follow people you know 💖 or find interesting 🌟\n\n',
          ),
          TextSpan(
            text:
                'Once you start following people (friends, family, etc.), you\'ll receive notifications about their events like birthdays, meetings, weddings, parties, etc., along with smart reminders to help you prepare if necessary 🔔\n\n',
          ),
          TextSpan(
            text:
                'You can choose to disable notifications for certain events and only keep the ones that matter most to you 📋',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Supported Devices and Operating Systems',
        contentList: [
          TextSpan(
            text: 'Currently, Wesh is available on ',
          ),
          WidgetSpan(
            child: Icon(FontAwesomeIcons.android, size: 13, color: Colors.black87),
          ),
          TextSpan(
            text:
                ' Android, with iOS and Web versions coming soon. \n\nWesh is still new and is gradually releasing features for early users to test and provide feedback. This means it\'s not yet available on the Play Store, App Store, or any other app stores 📱\n\n',
          ),
          TextSpan(
            text:
                'For Android, we support devices running OS 6 and newer. Please ensure your device meets this requirement ✅\n\n',
          ),
          TextSpan(
            text: 'The only place to download and test Wesh is through our website 🌐\n\n',
          ),
          TextSpan(
            text:
                'We\'re working hard to quickly complete all necessary proofs of concept so that Wesh can be available on all stores, as well as on iOS and the web. Don\'t forget to share your feedback! 📢\n\n',
          ),
          TextSpan(
            text: 'Stay tuned for updates on the Wesh website! 🔔',
          ),
        ],
      ),
      HelpItemContent(
        subHeader: 'Troubleshooting',
        contentList: [
          const TextSpan(
            text: 'Issue with Login:\n\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: '\t\t■ If you encounter problems while logging in, first check your network connection\n\n',
          ),
          const TextSpan(
            text:
                '\t\t■ Ensure you\'re using the correct credentials you used to create your account. If you created your account with ',
          ),
          const WidgetSpan(
            child: Icon(FontAwesomeIcons.google, size: 13, color: Colors.black87),
          ),
          const TextSpan(
            text: ' Google, you must log in using Google. The same applies to other authentication methods like ',
          ),
          const WidgetSpan(
            child: Icon(FontAwesomeIcons.facebook, size: 13, color: Colors.black87),
          ),
          const TextSpan(
            text: ' Facebook and ',
          ),
          const WidgetSpan(
            child: Icon(Icons.email, size: 16, color: Colors.black87),
          ),
          const TextSpan(
            text: ' email address\n\n',
          ),
          const TextSpan(
            text: '\nIssue with Registration:\n\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: '\t\t■ When registering for the first time, make sure to follow the guidelines for each field:\n\n',
          ),
          subSubHelpItem(
              title: 'Username',
              widgetSpanChildren: [],
              text:
                  'must be at least 4 characters, all in lowercase. Only alphanumeric characters (a-z), numbers (0-9), and underscores are allowed. Example: john_doe23, sarah_bell\n\n'),
          subSubHelpItem(
              widgetSpanChildren: [],
              title: 'Name',
              text:
                  'enter your real name or the name you use daily so people can easily find you later. It should be less than 45 characters, with no character restrictions\n\n'),
          subSubHelpItem(
              widgetSpanChildren: [],
              title: 'Birthday',
              text:
                  'enter your real birthday as it can\'t be changed later. Wesh often gives gifts and discounts on user birthdays to prevent abuse 🎁\n\n'),
          subSubHelpItem(
            title: 'Authentication Methods',
            widgetSpanChildren: [
              const WidgetSpan(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(FontAwesomeIcons.facebook, size: 10, color: Colors.black87),
                ),
              ),
              const TextSpan(
                text: ', ',
              ),
              const WidgetSpan(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(FontAwesomeIcons.google, size: 10, color: Colors.black87),
                ),
              ),
              const TextSpan(
                text: ', or your ',
              ),
              const WidgetSpan(
                child: Icon(Icons.email, size: 12, color: Colors.black87),
              ),
              const TextSpan(
                text:
                    ' address. Remember which one you use and the credentials, as they will be needed for future logins or password recovery\n\n',
              ),
            ],
          ),
          subSubHelpItem(
              widgetSpanChildren: [],
              title: 'Password Confirmation',
              text: 'make sure it matches the password you entered above\n\n'),
          subSubHelpItem(
              widgetSpanChildren: [],
              title: 'Profile Picture',
              text:
                  'You can pick a picture from your device, use the camera, or leave it as default. We recommend using a picture of yourself so people can find you easily 📸. If you have issues uploading your profile picture, check your connection and note that upload time may vary based on your picture size and network speed. We recommend using a picture under 5MB\n\n'),
          ...troubleshootingNext,
        ],
      )
    ],
  ),
  HelpItem(
    title: 'Timeline',
    icon: Icon(Icons.calendar_month_rounded, color: Colors.white, size: 22.sp),
    content: [
      const HelpItemContent(
        subHeader: 'About the Timeline',
        contentList: [
          TextSpan(
            text:
                'Wesh presents all your events, as well as the events and reminders of people you follow, in a centralized, calendar-based timeline 📅.\n\nYou\'ll find this in your Home Tab when you start Wesh and are already logged in\n\n',
          ),
          TextSpan(
            text:
                'Currently, only the Schedule View mode is available. More views will be added in future versions, including Monthly, Weekly, and Daily 📆\n\n',
          ),
          TextSpan(
            text:
                'When you add or update an event or reminder, or if someone you follow creates or updates an event, it will automatically sync and appear on your timeline 🔄',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'What About Recurrent Events and Reminders?',
        contentList: [
          TextSpan(
            text:
                'Our calendar-based timeline handles events that occur on multiple days (e.g., seminar) or follow a specific recurrence (daily, weekly, yearly, etc., like birthdays) 🎉\n\n',
          ),
          TextSpan(
            text: 'This allows you to have a clear visual of the duration and frequency of events 📅\n\n',
          ),
          TextSpan(
            text:
                'This also applies to reminders, known as intelligent reminders.\n\nFor instance, if you created a reminder for an event that happens at the beginning of each month, you\'ll see this reminder\'s recurrence at the beginning of each month 📅',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Understanding Event and Reminder Card Content',
        contentList: [
          TextSpan(
            text: 'On your timeline, each event and reminder is displayed within a card 🃏\n\n',
          ),
          TextSpan(
            text: '\t\t■ Event Card:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: '${'       '}\t\t◆ Colored in the specific color chosen when the event was created\n\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ Displays the title of the event at the top 🏷️\n\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ Shows the person who created the event at the bottom left 👤\n\n',
          ),
          TextSpan(
            text:
                '${'       '}\t\t◆ Indicates the event\'s start time at the bottom right, either as a time range or "All-day" for events that last the entire day 🕒\n\n',
          ),
          TextSpan(
            text: '\t\t■ Reminder Card:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: '${'       '}\t\t◆ Displays only the title of the reminder 📝\n\n',
          ),
          TextSpan(
            text:
                'Clicking on any of these cards (event or reminder) will show more detailed information in a dedicated modal 🖱️',
          ),
        ],
      ),
      HelpItemContent(
        subHeader: 'Troubleshooting',
        contentList: [
          const TextSpan(
            text: 'Issue with Events or Reminders in Your Timeline:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\n\n\t\t■ Tap on the Wesh logo at the top left corner of your home tab. This will reload and sync your timeline with your events, the events of people you follow, and your reminders 🔄\n\n\n',
          ),
          const TextSpan(
            text: 'Scrolling Too Far from Today’s Date:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: '\n\n\t\t■ Simply tap on the Home tab button to be redirected to today’s date 🗓️\n\n',
          ),
          ...troubleshootingNext,
        ],
      )
    ],
  ),
  HelpItem(
    title: 'Events',
    icon: Icon(FontAwesomeIcons.splotch, color: Colors.white, size: 22.sp),
    content: [
      const HelpItemContent(
        subHeader: 'What’s an Event?',
        contentList: [
          TextSpan(
            text:
                'Wesh revolves around events 🎉. Events represent occasions that occur within a specific time frame—whether it\'s a day, month, or recurring event—held either online or offline\n\n',
          ),
          TextSpan(
            text:
                'These range from birthdays, weddings, concerts, and parties to fashion shows, exhibitions, exams, seminars, product launches, meetings, and more 🎊\n\n',
          ),
          TextSpan(
            text: 'Each user has a default event: their birthday, which cannot be changed 🎂\n',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Where to See, Check, and Manage My Events?',
        contentList: [
          TextSpan(
            text: 'You can view and manage your events in two main places:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Profile Page:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: ' Events are displayed here from newest to oldest based on their creation date\n',
          ),
          TextSpan(
            text: '\t\t■ Timeline:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: ' Events are shown alongside the days they will occur 📅\n\n\n',
          ),
          TextSpan(
            text: 'You can also explore events created by others through the search feature:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Navigate to your ',
          ),
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(bottom: 2, right: 1, left: 1),
              child: Icon(FontAwesomeIcons.house, size: 12, color: Colors.black87),
            ),
          ),
          TextSpan(
            text: ' Home Page, then click on the magnifying glass icon ',
          ),
          WidgetSpan(
            child: Icon(Icons.search, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' (top right), select the Events tab, and search by event title',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Event Details',
        contentList: [
          TextSpan(
            text:
                'Events are displayed within colored event cards that you can tap to view detailed information 🃏:\n\n',
          ),
          TextSpan(
            text: '\t\t■ ',
          ),
          TextSpan(
            text: 'Event Name\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: '\t\t■ ',
          ),
          TextSpan(
            text: 'Countdown to Start Time ⏳\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: '\t\t■ ',
          ),
          TextSpan(
            text: 'Edit (if it\'s your event) or Reply to the Creator 📝\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: '\t\t■ ',
          ),
          TextSpan(
            text: 'Reminders Set 🔔\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: '\t\t■ ',
          ),
          TextSpan(
            text: 'Event Creator 👤\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: '\t\t■ ',
          ),
          TextSpan(
            text: 'Event Type (e.g., birthday, meeting, seminar)\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: '\t\t■ ',
          ),
          TextSpan(
            text: 'Date, Time, and Recurrence 🗓️\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: '\t\t■ ',
          ),
          TextSpan(
            text: 'Location (physical or online)\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: '\t\t■ ',
          ),
          TextSpan(
            text: 'Event Link (if available)\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: '\t\t■ ',
          ),
          TextSpan(
            text: 'Event Description 📝\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: '\t\t■ ',
          ),
          TextSpan(
            text: 'Creation or Update Timestamp\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'How to Create an Event?',
        contentList: [
          TextSpan(
            text: 'Tap the ',
          ),
          WidgetSpan(
            child: Icon(Icons.add, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' icon and select “⭐ Create an Event”. Then enter the following details:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Event Name: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'Up to 45 characters\n\n',
          ),
          TextSpan(
            text: '\t\t■ Description: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'Up to 500 characters\n\n',
          ),
          TextSpan(
            text: '\t\t■ Event Type: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'Choose from options like party, master class, special day, meeting, etc.\n\n',
          ),
          TextSpan(
            text: '\t\t■ Event Link: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'Provide a valid external link if needed\n\n',
          ),
          TextSpan(
            text: '\t\t■ Location: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'Specify a physical venue if applicable\n\n',
          ),
          TextSpan(
            text: '\t\t■ Cover Photo: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'Use the default or upload a custom photo\n\n',
          ),
          TextSpan(
            text: '\t\t■ Date and Time: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'Select One-day or multi-day event with customizable timing\n\n',
          ),
          TextSpan(
            text: '\t\t■ Color: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'Choose a color to distinguish your event card\n',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'How to Edit an Event?',
        contentList: [
          TextSpan(
            text: 'To edit an event:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Navigate to your Profile Page (by clicking on the ',
          ),
          WidgetSpan(
            child: Icon(Icons.person, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' icon)\n\n',
          ),
          TextSpan(
            text:
                '\t\t■  Click on the Event tab (just before the Reminder tab) or find the event card in your timeline, then click on it\n\n',
          ),
          TextSpan(
            text: '\t\t■  In the event modal, click on the “',
          ),
          WidgetSpan(
            child: Icon(Icons.edit, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' Edit” button located below the event title or next to the Reminder button\n\n',
          ),
          TextSpan(
            text: '\t\t■ On the edit page, you can modify:\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ Event title\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ Description\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ Event type (e.g., switch from Masterclass to Seminar)\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ Event link (valid and working links only)\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ Location\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ Cover photo (choose default or upload from Gallery or Camera)\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ Date and time (switch between One-day event or Multi-day event)\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ Event color\n\n',
          ),
          TextSpan(
            text: '\t\t■ Validate your changes by clicking "',
          ),
          WidgetSpan(
            child: Icon(Icons.edit, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' Edit” on the top right corner of the edit page\n\n\n',
          ),
          TextSpan(
            text: 'Note:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                '\t\tEditing the event date will automatically update all attached reminders to reflect the new date\n\n',
          ),
          TextSpan(
            text: '\t\tYou cannot edit the date/time or type of your birthday event because it’s your birthday\n\n',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'How to Delete an Event?',
        contentList: [
          TextSpan(
            text: 'To delete an event:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Navigate to your Profile Page (by clicking on the ',
          ),
          WidgetSpan(
            child: Icon(Icons.person, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' icon)\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ Click on the Event tab (just before the Reminder tab) or wherever you see an event card (e.g., in your timeline), and click on it\n\n',
          ),
          TextSpan(
            text: '\t\t■ In the event Modal, click on the “',
          ),
          WidgetSpan(
            child: Icon(Icons.edit, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' Edit” button located below the event title or next to the Reminder button\n\n',
          ),
          TextSpan(
            text: '\t\t■ On the edit page, locate the delete icon or trash button ',
          ),
          WidgetSpan(
            child: Icon(Icons.delete_rounded, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' at the bottom right of the page\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ You’ll be prompted to confirm the permanent deletion of the event. Click on “Delete” to proceed\n\n',
          ),
          TextSpan(
            text: 'Note:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                '\t\tWhen you delete an event, it will be completely removed from our database. Any reminders attached to it will also be deleted. The event will no longer appear in your Home Timeline or your Profile > Event tab\n',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Who Can See My Events and What Events Can I See?',
        contentList: [
          TextSpan(
            text: 'Any user of Wesh who visits your profile or follows you can see your events\n\n',
          ),
          TextSpan(
            text:
                'Similarly, you can view events of any user on Wesh by following them, visiting their profile, or using the search functionality\n\n',
          ),
          TextSpan(
            text:
                'In future versions, we plan to enhance event privacy options so you can restrict or allow access to your events for specific individuals or groups\n',
          ),
        ],
      ),
      HelpItemContent(
        subHeader: 'Troubleshooting',
        contentList: [
          const TextSpan(
            text: 'Can’t View or Load Event Details:\n\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\t\t■ First, check your internet connection. If the issue persists, consider sending a bug report to help us troubleshoot the problem. Sometimes, this issue occurs if the event you’re trying to view has been deleted at the moment you clicked on it.\n\n\n',
          ),
          const TextSpan(
            text: 'Can’t Create or Update an Event:\n\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\t\t■ If you encounter an error, ensure all required fields are filled correctly. Error messages will appear before you validate your edits, allowing you to correct any mistakes.\n\n\n',
          ),
          const TextSpan(
            text: 'Can’t Load All Event Reminders:\n\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\t\t■ First, verify that you have created reminders associated with the event. If reminders exist and the issue persists, dismiss the event modal and click on the event card again to try reloading.\n\n\n',
          ),
          const TextSpan(
            text: 'Event Link Throws an Error:\n\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\t\t■ If an event link throws an error, it is likely broken. Contact the event creator to fix it. We always ensure that links leading outside Wesh are valid, safe, and relevant.\n\n',
          ),
          ...troubleshootingNext,
        ],
      ),
    ],
  ),
  HelpItem(
    title: 'Reminders',
    icon: Icon(FontAwesomeIcons.clockRotateLeft, color: Colors.white, size: 20.sp),
    content: [
      const HelpItemContent(
        subHeader: 'About Intelligent Reminders',
        contentList: [
          TextSpan(
            text:
                'Intelligent reminders are alerts or notifications that trigger at specific times to remind you about an event or a date you’ve set. 📅\n\n',
          ),
          TextSpan(
            text:
                'They are called intelligent because they adapt to changes in the event they are attached to.\n\nIf the event is deleted or updated, or if it has a recurrence pattern, the reminders are automatically adjusted or removed to ensure you stay informed without manual intervention',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Where to See, Check, and Manage My Reminders?',
        contentList: [
          TextSpan(
            text: 'Your reminders are visible in your Profile Page (by clicking on the ',
          ),
          WidgetSpan(
            child: Icon(Icons.person, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' icon > Reminders Tab) and also in your timeline (accessible via the Home Page ',
          ),
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Icon(FontAwesomeIcons.house, size: 13, color: Colors.black87),
            ),
          ),
          TextSpan(
            text:
                ').\n\nIn your profile, reminders are displayed from newest to oldest based on their creation date. \n\nIn your timeline, they appear next to the day or days they are scheduled to remind you.\n\nTo view details about a specific reminder, simply tap on its card to display a modal containing all information about the reminder, as well as options to edit it',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'How to Create a Reminder?',
        contentList: [
          TextSpan(
            text: 'To create a reminder:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Tap the plus icon ',
          ),
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Icon(FontAwesomeIcons.plus, size: 13, color: Colors.black87),
            ),
          ),
          TextSpan(
            text: '\n\n\t\t■ Then click on the “Create a reminder” button.\n\n',
          ),
          TextSpan(
            text: '\t\t■ Enter the following information:\n\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ Title: Less than 45 characters.\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ Event or Date: Attach the reminder to an event or a specific date.\n',
          ),
          TextSpan(
            text:
                '${'       '}\t\t◆ Reminder Time: Specify when you want to be reminded (e.g., immediately, 10 minutes before, 1 hour before, 1 day before, etc.).\n',
          ),
          TextSpan(
            text:
                '${'       '}\t\t◆ Recurrence: Choose if the reminder should repeat daily, weekly, monthly, yearly, or not at all.\n',
          ),
          TextSpan(
            text: '\n\nNote:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                'If you attach a reminder to an event without recurrence, the recurrence option will not be available.\n\nHowever, if the event has a recurrence pattern or if the reminder is attached to a standalone date (which defaults can have recurrence).',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'How to Edit a Reminder?',
        contentList: [
          TextSpan(
            text: 'To make changes to a reminder:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Navigate to your Profile Page (by clicking on the ',
          ),
          WidgetSpan(
            child: Icon(Icons.person, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' icon)\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ Then click on the Reminder tab (just after the Event tab) or click on any reminder card wherever you see it.\n\n',
          ),
          TextSpan(
            text: '\t\t■ In the reminder modal, click on the “',
          ),
          WidgetSpan(
            child: Icon(Icons.edit, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' Edit” button located at the top right.\n\n',
          ),
          TextSpan(
            text: '\t\t■ On the edit page, you can modify:\n\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ Title\n',
          ),
          TextSpan(
            text:
                '${'       '}\t\t◆ Attached event: Change it to another event or attach it to a specific date and time.\n',
          ),
          TextSpan(
            text:
                '${'       '}\t\t◆ Trigger time: Specify when the reminder should alert you (e.g., immediately, 10 minutes before, 1 hour before, 1 day before, etc.).\n',
          ),
          TextSpan(
            text:
                '${'       '}\t\t◆ Recurrence: Choose if the reminder should repeat daily, weekly, monthly, yearly, or not at all.\n',
          ),
          TextSpan(
            text: '\t\t■ Confirm your changes by clicking the “',
          ),
          WidgetSpan(
            child: Icon(Icons.edit, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' Edit” button at the top right corner of the edit page.\n\n',
          ),
          TextSpan(
            text: 'Note:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                'Detaching a reminder from an event means it won’t appear in that event’s modal under the Reminders section, and it will no longer be associated with that event',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'How to Delete a Reminder?',
        contentList: [
          TextSpan(
            text: 'To delete a reminder:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Visit your Profile Page (by clicking on the ',
          ),
          WidgetSpan(
            child: Icon(Icons.person, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' icon)\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ Click on the Reminder tab (just after the Event tab) or click on any reminder card wherever you see it.\n\n',
          ),
          TextSpan(
            text: '\t\t■ In the reminder modal, click on the “',
          ),
          WidgetSpan(
            child: Icon(Icons.edit, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' Edit” button located at the top right.\n\n',
          ),
          TextSpan(
            text: '\t\t■ On the edit page, click on the delete icon or trash button “',
          ),
          WidgetSpan(
            child: Icon(Icons.delete, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: '” at the bottom right.\n\n',
          ),
          TextSpan(
            text: '\t\t■ Confirm the deletion by clicking on “Delete” — and voilà! Your reminder is deleted!\n\n',
          ),
          TextSpan(
            text: 'Note:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                'When you delete a reminder, it is removed entirely from our database, disappears from the event it was attached to, and vanishes from your Home Timeline and Profile > Reminder tab',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Who Can See My Reminders?',
        contentList: [
          TextSpan(
            text:
                'By default, reminders are private — only you can see them.\n\nEven if someone visits your profile or uses the search functionality, they won’t find or view any of your reminders.\n\n',
          ),
          TextSpan(
            text: 'Similarly, you cannot view other people\'s reminders.\n\n',
          ),
          TextSpan(
            text:
                'In upcoming versions, we plan to introduce enhanced reminders privacy options, allowing you to choose between default privacy settings or restrict access to specific individuals or groups',
          ),
        ],
      ),
      HelpItemContent(
        subHeader: 'Troubleshooting',
        contentList: [
          const TextSpan(
            text: 'Can’t View or Load Reminder Details:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\n\n\t\t■ First, check your internet connection. If the issue persists, you’ll be prompted to send a bug report, which helps us diagnose the problem. Typically, this issue occurs if the reminder you’re trying to access has been deleted just as you clicked on it.\n\n\n',
          ),
          const TextSpan(
            text: 'Can’t Create or Update a Reminder:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\n\n\t\t■ If you encounter an error, ensure all required fields are correctly filled (errors will be displayed before you confirm edits so you can correct them).\n\n\n',
          ),
          const TextSpan(
            text: 'Unexpected Reminder Behavior:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\n\n\t\t■ If a reminder you created changes unexpectedly, it may be due to changes in the event it’s attached to. For example, if the event\'s date is changed, your reminder will automatically adjust to reflect the new schedule without your intervention.\n\n\n',
          ),
          const TextSpan(
            text: 'Can’t Load All Reminders:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\n\n\t\t■ If you encounter this issue, first close the reminder modal and click on the reminder card again.\n\n\n',
          ),
          const TextSpan(
            text: 'Error in Reminder Content:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: '\n\n\t\t■ If you notice an error in your reminder, click on the edit button (',
          ),
          const WidgetSpan(
            child: Icon(Icons.edit, size: 16, color: Colors.black87),
          ),
          const TextSpan(
            text: ' located at the top right of the reminder modal) to make corrections.\n\n\n',
          ),
          ...troubleshootingNext,
        ],
      )
    ],
  ),
  HelpItem(
    title: 'Stories',
    icon: Icon(FontAwesomeIcons.heart, color: Colors.white, size: 22.sp),
    content: [
      const HelpItemContent(
        subHeader: 'What are Stories?',
        contentList: [
          TextSpan(
            text:
                'Stories are text, video, or image/GIF content that you or others can share on your profile to update followers about daily moments, project progressions, and more\n\n',
          ),
          TextSpan(
            text: 'Stories have a 24-hour limit, after which they disappear\n\n',
          ),
          TextSpan(
            text: 'They are primarily intended for your followers but can also be viewed on anyone’s profile',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Where Can I See Stories?',
        contentList: [
          TextSpan(
            text: 'You can view stories in two main places:\n\n',
          ),
          TextSpan(text: '\t\t■ Stories Page:', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(
            text: '\n\nClick on the ',
          ),
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(bottom: 2, right: 1, left: 1),
              child: Icon(FontAwesomeIcons.circleNotch, size: 12, color: Colors.black87),
            ),
          ),
          TextSpan(
            text:
                ' Stories Icon to see all stories from the people you follow. In the Stories tab, stories are displayed starting with the most recent one posted among all the people you follow\n\n',
          ),
          TextSpan(text: '\t\t■ Profile Pages: ', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(
            text:
                '\n\nStories appear next to a user\'s profile picture in a small red circle\n\nClick on this red circle on your or someone else’s profile to view their current stories\n\nTo view all of someone’s or your own stories, tap on the story card or on the red circle next to the Profile picture to open a fullscreen Stories Viewer that displays all non-expired stories',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'How to Create a Story?',
        contentList: [
          TextSpan(
            text: 'To create a story:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Tap the plus icon ',
          ),
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Icon(FontAwesomeIcons.plus, size: 13, color: Colors.black87),
            ),
          ),
          TextSpan(
            text: ' and select “Create a story”\n\n',
          ),
          TextSpan(
            text: '\t\t■ Choose the story type: text, image/GIF, or video\n\n',
          ),
          TextSpan(
            text: '\t\t■ Optionally, attach an event to specify that the story relates to a particular event\n\n',
          ),
          TextSpan(
            text: '\t\t■ Add content:\n\n',
          ),
          TextSpan(
            text:
                '${'       '}\t\t◆ For text stories: Write up to 500 characters and customize with fonts, background colors, emojis, etc\n',
          ),
          TextSpan(
            text:
                '${'       '}\t\t◆ For video, image, or GIF stories: Add a caption (up to 120 characters) to provide more context',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Can I Edit a Published Story?',
        contentList: [
          TextSpan(
            text:
                'No, once a story is published, it cannot be edited.\n\nYou would need to delete it and create a new one if changes are necessary',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Who Can See My Stories?',
        contentList: [
          TextSpan(
            text:
                'Anyone who visits your profile can view your stories.\n\nYour followers can also see your story updates in their ',
          ),
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Icon(FontAwesomeIcons.circleNotch, size: 12, color: Colors.black87),
            ),
          ),
          TextSpan(
            text: ' Stories Page.\n\n',
          ),
          TextSpan(
            text:
                'Likewise, you can view anyone’s stories on their Profile page by clicking the small circle next to their profile picture.\n\nIf the circle isn’t visible, it means the person hasn’t shared any stories or their stories have expired\n\n',
          ),
          TextSpan(
            text:
                'If you want real-time updates and notifications about someone’s story activity, follow them to see their updates in your ',
          ),
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Icon(FontAwesomeIcons.circleNotch, size: 12, color: Colors.black87),
            ),
          ),
          TextSpan(
            text: ' Stories Page (by clicking the Stories Icon).\n\n',
          ),
        ],
      ),
      HelpItemContent(
        subHeader: 'Troubleshooting',
        contentList: [
          const TextSpan(
            text: 'Stories Page is Blank:\n\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: '\t\t■ First, check your network connection 📶\n\n',
          ),
          const TextSpan(
            text: '\t\t■ Ensure you follow at least 1 or 2 people who have recently posted stories.\n\n',
          ),
          const TextSpan(
            text:
                '\t\t■ If the issue persists, on the Stories page, pull down the list to refresh and reload all stories 🔄\n\n\n',
          ),
          const TextSpan(
            text: 'Cannot Create a Story:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: '\n\n\t\t■ For text stories, ensure you enter at least one character or emoji\n\n',
          ),
          const TextSpan(
            text:
                '\t\t■ For video or image stories, verify that your media is correctly uploaded and avoid using overly large files 📸\n\n\n',
          ),
          const TextSpan(
            text: 'Can’t Load or View Stories:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: '\n\n\t\t■ First, check your network connection 📶\n\n',
          ),
          const TextSpan(
            text:
                '\t\t■ Wait for any loading indicators, especially for image or video stories, which may take longer to load due to their size ⏳\n\n\n',
          ),
          const TextSpan(
            text: 'Error While Making a Screenshot of a Story:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: '\n\n\t\t■ If you encounter issues with taking a screenshot:\n\n',
          ),
          const TextSpan(
            text: '${'       '}\t\t◆ Double-check your Gallery or ',
          ),
          const WidgetSpan(
            child: Icon(FontAwesomeIcons.folder, size: 13, color: Colors.black87),
          ),
          const TextSpan(
            text: ' Wesh Storage Folder > Wesh Screenshots folder to see if the screenshot was taken correctly\n\n',
          ),
          const TextSpan(
            text:
                '${'       '}\t\t◆ Ensure there are no apps or system restrictions preventing you from taking screenshots 📱\n\n\n',
          ),
          const TextSpan(
            text: 'Can’t Share a Story:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: '\n\n\t\t■ If you\'re unable to share your stories:\n\n',
          ),
          const TextSpan(
            text: '${'       '}\t\t◆ Verify there are no app or system restrictions on taking screenshots 📵\n\n',
          ),
          const TextSpan(
            text: '${'       '}\t\t◆ Ensure that your story has fully loaded and is available for sharing ✅\n\n',
          ),
          ...troubleshootingNext,
        ],
      )
    ],
  ),
  HelpItem(
    title: 'Forevers',
    icon: Icon(FontAwesomeIcons.circleNotch, color: Colors.white, size: 20.sp),
    content: [
      const HelpItemContent(
        subHeader: 'What are Forevers?',
        contentList: [
          TextSpan(
            text: 'Forevers allow you to preserve and save your stories beyond their 24-hour expiration limit ⏳\n\n',
          ),
          TextSpan(
            text:
                'They are particularly useful if you want certain stories to be viewed multiple times without having to create new ones each time\n\n',
          ),
          TextSpan(
            text:
                'You can view your Forevers on your Profile page, specifically under the Forevers tab located after the event and reminder tabs',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'How to Create a Forever?',
        contentList: [
          TextSpan(
            text: 'To create a Forever:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Go to your Profile Page (by clicking on the ',
          ),
          WidgetSpan(
            child: Icon(Icons.person, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' icon)\n\n',
          ),
          TextSpan(
            text: '\t\t■ Click on the Forevers tab (located after the event and reminder tabs)\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ Click on “Create one here” if you haven\'t created any Forevers yet, or simply click on the “Create a Forever” button if you have already created at least one\n\n',
          ),
          TextSpan(
            text: '\t\t■ You will be prompted to add:\n\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ A title for your Forever\n\n',
          ),
          TextSpan(
            text:
                '${'       '}\t\t◆ At least one story: Forevers function as collections of stories, so you must add at least one story by clicking on the “+ Add” button\n\n',
          ),
          TextSpan(text: 'Note: \n', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(
            text:
                'Clicking on the “+ Add” button will display a page with all your past and current stories\n\nYou can select and add as many stories as you want to your Forever',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'How to Edit a Forever?',
        contentList: [
          TextSpan(
            text: 'To edit a Forever:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Navigate to your Profile Page (by clicking on the ',
          ),
          WidgetSpan(
            child: Icon(Icons.person, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' icon)\n\n',
          ),
          TextSpan(
            text: '\t\t■ Click on the Forevers tab (located after the event and reminder tabs)\n\n',
          ),
          TextSpan(
            text: '\t\t■ Click on the edit icon “',
          ),
          WidgetSpan(
            child: Icon(Icons.edit, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: '” at the end of the Forever card you want to edit or update\n\n',
          ),
          TextSpan(
            text: '\t\t■ You can make changes to:\n\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ Its title\n',
          ),
          TextSpan(
            text:
                '${'       '}\t\t◆ The stories it contains: add or remove specific stories you want to include or exclude\n\n',
          ),
          TextSpan(
            text: '\t\t■ Validate your changes by clicking "',
          ),
          WidgetSpan(
            child: Icon(Icons.edit, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' Edit” on the top right corner of the edit page',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'How to Delete a Forever?',
        contentList: [
          TextSpan(
            text: 'To delete a Forever:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Go to your Profile Page (by clicking on the ',
          ),
          WidgetSpan(
            child: Icon(Icons.person, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' icon)\n\n',
          ),
          TextSpan(
            text: '\t\t■ Click on the Forevers tab (located after the event and reminder tabs)\n\n',
          ),
          TextSpan(
            text: '\t\t■ Click on the edit icon “',
          ),
          WidgetSpan(
            child: Icon(Icons.edit, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: '” at the end of the Forever card you want to edit or update\n\n',
          ),
          TextSpan(
            text: '\t\t■ On the edit page, locate and click on the delete icon or trash button “',
          ),
          WidgetSpan(
            child: Icon(Icons.delete_rounded, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: '” at the bottom right of the page\n\n',
          ),
          TextSpan(
            text: '\t\t■ Confirm the deletion by clicking “Delete”\n\n',
          ),
          TextSpan(
            text: 'Note:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                'Deleting a Forever will only remove the Forever itself. The stories contained within it (both past and non-expired) will not be deleted',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Are Forevers Private?',
        contentList: [
          TextSpan(
            text: 'No, Forevers are public and visible to anyone who visits your Profile Page\n\n',
          ),
          TextSpan(
            text:
                'We plan to enhance privacy features for Forevers in upcoming versions, allowing you to restrict access to certain individuals or groups',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Can Two Forevers Contain the Same Story?',
        contentList: [
          TextSpan(
            text:
                'Yes! Forevers function like collections, so multiple Forevers can contain the same story simultaneously',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Where Can I See Someone Else\'s Forevers?',
        contentList: [
          TextSpan(
            text:
                'You can view someone else\'s Forevers by visiting their Profile Page and clicking on the Forevers tab (located after the event and reminder tabs)',
          ),
        ],
      ),
      HelpItemContent(
        subHeader: 'Troubleshooting',
        contentList: [
          const TextSpan(
            text: 'Can’t See My Forever on My Profile:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: '\n\n\t\t■ First, check your network connection 🌐\n\n',
          ),
          const TextSpan(
            text: '\t\t■ Ensure you are searching for the Forever by its correct title 🔍\n\n',
          ),
          const TextSpan(
            text:
                '\t\t■ Note: On the Profile Page, Forevers are displayed based on their modification date, with the most recently modified ones appearing first\n\n',
          ),
          const TextSpan(
            text: '\nCan’t See or Select My Story While Adding to a Forever:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: '\n\n\t\t■ This may occur if the story you want to add is already included in your Forevers 📚\n\n',
          ),
          const TextSpan(
            text: '\t\t■ Ensure it is not already selected ✅\n\n',
          ),
          const TextSpan(
            text: '\nMy Forever Displays Stories in a Strange Order:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: '\n\n\t\t■ Forevers display stories in the order you defined when creating them 🗂️\n\n',
          ),
          const TextSpan(
            text: '\t\t■ You can edit the order on the Forever\'s edit page by clicking the edit icon "',
          ),
          const WidgetSpan(
            child: Icon(Icons.edit, size: 16, color: Colors.black87),
          ),
          const TextSpan(
            text: '” at the end of the Forever card\n\n',
          ),
          ...troubleshootingNext,
        ],
      )
    ],
  ),
  HelpItem(
    title: 'Search',
    icon: Icon(Icons.search, color: Colors.white, size: 24.sp),
    content: [
      const HelpItemContent(
        subHeader: 'More on the Search Functionality?',
        contentList: [
          TextSpan(
            text:
                'As the name suggests, the search functionality on Wesh helps you find events and people easily\n\nYou can also apply filters to refine your search based on specific dates 📅\n\n',
          ),
          TextSpan(
            text:
                'The search functionality works by matching your search term with event names for events and with usernames or names for people',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'About Search Filters',
        contentList: [
          TextSpan(
            text: 'Search Filters are designed to give you more precise search results:\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ Event Filters: When applied, these filters show events happening during the specified period.\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ User Filters: These filters display people whose birthdays fall within the selected timeframe.\n\n',
          ),
          TextSpan(
            text:
                'Filters range from specific days to months, allowing you to broaden or narrow your search results by applying multiple filters',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'How to Apply Filters',
        contentList: [
          TextSpan(
            text: 'To apply filters to your search:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Click on the date button ',
          ),
          WidgetSpan(
            child: Icon(Icons.calendar_month_sharp, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' next to the search bar; the icon will darken\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ Select the filter you want to apply—whether it\'s a specific day or a range of months. The selected filters will turn red\n\n',
          ),
          TextSpan(
            text: 'Note:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'When a filter is applied, the date button ',
          ),
          WidgetSpan(
            child: Icon(Icons.calendar_month_sharp, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' will display a small red circle to indicate that one or more filters are active',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'How to Reset Filters',
        contentList: [
          TextSpan(
            text: 'To reset filters and return to a "no-filter-selected" state:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Click on the ',
          ),
          WidgetSpan(
            child: Icon(Icons.close, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' button at the beginning of the row displaying all filters',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'How to Remove Filter',
        contentList: [
          TextSpan(
            text: 'To remove all applied filters:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Click on the date button ',
          ),
          WidgetSpan(
            child: Icon(Icons.calendar_month_sharp, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' next to the search bar: the icon will turn grey',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'What Can’t Be Found Using the Search Functionality?',
        contentList: [
          TextSpan(
            text:
                'The search functionality does not include reminders, stories, Forevers, settings, chats, or notifications\n\nIt is solely for finding events and profiles',
          ),
        ],
      ),
      HelpItemContent(
        subHeader: 'Troubleshooting',
        contentList: [
          const TextSpan(
            text: 'Can’t Find Someone’s Profile:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: '\n\n\t\t■ First, check your network connection 📡\n\n',
          ),
          const TextSpan(
            text: '\t\t■ Ensure you\'ve entered the correct name or username\n\n',
          ),
          const TextSpan(
            text: '\t\t■ Check if any filters are applied and ensure they are appropriate\n\n\n',
          ),
          const TextSpan(
            text: '\nCan’t Find a Particular Event:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: '\n\n\t\t■ Verify your network connection\n\n',
          ),
          const TextSpan(
            text: '\t\t■ Ensure the event name matches your search term 🔍\n\n',
          ),
          const TextSpan(
            text: '\t\t■ Check applied filters to ensure they are correct and relevant\n\n\n',
          ),
          const TextSpan(
            text: '\nGetting Events Instead of Profiles (or Vice-Versa):',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\n\n\t\t■ Make sure you\'re on the correct tab (People or Events) corresponding to what you\'re searching for. Profiles are under "People" and events are under "Events"\n\n\n',
          ),
          const TextSpan(
            text: '\nFilters Aren’t Working Correctly:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: '\n\n\t\t■ Ensure the date button ',
          ),
          const WidgetSpan(
            child: Icon(Icons.calendar_month_sharp, size: 16, color: Colors.black87),
          ),
          const TextSpan(
            text: ' shows a red circle when filters are applied 🔴\n\n',
          ),
          const TextSpan(
            text: '\t\t■ Double-check that the selected filters match your search criteria precisely\n\n',
          ),
          ...troubleshootingNext,
        ],
      ),
    ],
  ),
  HelpItem(
    title: 'Chat',
    icon: Icon(FontAwesomeIcons.message, color: Colors.white, size: 20.sp),
    content: [
      const HelpItemContent(
        subHeader: 'About Chats',
        contentList: [
          TextSpan(
            text:
                'Chats on Wesh allow you to exchange messages and information with any user in real-time\n\nYou can send various types of messages including text, images, videos, emojis, GIFs, voice notes, money, gifts, replies to events or stories, and even special birthday wishes 🎉',
          ),
        ],
      ),
      HelpItemContent(
        subHeader: 'Who Can I Chat With?',
        contentList: [
          const TextSpan(
            text:
                'There are no limits or restrictions on who you can chat with, as long as the person has a Wesh account. \n\nAnyone who wishes to chat with you can initiate a conversation, and it will appear in your Chats Page ',
          ),
          const WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(bottom: 2, right: 1, left: 1),
              child: Icon(FontAwesomeIcons.message, size: 12, color: Colors.black87),
            ),
          ),
          const TextSpan(
            text:
                ' \n\n To start a conversation with someone, simply go to their profile and click on the Message Icon button “',
          ),
          WidgetSpan(
            child: Icon(Icons.chat_bubble_rounded, size: 14, color: Colors.grey.shade600),
          ),
          const TextSpan(
            text: '” below their profile information',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Where to Find Chats?',
        contentList: [
          TextSpan(
            text: 'All your chats are accessible on your Chats Page, accessed by clicking the Chat icon ',
          ),
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(bottom: 2, right: 1, left: 1),
              child: Icon(FontAwesomeIcons.message, size: 12, color: Colors.black87),
            ),
          ),
          TextSpan(
            text:
                '\n\nDeleted chats and cleared conversations will not be visible\n\nChats are displayed from the latest to the oldest',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'More on Read Receipts',
        contentList: [
          TextSpan(
            text:
                'When you send a message, you can track its read receipts to see if your message has been read or seen. Here\'s how it works:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Clock Icon ',
          ),
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(bottom: 2, right: 1, left: 1),
              child: Icon(FontAwesomeIcons.clock, size: 12, color: Colors.black87),
            ),
          ),
          TextSpan(
            text: ' : Your message is being sent and is pending.\n\n',
          ),
          TextSpan(
            text: '\t\t■ Grey Check Icon ',
          ),
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(bottom: 2, right: 1, left: 1),
              child: Icon(FontAwesomeIcons.check, size: 12, color: Colors.black87),
            ),
          ),
          TextSpan(
            text: ' : Your message has been sent but not yet read.\n\n',
          ),
          TextSpan(
            text: '\t\t■ Grey Double-Check Icon ',
          ),
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(bottom: 2, right: 1, left: 1),
              child: Icon(FontAwesomeIcons.checkDouble, size: 12, color: Colors.black87),
            ),
          ),
          TextSpan(
            text: ' : Your message has been sent, seen, but not read.\n\n',
          ),
          TextSpan(
            text: '\t\t■ Red Double-Check Icon ',
          ),
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(bottom: 2, right: 1, left: 1),
              child: Icon(FontAwesomeIcons.checkDouble, size: 12, color: kSecondColor),
            ),
          ),
          TextSpan(
            text: ' : Your message has been sent, seen, and read',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Copy or Share a Message Content',
        contentList: [
          TextSpan(
            text:
                'For each message, Wesh allows you to copy text messages or share media messages (videos, images, GIFs, voice notes, etc.) to other apps\nTo do so:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Press and hold the message you want to copy or share.\n\n',
          ),
          TextSpan(
            text: '\t\t■ In the new app bar that appears, select the copy icon button “',
          ),
          WidgetSpan(
            child: Icon(Icons.copy, size: 14, color: Colors.black87),
          ),
          TextSpan(
            text: '” to copy text content or the share icon button “',
          ),
          WidgetSpan(
            child: Icon(Icons.share, size: 14, color: Colors.black87),
          ),
          TextSpan(
            text: '” to share media content to other apps',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Reply to a Message',
        contentList: [
          TextSpan(
            text:
                'Replying to a message allows you to highlight a specific message within a conversation. To reply to a message:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Swipe right on the message you wish to reply to.\n\n',
          ),
          TextSpan(
            text: '\t\t■ Alternatively, press and hold the message, then select the left arrow icon “',
          ),
          WidgetSpan(
            child: Icon(Icons.reply, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: '” in the top app bar\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ Once done, the message you are replying to will appear at the top of the chat text field, ready for your response\n\n\n',
          ),
          TextSpan(
            text: 'Note:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'You can only reply to one message at a time\n\nTo remove a reply-to-message, click the "',
          ),
          WidgetSpan(
            child: Icon(Icons.close, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text:
                '" button in the top right corner of the chat text field\n\nWhen a message has a reply attached to it, click on the "reply-message" box at the top of the message to be redirected to the original message in the conversation\n\nIf the message no longer exists, you won’t be redirected',
          ),
        ],
      ),
      HelpItemContent(
        subHeader: 'How to Forward a Message',
        contentList: [
          const TextSpan(
            text:
                'Forwarding a message is useful if you want to share a specific message with another person or as a new story. You can forward any message displayed in the conversation feed:\n\n',
          ),
          const TextSpan(
            text: '\t\t■ Press and hold the message you want to forward\n\n',
          ),
          const TextSpan(
            text: '\t\t■ Select the right arrow icon "',
          ),
          WidgetSpan(
            child: Transform.scale(scaleX: -1, child: const Icon(Icons.reply, size: 16, color: Colors.black87)),
          ),
          const TextSpan(
            text: '" in the top app bar\n\n',
          ),
          const TextSpan(
            text: '\t\t■ On the Forward page, choose where you want to forward your message:\n\n',
          ),
          const TextSpan(
            text: '${'       '}\t\t◆ To your stories\n\n',
          ),
          const TextSpan(
            text:
                '${'       '}\t\t◆ To someone else: Select the recipient from Recent Chats or search by name or username in the Search Bar\n\n',
          ),
          const TextSpan(
            text:
                '\t\t■ Click the “Forward” button next to your story or the recipient’s profile you wish to forward to\n\n\n',
          ),
          const TextSpan(
            text: 'Note:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: 'You can forward multiple messages simultaneously:\n\n',
          ),
          const TextSpan(
            text: '\t\t■ Forwarding to your stories will create multiple stories, one for each forwarded message\n\n',
          ),
          const TextSpan(
            text:
                '\t\t■ Forwarding to someone else will create multiple messages, one new message for each forwarded message',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'How to Reply to an Event or Story',
        contentList: [
          TextSpan(
            text:
                'You can reply to someone’s event or story. Your reply will appear as a message with a preview of the event or story you’re replying to.\n\n',
          ),
          TextSpan(text: 'To reply to an event:\n\n', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(
            text: '\t\t■ Click on the event you want to reply to.\n\n',
          ),
          TextSpan(
            text: '\t\t■ In the event modal, click the “',
          ),
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(bottom: 2, right: 1, left: 1),
              child: Icon(FontAwesomeIcons.message, size: 12, color: Colors.black87),
            ),
          ),
          TextSpan(
            text: ' Message” button next to the “Reminders” button\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ You’ll be directed to a chat with the event owner, with the message text field pre-attached with the event preview\n\n',
          ),
          TextSpan(
            text: '\t\t■ Write your message and send.\n\n\n',
          ),
          TextSpan(text: 'To reply to a story:\n\n', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(
            text: '\t\t■ Click on the story you want to reply to.\n\n',
          ),
          TextSpan(
            text: '\t\t■ Click the three dots icon "',
          ),
          WidgetSpan(
            child: Icon(Icons.more_vert, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: '" in the top right corner of the story viewer\n\n',
          ),
          TextSpan(
            text: '\t\t■ In the story options modal, click the “Reply” button\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ You’ll be directed to a chat with the story owner, with the message text field pre-attached with the story preview\n\n',
          ),
          TextSpan(
            text: '\t\t■ Write your message and send\n\n\n',
          ),
          TextSpan(
            text: 'Note:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'You cannot reply to your own event or story',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'How to Delete a Message',
        contentList: [
          TextSpan(
            text: 'To delete a message:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Press and hold the message or messages you want to delete.\n\n',
          ),
          TextSpan(
            text: '\t\t■ In the top app bar, tap the trash icon "',
          ),
          WidgetSpan(
            child: Icon(Icons.delete, size: 15, color: Colors.black87),
          ),
          TextSpan(
            text: '"\n\n',
          ),
          TextSpan(
            text: '\t\t■ Confirm that you want to delete the selected message(s)\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ Optionally, select to delete stored files (videos, images, GIFs, voicenotes, etc.) associated with the message(s)\n\n',
          ),
          TextSpan(
            text: '\t\t■ Tap “Delete” to confirm\n\n\n',
          ),
          TextSpan(
            text: 'Important:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                'When you delete one or multiple messages, only your messages will disappear from our database\n\nFor media types (videos, images, GIFs, voicenotes, etc.), the associated files stored in our database will also be deleted\n\nThe person you were chatting with will no longer see your messages or associated files, but they will still have these files stored in their device\'s Wesh folder',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Images, Videos, Songs, and GIFs',
        contentList: [
          TextSpan(
            text: 'Wesh allows you to send images, videos, songs, and GIFs in your conversations.\n\n',
          ),
          TextSpan(
            text: 'To send media:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Enter any chat by tapping on it\n\n',
          ),
          TextSpan(
            text: '\t\t■ At the bottom of the Chat page, tap the paper clip icon "',
          ),
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(bottom: 2, right: 1, left: 1),
              child: Icon(FontAwesomeIcons.paperclip, size: 12, color: Colors.black87),
            ),
          ),
          TextSpan(
            text: '"\n\n',
          ),
          TextSpan(
            text: '\t\t■ Choose the type of media:\n\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ For Image: tap the camera "',
          ),
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(bottom: 2, right: 1, left: 1),
              child: Icon(FontAwesomeIcons.camera, size: 12, color: Colors.black87),
            ),
          ),
          TextSpan(
            text: '" or image "',
          ),
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(bottom: 2, right: 1, left: 1),
              child: Icon(FontAwesomeIcons.image, size: 12, color: Colors.black87),
            ),
          ),
          TextSpan(
            text: '"\n\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ For Video: tap Video "',
          ),
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(bottom: 2, right: 1, left: 1),
              child: Icon(FontAwesomeIcons.play, size: 12, color: Colors.black87),
            ),
          ),
          TextSpan(
            text: '"\n\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ For Song: tap Song "',
          ),
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(bottom: 2, right: 1, left: 1),
              child: Icon(FontAwesomeIcons.itunesNote, size: 12, color: Colors.black87),
            ),
          ),
          TextSpan(
            text: '"\n\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ For GIF: tap Image "',
          ),
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(bottom: 2, right: 1, left: 1),
              child: Icon(FontAwesomeIcons.image, size: 12, color: Colors.black87),
            ),
          ),
          TextSpan(
            text: '"\n\n',
          ),
          TextSpan(
            text: '\t\t■ Select the media you want to send\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ You\'ll be redirected to the "Preview-before-send" page where you can add a description, attach an event, preview, and make changes\n\n',
          ),
          TextSpan(
            text: '\t\t■ Then tap the send button\n\n\n',
          ),
          TextSpan(
            text: 'Note:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                'Ensure media sizes are small (we recommend a maximum of 5MB for images, a maximum of 100MB for videos) for faster upload times',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Voicenote Messages',
        contentList: [
          TextSpan(
            text:
                'Voicenote messages have gained popularity for their efficiency and their ability to foster a more natural and human connection in chats\n\nWesh has integrated voicenotes to enhance interaction, allowing for more expressive communication that captures nuances beyond what text can convey\n\n',
          ),
          TextSpan(
            text: 'To send a voicenote:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Enter any chat by tapping on it\n\n',
          ),
          TextSpan(
            text: '\t\t■ At the bottom of the Chat page, tap the microphone icon "',
          ),
          WidgetSpan(
            child: Icon(Icons.mic, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: '" and start recording your message\n\n',
          ),
          TextSpan(
            text: '\t\t■ When done, tap send\n\n',
          ),
          TextSpan(
            text: '\t\t■ If you\'re unsatisfied or wish to redo, tap the trash icon "',
          ),
          WidgetSpan(
            child: Icon(Icons.delete, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: '"\n\n',
          ),
          TextSpan(
            text: 'Note:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'If prompted, grant Wesh permission to access your device\'s microphone for flawless recording',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Chat Notifications',
        contentList: [
          TextSpan(
            text:
                'When you receive a new message, you’ll get an instant notification 🔔 with the message content, sender\'s name, and profile picture\n\n',
          ),
          TextSpan(
            text: 'Tapping the notification redirects you to the Chat Page to view the conversation\n\n',
          ),
          TextSpan(
            text:
                'Notifications are customized based on message type (video, image, voicenote, GIF, etc.), making it easy to identify and decide whether to view immediately or later\n\n\n',
          ),
          TextSpan(
            text: 'Note:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                'New chat notifications won’t appear if you\'re already viewing your Chats list or inside a specific chat\n\n',
          ),
          TextSpan(
            text: 'Unread messages in the Chats list are highlighted and pushed to the top\n\n',
          ),
          TextSpan(
            text:
                'In a chat, new messages appear at the bottom. An icon indicates new messages if you\'re not at the bottom of the chat feed\n\n',
          ),
          TextSpan(
            text:
                'You can manage Chat notifications in Notification Settings (Profile Page > Settings > Notifications > Disable “Chat notifications”)',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Clearing a Conversation',
        contentList: [
          TextSpan(
            text: 'If you want to delete an entire chat:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Open the chat you want to clear by clicking on it\n\n',
          ),
          TextSpan(
            text: '\t\t■ Tap the three dots icon "',
          ),
          WidgetSpan(
            child: Icon(Icons.more_vert, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: '" in the top right corner of the Chat Page\n\n',
          ),
          TextSpan(
            text: '\t\t■ Select "Clear"\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ Confirm that you want to delete the entire chat. You can also choose to delete all stored files (videos, images, GIFs, voicenotes, etc.) associated with this chat by checking that box\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ Click "Clear," and voilà, all messages inside the chat will be deleted along with the chat itself\n\n\n',
          ),
          TextSpan(
            text: 'Important:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'When you clear or delete a conversation:\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ All your messages in this conversation will be deleted from our database. If it\'s a media type message (video, image, GIF, voicenote, etc.), the associated file stored in our database will also be deleted\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ The chat will disappear from your Chats list page as it will no longer contain any messages.\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ The other person you were chatting with will no longer see your messages and the files associated with the chat, but they will still see their own messages and the chat itself because the chat is only deleted on your side\n\n\n',
          ),
          TextSpan(
            text: 'Warning:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                'The other person you were chatting with can still see the files associated with the chat inside their device storage (Wesh folder) because Wesh stores files on devices for quick access in the future',
          ),
        ],
      ),
      HelpItemContent(
        subHeader: 'Troubleshooting',
        contentList: [
          const TextSpan(
            text: 'Can’t record a voicenote message:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\n\n\t\t■ Ensure that you\'ve granted Wesh permission to use your microphone. If not, go to your Device Settings > Apps > Wesh > Grant Microphone Access and relaunch the app 🎙️\n\n',
          ),
          const TextSpan(
            text: '\nCan’t send media to someone:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\n\n\t\t■ Ensure that you\'ve granted Wesh permission to access your files. If not, go to your Device Settings > Apps > Wesh > Grant Files Access and relaunch the app 🖼️\n\n',
          ),
          const TextSpan(
            text: '\nNo messages inside a chat:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\n\n\t\t■ Check your network connections 📶\n\n\t\t■ Ensure that at least one message has been sent in this conversation, either by you or the other person you\'re chatting with\n\n',
          ),
          const TextSpan(
            text: '\nCan’t send money to someone:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\n\n\t\t■ We currently do not support money transfers in all countries. If you don’t see an option to send money in your country, it means that we don\'t support that country yet. We are working to make this available everywhere, so stay tuned for updates 💸\n\n',
          ),
          const TextSpan(
            text: '\nCan’t see older Video, Image, Voicenote, GIF, or song, and it displays an error:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\n\n\t\t■ You can no longer view messages containing these types of media if they have been moved or deleted from the Wesh folder on your device. If it\'s not your message, you can request the sender to resend it\n\n',
          ),
          const TextSpan(
            text: '\nCan’t hear Video, Voicenote, or song message:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\n\n\t\t■ Turn up your device volume 🔊\n\n\t\t■ Ensure your phone is not in "Do Not Disturb" mode and that the volume is high\n\n\t\t■ Ask the sender to check if the Video, Voicenote, or song is not muted by default\n\n',
          ),
          const TextSpan(
            text: '\nCan’t download Image, Video, Voicenote, Song, or GIF message:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\n\n\t\t■ Check your network connections 📶\n\n\t\t■ It\'s possible that the person who sent the message has deleted it, and it no longer exists on our servers. You can request them to resend the message\n\n',
          ),
          const TextSpan(
            text: '\nNot receiving new message notifications:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\n\n\t\t■ Ensure that Chat notifications are enabled in your Notification Settings (Profile page > Settings > Notifications > "Chat notifications") 🔔\n\n\t\t■ If enabled, check your device settings to make sure "Do Not Disturb" is disabled and that Wesh is allowed to send notifications (Device Settings > Apps > Wesh > Enable Notifications)\n\n',
          ),
          ...troubleshootingNext
        ],
      ),
    ],
  ),
  HelpItem(
    title: 'Notifications',
    icon: Icon(Icons.notifications_rounded, color: Colors.white, size: 25.sp),
    content: [
      const HelpItemContent(
        subHeader: 'More on Notifications',
        contentList: [
          TextSpan(
            text: 'Notifications keep you updated and alerted about what\'s happening or will happen 📲\n\n',
          ),
          TextSpan(
            text:
                'In addition to notifications based on your activity, you\'ll also receive notifications from people you follow, as well as from the Wesh app (settings, updates, recommendations, suggestions, etc.)\n\n',
          ),
          TextSpan(
            text:
                'Based on your preferences, you can disable certain types of notifications, although all are enabled by default',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'What Notifications Can I Receive?',
        contentList: [
          TextSpan(
            text:
                'Most of the time, you\'ll receive notifications based on your activity and the activities of people you follow\nNotifications can include:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Events: New events, updates, and when they start\n\n',
          ),
          TextSpan(
            text: '\t\t■ Reminders: When reminders you\'ve set are triggered\n\n',
          ),
          TextSpan(
            text: '\t\t■ Chats: When you receive a new message\n\n',
          ),
          TextSpan(
            text: '\t\t■ Stories: When someone you follow shares a new story\n\n',
          ),
          TextSpan(
            text: '\t\t■ More: App settings and updates, Wesh recommendations and suggestions, etc\n\n\n',
          ),
          TextSpan(
            text: 'Note:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                'Notifications are tailored based on your interests and the personal information you share with us, providing a more personalized experience',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'What Happens When I Click on a Wesh Notification?',
        contentList: [
          TextSpan(
            text:
                'Depending on the type of notification you receive, clicking on it will redirect you to the appropriate page:\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ Event-related notification: Opens the Wesh app and shows you the event details in the event modal\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ Reminder-related notification: Opens the Wesh app and displays the reminder details in the reminder modal\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ Chat or new message related notification: Opens the Wesh app and displays the chat feed along with the new message(s) received\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ Story-related notification: Opens the Wesh app and shows the story viewer containing the new story\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ App setting related notification: Opens the Wesh app and displays the corresponding settings page',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Disable All or Specific Types of Notifications',
        contentList: [
          TextSpan(
            text:
                'You can disable certain or all notifications from the Wesh app. To do this, navigate to your Notification Settings Page:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Go to your Profile page > Settings > Notifications\n\n',
          ),
          TextSpan(
            text: '\t\t■ Disable notifications by toggling off the types you no longer wish to receive\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ Save your changes by clicking the “Save” button in the top right corner of the Notification Settings Page\n\n\n',
          ),
          TextSpan(
            text: 'Alternatively, adjust settings in your device:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Go to Device Settings > Apps > Wesh > Notifications\n\n',
          ),
          TextSpan(
            text: '\t\t■ Or Use “Do Not Disturb” mode on your device to temporarily disable notifications',
          ),
        ],
      ),
      HelpItemContent(
        subHeader: 'Troubleshooting',
        contentList: [
          const TextSpan(
            text: 'Can’t Receive Notifications:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\n\n\t\t■ Ensure the corresponding notification type is enabled in your Notification Settings Page (Profile page > Settings > Notifications)\n\n',
          ),
          const TextSpan(
            text: '\t\t■ Check your device settings to disable “Do Not Disturb” mode\n\n',
          ),
          const TextSpan(
            text:
                '\t\t■ And ensure Wesh is allowed to send notifications (Device Settings > Apps > Wesh > Enable Notifications)\n\n',
          ),
          const TextSpan(
            text: '\nStill Receiving Notifications Even After Disabling:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\n\n\t\t■ Confirm that the notification type you’re still receiving is disabled in your Notification Settings Page (Profile page > Settings > Notifications)\n\n',
          ),
          ...troubleshootingNext,
        ],
      ),
    ],
  ),
  HelpItem(
    title: 'Subscriptions',
    icon: Icon(FontAwesomeIcons.plus, color: Colors.white, size: 20.sp),
    content: [
      const HelpItemContent(
        subHeader: 'What are Subscriptions?',
        contentList: [
          TextSpan(
            text:
                'Subscriptions refer to the act of following or being followed by people\n\nWhen you follow someone on Wesh, you subscribe to their public activities\n\nThis means you\'ll receive notifications when they share, create, or update events, stories, and more\n\n',
          ),
          TextSpan(
            text:
                'This system of following people keeps you connected with those you care about most—whether they\'re family, friends, companies, celebrities, or anyone else you have a direct or indirect interest in',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'How to Follow or Unfollow Someone?',
        contentList: [
          TextSpan(
            text: 'To follow or unfollow someone on Wesh:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Visit their profile.\n\n',
          ),
          TextSpan(
            text: '\t\t■ Click on the “Follow” or “Unfollow” button located above the Profile Stats Buttons section',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Who Can I Follow?',
        contentList: [
          TextSpan(
            text:
                'You can follow anyone on Wesh—there are no limits or restrictions\n\nSimilarly, anyone can follow you to stay updated on your public activities and updates',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'How and Where to Manage My Subscriptions?',
        contentList: [
          TextSpan(
            text: 'To manage or view all your subscriptions:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Go to your Profile Page by clicking on the Profile Icon',
          ),
          WidgetSpan(
            child: Icon(Icons.person, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: '\n\n',
          ),
          TextSpan(
            text: '\t\t■ Click on either the Followers or Followings buttons below your Profile Information\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ You\'ll be redirected to the People Page, where you can see all your followers under the "Followers" tab and all the people and accounts you follow under the "Followings" tab\n\n',
          ),
          TextSpan(
            text:
                'You can also remove followers if you don\'t want them following you, and you can unfollow accounts you currently follow\n\n\n',
          ),
          TextSpan(
            text: 'Note:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'You can follow more people by clicking on the "plus user" icon ',
          ),
          WidgetSpan(
            child: Icon(Icons.person_add, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text:
                ' (top right corner of People Page) and then searching for accounts you might be interested in following.\n\n\n',
          ),
          TextSpan(
            text: 'Tip:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                'If you want more people to follow you, consider inviting people from outside Wesh or creating useful and targeted events to attract new followers',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Should I Follow Someone to Chat with Them?',
        contentList: [
          TextSpan(
            text:
                'No! There\'s no correlation between subscriptions and chatting\n\nYou can chat with anyone you like, regardless of whether you follow each other',
          ),
        ],
      ),
      HelpItemContent(
        subHeader: 'Troubleshooting',
        contentList: [
          const TextSpan(
            text: 'Can’t Follow an Account:\n\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: '\t\t■ First, check your network connection\n\n',
          ),
          const TextSpan(
            text:
                '\t\t■ Then, click on the “follow” button next to the account card or Profile Page you’d like to follow\n\n',
          ),
          const TextSpan(
            text: '\nFollow/Unfollow Button is Just Spinning:\n\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: '\t\t■ This could be a network issue\n\n',
          ),
          const TextSpan(
            text: '\t\t■ First, check your network connection\n\n',
          ),
          const TextSpan(
            text: '\t\t■ Then, restart the app\n\n',
          ),
          const TextSpan(
            text: '\nNot Notified on People’s Activities I Follow:\n\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\t\t■ Ensure you are actually following them—on their Profile Page, the “Follow” button should show “Unfollow”.\n\n',
          ),
          const TextSpan(
            text:
                '\t\t■ Also, check your notification settings to ensure notifications are enabled (Profile page > Settings > Notifications > enable all notifications or select the ones you want to receive)\n\n',
          ),
          const TextSpan(
            text: '\nCan’t See My Followings’ Events in My Timeline:\n\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: '\t\t■ Usually, someone\'s events are automatically added to your timeline once you follow them\n\n',
          ),
          const TextSpan(
            text: '\t\t■ If not, make sure you are following them on their Profile Page\n\n',
          ),
          const TextSpan(
            text:
                '\t\t■ Also, refresh and sync your timeline by clicking on the Wesh logo on your Home Page (top left corner)\n\n',
          ),
          const TextSpan(
            text: '\nCan’t See My Followings’ Stories in My Stories Page:\n\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: '\t\t■ This may be due to a network issue\n\n',
          ),
          const TextSpan(
            text: '\t\t■ First, ensure you are following them on their Profile Page\n\n',
          ),
          const TextSpan(
            text:
                '\t\t■ Next, make sure your followings have shared at least one story or their stories haven\'t expired yet\n\n',
          ),
          const TextSpan(
            text: '\t\t■ Finally, on the Stories Page, refresh all stories by pulling down the stories list\n\n',
          ),
          ...troubleshootingNext,
        ],
      ),
    ],
  ),
  HelpItem(
    title: 'Security',
    icon: Icon(Icons.security_rounded, color: Colors.white, size: 23.sp),
    content: [
      const HelpItemContent(
        subHeader: 'About Account Security',
        contentList: [
          TextSpan(
            text:
                'Wesh prioritizes account security with each new version, continuously enhancing measures to safeguard user data and privacy 🛡️\n\n',
          ),
          TextSpan(
            text:
                'Certain sensitive information you provide is not visible to Wesh employees, developers, contributors, or third parties.\n\n',
          ),
          TextSpan(
            text:
                'Whenever we share your public data with third parties, you\'ll be notified, including details on how and why the data will be used, and the identity of the third party.\n\n',
          ),
          TextSpan(
            text:
                'For testing and development, Wesh uses fake and dummy data that mimics real-world user interactions. Your actual data is never used for these purposes.\n\n',
          ),
          TextSpan(
            text:
                'Wesh\'s Terms and Conditions are regularly updated to outline how we use and share your data—to whom, for what purposes, and why. By creating an account, you agree to these conditions, so it\'s essential to review them carefully before signing up',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'How to Protect My Account?',
        contentList: [
          TextSpan(
            text:
                'When registering a new account with your email address, you\'ll be prompted to create a strong password. We recommend keeping your password private to prevent unauthorized access.\n\n',
          ),
          TextSpan(
            text: 'I Forgot My Password:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: '\t\t■ If you\'ve forgotten your password:\n',
          ),
          TextSpan(
            text: '\t\t■ Go to your Security Settings Page:\n',
          ),
          TextSpan(
            text: '\t\t■ Navigate to Profile Page > Security > under Account Accesses section\n',
          ),
          TextSpan(
            text: '\t\t■ Click on "Email & Password"\n',
          ),
          TextSpan(
            text: '\t\t■ Select "Change current password"\n',
          ),
          TextSpan(
            text: '\t\t■ Follow the prompts to reset your password and set a new one\n\n',
          ),
          TextSpan(
            text: 'Alternatively, if you\'re logged out:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: '\t\t■ Visit the login page\n',
          ),
          TextSpan(
            text: '\t\t■ Click on "Forgot password" below the password field\n',
          ),
          TextSpan(
            text: '\t\t■ Enter your email address and follow the instructions to reset your password',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'How to Access My Account?',
        contentList: [
          TextSpan(
            text:
                'Wesh offers multi-authentication options, allowing you to log into your account through various methods such as Google, Facebook, Email and Password 🔄\n\n',
          ),
          TextSpan(
            text:
                'Manage these options in your Security Settings Page (Profile > Security > under Account Accesses section), where you can add or remove authentication methods\n\n\n',
          ),
          TextSpan(
            text: 'Note:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'You must keep at least one authentication method enabled at all times',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Data Privacy',
        contentList: [
          TextSpan(
            text: 'Data privacy concerns how we handle, use, store, and share the information you provide to us\n\n',
          ),
          TextSpan(
            text:
                'Whenever we share your information outside the Wesh ecosystem or with third parties, you\'ll receive notifications detailing exactly what data will be shared, to whom, and for what purposes\n\n',
          ),
          TextSpan(
            text:
                'Sensitive information is never shared. Even Wesh employees, developers, contributors, or third parties cannot access it—it remains strictly restricted to you\n\n',
          ),
          TextSpan(
            text:
                'One of our primary reasons for collecting information about you and your profile is to create a more personalized and enriching experience. This includes showing you relevant content, recommendations, and suggestions\n\n',
          ),
          TextSpan(
            text:
                'For more details, you can review our Data Privacy policy in our Terms and Conditions available on the Wesh website',
          ),
        ],
      ),
      HelpItemContent(
        subHeader: 'Troubleshooting',
        contentList: [
          const TextSpan(
            text: 'Can’t See or Forgot Connected Accounts (Google, Facebook, Email):\n\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\t\t■ All accounts connected to your Wesh account are visible in the Security Settings Page (Profile Page > Security > under Account Accesses section). You can manage these connections—attach or detach accounts—as needed on that page.\n\n',
          ),
          const TextSpan(
            text: '\nUnable to Attach an Email, Google, or Facebook Account:\n\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: '\t\t■ First, check your network connection\n\n',
          ),
          const TextSpan(
            text:
                '\t\t■ If the issue persists, it may indicate that the email, Google, or Facebook account you\'re trying to attach is already in use. Ensure it belongs to you and is not already linked to another account\n\n',
          ),
          ...troubleshootingNext,
        ],
      ),
    ],
  ),
  HelpItem(
    title: 'Payments',
    icon: Icon(FontAwesomeIcons.moneyBill1Wave, color: Colors.white, size: 20.sp),
    content: [
      const HelpItemContent(
        subHeader: 'Payment within Wesh',
        contentList: [
          TextSpan(
            text:
                'Payments have been introduced to facilitate connections among users for events like birthdays, parties, seminars, etc 🎉\n\n',
          ),
          TextSpan(
            text:
                'Sending money on Wesh can signify birthday wishes, paying participation or entrance fees to events, or simply sending money to someone you care about 💸\n\n\n',
          ),
          TextSpan(
            text: 'Note:\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                'Generally, Wesh does not handle money transfers or hold funds (except in rare cases); it uses third-party services depending on the countries involved and legal considerations',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Who Can I Send Money To?',
        contentList: [
          TextSpan(
            text: 'You can send money to any Wesh account, subject to our country-specific policies and guidelines\n\n',
          ),
          TextSpan(
            text: 'Please refer to the Wesh Guidelines for updated information, available on our website',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'How to Send Money Using Wesh',
        contentList: [
          TextSpan(
            text: 'To send money:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Open the chat with the recipient\n\n',
          ),
          TextSpan(
            text: '\t\t■ Tap the paperclip icon at the bottom of the chat page ',
          ),
          WidgetSpan(
            child: Icon(Icons.attach_file, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: '\n\n\t\t■ Select the money icon "',
          ),
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Icon(FontAwesomeIcons.dollarSign, size: 13, color: Colors.black87),
            ),
          ),
          TextSpan(
            text: '"\n\n',
          ),
          TextSpan(
            text: '\t\t■ Follow the prompts to choose a transfer method and provide necessary details\n\n',
          ),
          TextSpan(
            text: '\t\t■ Click "Send" to initiate the transfer\n\n',
          ),
          TextSpan(
            text: '\t\t■ Track its progress',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Receiving Money in Unsupported Countries',
        contentList: [
          TextSpan(
            text:
                'Receiving money is feasible even in countries not yet supported by Wesh\n\nWe guide you through the process and assist with any issues that may arise 🌍',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Is There a Money Transfer Limit?',
        contentList: [
          TextSpan(
            text:
                'Wesh does not impose a transfer limit itself; limits depend on the third-party services used\n\nYou\'ll be notified if you exceed any transfer limits',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Managing Sent or Received Money',
        contentList: [
          TextSpan(
            text:
                'All money transfers via Wesh are tracked and recorded from initiation to completion\n\nHere where to manage your transactions:\n\n',
          ),
          TextSpan(
            text: '\t\t■ In your chat history, where transfers appear as messages with details\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ On your Payments Page (Profile Page > Security > Payments), where you can track, monitor, and request assistance for any transfer\n',
          ),
        ],
      ),
      HelpItemContent(
        subHeader: 'Troubleshooting',
        contentList: [
          const TextSpan(
            text: 'Can’t Find or Track Past Transfers:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\n\n\t\t■ Money transfers appear as messages in your chat history 💬. Even if a chat is deleted, transfers are still visible on your Payments Page (Profile Page > Security > Payments > Send tab)\n\n\n',
          ),
          const TextSpan(
            text: 'Payment Options Unavailable in My Country:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\n\n\t\t■ Currently, Wesh does not support all countries 🌍 but is working towards expanding coverage. Check the "Payment availability countries" section on the Wesh website for updates\n\n\n',
          ),
          const TextSpan(
            text: 'Unable to Send Money Despite Country Support:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\n\n\t\t■ This may occur if your account is restricted or blocked due to violations of Wesh\'s money transfer guidelines 🚫. You can appeal for a review to potentially resolve the issue\n\n',
          ),
          ...troubleshootingNext,
        ],
      ),
    ],
  ),
  HelpItem(
    title: 'Profile',
    icon: Icon(Icons.account_circle_rounded, color: Colors.white, size: 26.sp),
    content: [
      const HelpItemContent(
        subHeader: 'What’s on My Profile Page',
        contentList: [
          TextSpan(
            text: 'Your Profile Page is where you and others can view all your public information and activities\n\n',
          ),
          TextSpan(
            text: 'It showcases your events, reminders (visible only to you), stories, and Forevers 📅\n\n',
          ),
          TextSpan(
            text: 'Public Information Displayed:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                '\n\n\t\t■ Profile picture (if set)\n\t\t■ Real name\n\t\t■ Username\n\t\t■ Birthday\n\t\t■ Bio (if set)\n\t\t■ Website link (if set)\n\n',
          ),
          TextSpan(
            text:
                'Visitors to your profile can choose to Follow or Unfollow you to stay updated on your activities\n\n',
          ),
          TextSpan(
            text: 'Additional Information Available:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                '\n\n\t\t■ Subscriptions: Lists of your followers and people you follow, visible to anyone including yourself\n\n\n',
          ),
          TextSpan(
            text: 'Note:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                '\nFrom your profile, you can access your settings to edit profile information, update preferences, seek help, or learn more about the app',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Updating or Editing Profile Information',
        contentList: [
          TextSpan(
            text: 'Most of your public information can be updated or edited, except for your birthday 🗓️\n\n',
          ),
          TextSpan(
            text: 'To Update Your Profile:\n\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: '\t\t■ Go to your Profile Page (click on the ',
          ),
          WidgetSpan(
            child: Icon(Icons.person, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' icon)\n\n',
          ),
          TextSpan(
            text: '\t\t■ Click on the Settings button located below your Profile Information ',
          ),
          WidgetSpan(
            child: Icon(Icons.settings, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: '\n\n',
          ),
          TextSpan(
            text: '\t\t■ Navigate to “My Account” in the Settings Page\n\n',
          ),
          TextSpan(
            text: '\t\t■ You’ll be directed to the “Edit Profile” page where you can modify:\n\n',
          ),
          TextSpan(
            text:
                '${'       '}\t\t◆ Your profile picture: remove, reset to default, or select a new image from your Gallery or Camera 🖼️\n\n',
          ),
          TextSpan(
            text:
                '${'       '}\t\t◆ Your username: must be at least 4 characters, lowercase alphanumeric (a-z, 0-9), and underscores 🔤\n\n',
          ),
          TextSpan(
            text:
                '${'       '}\t\t◆ Your name: your real name, up to 45 characters, with no character restrictions ✍️\n\n',
          ),
          TextSpan(
            text:
                '${'       '}\t\t◆ Your bio (optional): a brief description about yourself, your interests, hobbies, or motto 📖\n\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ Your website link (optional): a valid external link you want to showcase 🌐\n\n',
          ),
          TextSpan(
            text: '\t\t■ Click “Save” in the top right corner to confirm your changes\n\n',
          ),
          TextSpan(
            text: 'Your Profile will be updated accordingly',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Where to Manage My Subscriptions?',
        contentList: [
          TextSpan(
            text: 'To manage or view all your subscriptions:\n\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: '\t\t■ Go to your Profile Page (click on the ',
          ),
          WidgetSpan(
            child: Icon(Icons.person, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' icon)\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ Click on either the “Followers” or “Followings” buttons located below your Profile Information\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ You’ll be redirected to the People Page, displaying all your followers under the “Followers” tab and all accounts you follow under the “Followings” tab',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Updating My Account Preferences',
        contentList: [
          TextSpan(
            text:
                'Your account preferences, including notification settings, security, and more, can be updated easily:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Visit your Profile Page (click on the ',
          ),
          WidgetSpan(
            child: Icon(Icons.person, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' icon)\n\n',
          ),
          TextSpan(
            text: '\t\t■ Click on the “Settings” button below your Profile Information ',
          ),
          WidgetSpan(
            child: Icon(Icons.settings, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: '\n\n',
          ),
          TextSpan(
            text: '\t\t■ Navigate to the corresponding Settings Page you want to update:\n\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ Notifications: Configure how you receive notifications 🔔\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ Security: Manage authentication methods and other security settings 🔒',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Help and Assistance',
        contentList: [
          TextSpan(
            text: 'Wesh continuously improves its Help feature to provide quick and effective assistance:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Go to your Profile Page (click on the ',
          ),
          WidgetSpan(
            child: Icon(Icons.person, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' icon)\n\n',
          ),
          TextSpan(
            text: '\t\t■ Click on the “Settings” button below your Profile Information ',
          ),
          WidgetSpan(
            child: Icon(Icons.settings, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: '\n\n',
          ),
          TextSpan(
            text: '\t\t■ Select the Help option\n\n',
          ),
          TextSpan(
            text: '\t\t■ You’ll be redirected to the Help Page where you can access:\n\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ Help Center: to find answers about Wesh\n\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ Report an issue\n\n',
          ),
          TextSpan(
            text: '${'       '}\t\t◆ Our Privacy Policy\n\n',
          ),
          TextSpan(
            text:
                '${'       '}\t\t◆ Ask us a question: you’ll receive a reply in your Wesh inbox from our official account regarding your question',
          ),
        ],
      ),
      const HelpItemContent(
        subHeader: 'Miscellaneous: Invite Someone, Rate, About Wesh, Log Out',
        contentList: [
          TextSpan(
            text: 'This section covers various actions you can take from your Profile Page:\n\n',
          ),
          TextSpan(
            text: 'Invite Someone:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                ' Inviting others is a great way to increase your followers or introduce Wesh to new users. Here\'s how:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Go to your Profile Page (click on the ',
          ),
          WidgetSpan(
            child: Icon(Icons.person, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' icon)\n\n',
          ),
          TextSpan(
            text: '\t\t■ Click on the Settings button below your Profile Information ',
          ),
          WidgetSpan(
            child: Icon(Icons.settings, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: '\n\n',
          ),
          TextSpan(
            text: '\t\t■ Select "Invite a friend"\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ You\'ll be guided to invite someone via Facebook, WhatsApp, Instagram, Telegram, SMS, Email, or other methods\n\n\n',
          ),
          TextSpan(
            text: 'Rate Wesh:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                ' Wesh continues to evolve with your valuable feedback. Your input directly contributes to enhancing and improving Wesh\n\nHere\'s how you can share your thoughts and feedback about the app:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Go to your Profile Page (click on the ',
          ),
          WidgetSpan(
            child: Icon(Icons.person, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' icon)\n\n',
          ),
          TextSpan(
            text: '\t\t■ Click on the “Settings” button below your Profile Information ',
          ),
          WidgetSpan(
            child: Icon(Icons.settings, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: '\n\n',
          ),
          TextSpan(
            text: '\t\t■ Choose "Rate Wesh"\n\n',
          ),
          TextSpan(
            text: '\t\t■ Select your satisfaction level\n\n',
          ),
          TextSpan(
            text:
                '\t\t■ Optionally, suggest features or improvements: we read carefully and take into account your suggestions 💡\n\n\n',
          ),
          TextSpan(
            text: 'About the App:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: ' Learn more details about Wesh, including its current version and licenses:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Go to your Profile Page (click on the ',
          ),
          WidgetSpan(
            child: Icon(Icons.person, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' icon)\n\n',
          ),
          TextSpan(
            text: '\t\t■ Click on the “Settings” button below your Profile Information ',
          ),
          WidgetSpan(
            child: Icon(Icons.settings, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: '\n\n',
          ),
          TextSpan(
            text: '\t\t■ Select "About the App"\n\n',
          ),
          TextSpan(
            text: '\t\t■ You\'ll find all information about the version of Wesh you’re using\n\n\n',
          ),
          TextSpan(
            text: 'Log Out:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: ' If you need to log out from your current account:\n\n',
          ),
          TextSpan(
            text: '\t\t■ Go to your Profile Page (click on the ',
          ),
          WidgetSpan(
            child: Icon(Icons.person, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: ' icon)\n\n',
          ),
          TextSpan(
            text: '\t\t■ Click on the “Settings” button below your Profile Information ',
          ),
          WidgetSpan(
            child: Icon(Icons.settings, size: 16, color: Colors.black87),
          ),
          TextSpan(
            text: '\n\n',
          ),
          TextSpan(
            text: '\t\t■ Tap on "Log out" located in the top right corner of the Settings Page\n\n',
          ),
          TextSpan(
            text: '\t\t■ Confirm by clicking "Logout"\n\n',
          ),
          TextSpan(
            text: 'You will be logged out of your current account',
          ),
        ],
      ),
      HelpItemContent(
        subHeader: 'Troubleshooting',
        contentList: [
          const TextSpan(
            text: 'Can’t Load My Profile Information:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\n\n\t\t■ First, check your network connection. Try navigating to another page and then return to your Profile\n\n',
          ),
          const TextSpan(
            text: '\nMy Profile Updates Don’t Take Effect:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\n\n\t\t■ Normally, changes to your profile are reflected automatically. If not, try restarting the app 🔄\n\n',
          ),
          const TextSpan(
            text: '\t\t■ If the issue persists, log out and then log back into your account 👤\n\n',
          ),
          const TextSpan(
            text: '\nEvents, Reminders, or Forevers Aren’t Loading:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: '\n\n\t\t■ Verify your network connection 📶\n\n',
          ),
          const TextSpan(
            text:
                '\t\t■ Try switching to another tab and then return to the content tab you want (Events, Reminders, or Forevers 🔄)\n\n',
          ),
          const TextSpan(
            text: '\nCan’t See My Stories on My Profile Page:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\n\n\t\t■ Access your Stories on the Profile Page by clicking on the red circle next to your profile picture 🔴\n\n',
          ),
          const TextSpan(
            text:
                '\t\t■ If the red circle isn’t visible, it means your stories have expired or you haven’t published any yet 📅\n\n',
          ),
          const TextSpan(
            text: '\nThe Help Information is Incorrect or Unclear:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text:
                '\n\n\t\t■ If you find any mistakes, please inform us, and we’ll promptly make the necessary corrections ✍️\n\n',
          ),
          ...troubleshootingNext,
        ],
      ),
    ],
  ),
  HelpItem(
    title: 'Troubleshooting',
    icon: Icon(Icons.question_mark_outlined, color: Colors.white, size: 24.sp),
    content: const [
      HelpItemContent(
        subHeader: 'How to Solve Issues?',
        contentList: [
          TextSpan(
            text: '\t\t■ Search Your Issue: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'Utilize the search functionality in the Help Center to find solutions to your problem',
          ),
        ],
      ),
      HelpItemContent(
        subHeader: 'Follow These Steps if You Haven’t Found Answers',
        contentList: [
          TextSpan(
            text: '\t\t■ Check your network connection: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'Ensure you have a good signal or change location to improve it 📶\n\n',
          ),
          TextSpan(
            text: '\t\t■ Update Wesh: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'Make sure you have the latest version of the app by checking Settings > About the App 🔄\n\n',
          ),
          TextSpan(
            text: '\t\t■  Free up space or clear cache: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'Clear Wesh\'s cache and restart the app 🧹\n\n',
          ),
          TextSpan(
            text: '\t\t■ Restart your device: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'Turn off and on your device, then relaunch the Wesh app 🔄',
          ),
        ],
      ),
      HelpItemContent(
        subHeader: 'I Can\'t Solve My Problem, I Tried Everything',
        contentList: [
          TextSpan(
            text: 'If you’re still stuck and can’t get your issue fixed, please contact us:\n',
          ),
          TextSpan(
            text: '\t\t■ Tap the ',
          ),
          WidgetSpan(child: Icon(Icons.support_agent_rounded, size: 16, color: Colors.black87)),
          TextSpan(
            text:
                ' “Ask us a question” button in the top right corner of this Help Center page or on the Settings Page > Help Page\n\n',
          ),
          TextSpan(
            text: 'We’ll reply to your chats using our official account',
          ),
        ],
      ),
    ],
  ),
];

List<InlineSpan> troubleshootingNext = [
  const TextSpan(
    text: '\n\nIf you encounter an issue not mentioned above, follow these steps:\n\n',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  const TextSpan(
      text: '\t\t■ Check your network connection:',
      style: TextStyle(fontWeight: FontWeight.bold),
      children: [
        TextSpan(
          text: 'ensure you have a good signal or change location to improve it\n\n',
          style: TextStyle(fontWeight: FontWeight.normal),
        )
      ]),
  const TextSpan(text: '\t\t■ Update Wesh: ', style: TextStyle(fontWeight: FontWeight.bold), children: [
    TextSpan(
      text: 'make sure you have the latest version of the app by checking Settings > About the App\n\n',
      style: TextStyle(fontWeight: FontWeight.normal),
    )
  ]),
  const TextSpan(
      text: '\t\t■ Free up space or clear cache: ',
      style: TextStyle(fontWeight: FontWeight.bold),
      children: [
        TextSpan(text: 'clear Wesh\'s cache and restart the app\n\n', style: TextStyle(fontWeight: FontWeight.normal))
      ]),
  const TextSpan(text: '\t\t■ Restart your device: ', style: TextStyle(fontWeight: FontWeight.bold), children: [
    TextSpan(
      text: 'turn off and on your device, then relaunch the Wesh app\n\n',
      style: TextStyle(fontWeight: FontWeight.normal),
    )
  ]),
  const TextSpan(text: '\t\t■ Still having issues?: ', style: TextStyle(fontWeight: FontWeight.bold), children: [
    TextSpan(
      text: 'contact us via the ',
      style: TextStyle(fontWeight: FontWeight.normal),
    ),
    WidgetSpan(child: Icon(Icons.support_agent_rounded, size: 16, color: Colors.black87)),
    TextSpan(
      text:
          ' “Ask us a question” button in the top right corner of this Help Center page or on the Settings Page > Help Page.\nWe’ll reply to your chats using our official account 💬',
      style: TextStyle(fontWeight: FontWeight.normal),
    )
  ]),
];
