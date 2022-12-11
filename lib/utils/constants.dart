import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:timeago/timeago.dart';
import 'package:wesh/services/notifications_api.dart';
import 'package:wesh/widgets/buildWidgets.dart';

import '../models/eventtype.dart';
import '../models/feedbacktype.dart';

// Links and ref
const String appName = 'Wesh';
const String appVersion = '0.1';
const String appEmail = 'app.wesh@gmail.com';
const String downloadAppUrl = 'https://wesh.grwebsite.com/';
const String privacyPolicyUrl = 'https://wesh.grwebsite.com/politique-de-confidentialite-en';

// ENV && App var
// fileLimitSize : 15MB
const int fileLimitSize = 15000000;

// Notifications Channels

List<NotificationChannel> notificationsChannelList = [
  NotificationChannel(
      channelId: '0',
      channelName: 'Messages',
      channelDescription: 'Recevez les notifications sur les messages qui vous sont destinés',
      channelImportance: Importance.max,
      channelPriority: Priority.defaultPriority),
  NotificationChannel(
      channelId: '1',
      channelName: 'Evenements',
      channelDescription: 'Recevez les notifications sur les évenements qui vous concernent',
      channelImportance: Importance.max,
      channelPriority: Priority.high),
  NotificationChannel(
      channelId: '2',
      channelName: 'Rappels',
      channelDescription: 'Recevez les notifications sur les rappels que vous mettez en place',
      channelImportance: Importance.max,
      channelPriority: Priority.max),
  NotificationChannel(
      channelId: '3',
      channelName: 'Stories',
      channelDescription: 'Recevez les notifications sur les nouvelles stories',
      channelImportance: Importance.max,
      channelPriority: Priority.defaultPriority),
];

// Colors
const kPrimaryColor = Color(0xFF68002C);
const kSecondColor = Color(0xFFE02F66);
final kSuccessColor = Colors.green.shade400;
const kGreyColor = Color(0xFFF0F0F0);

// Constants
// Constants : Payment Method
const mtnMobileMoneyLabel = 'Mobile Money';
const airtelMoneyLabel = 'Airtel Money';

// Assets
const String weshLogoBlack = 'assets/images/wesh_logo_black.svg';
const String weshLogoColored = 'assets/images/wesh_logo_colored.svg';
const String googleLogo = 'assets/images/google_logo.svg';
const String phoneLogo = 'assets/images/phone_logo.svg';
const String facebookLogo = 'assets/images/facebook_logo.svg';
const String weshLogoPic = 'assets/images/wesh_logo.png';
const String weshFaviconPic = 'assets/images/wesh_favicon.png';
const String darkBackground = 'assets/images/dark_background.png';
const String soundWaves = 'assets/images/sound_waves.png';
const String mtnMobileMoneyLogo = 'assets/images/mtn_mobile_money_logo.png';
const String airtelMoneyLogo = 'assets/images/airtel_money_logo.png';

const List<String> monthsList = [
  'Janvier',
  'Février',
  'Mars',
  'Avril',
  'Mai',
  'Juin',
  'Juillet',
  'Août',
  'Septembre',
  'Octobre',
  'Novembre',
  'Décembre'
];

// Time ago messages
class FrMessagesShortsform implements LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'à l\'instant';
  @override
  String aboutAMinute(int minutes) => '1min';
  @override
  String minutes(int minutes) => '${minutes}min';
  @override
  String aboutAnHour(int minutes) => '1h';
  @override
  String hours(int hours) => '${hours}h';
  @override
  String aDay(int hours) => '1j';
  @override
  String days(int days) => '${days}j';
  @override
  String aboutAMonth(int days) => '1m';
  @override
  String months(int months) => '${months}m';
  @override
  String aboutAYear(int year) => '1a';
  @override
  String years(int years) => '${years}a';
  @override
  String wordSeparator() => ' ';
}

// Reminders
final remindersList = [
  Text(
    'dès qu\'il commence',
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 16.sp, color: Colors.black),
  ),
  Text(
    '10min avant',
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 16.sp, color: Colors.black),
  ),
  Text(
    '1h avant',
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 16.sp, color: Colors.black),
  ),
  Text(
    '1 jour avant',
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 16.sp, color: Colors.black),
  ),
  Text(
    '3 jours avant',
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 16.sp, color: Colors.black),
  ),
  Text(
    '1 semaine avant',
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 16.sp, color: Colors.black),
  ),
  Text(
    '1 mois avant',
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 16.sp, color: Colors.black),
  ),
];

const recurrencesList = [
  Text(
    'Aucune récurrence',
    style: TextStyle(color: Colors.black),
  ),
  Text(
    'Chaque jour',
    style: TextStyle(color: Colors.black),
  ),
  Text(
    'Chaque semaine',
    style: TextStyle(color: Colors.black),
  ),
  Text(
    'Chaque mois',
    style: TextStyle(color: Colors.black),
  ),
  Text(
    'Chaque année',
    style: TextStyle(color: Colors.black),
  ),
];

// FeedBack Available Type
List<FeedBackType> feedbackAvailableTypeList = [
  FeedBackType(index: 1, emoji: '😞', title: 'Déçu'),
  FeedBackType(index: 2, emoji: '😒', title: 'Pas cool'),
  FeedBackType(index: 3, emoji: '🙄', title: 'Je sais pas'),
  FeedBackType(index: 4, emoji: '😊', title: 'J\'aime bien'),
  FeedBackType(index: 5, emoji: '🥰', title: 'Excellent'),
];

// Event Available Type
List<EventType> eventAvailableTypeList = [
  EventType(
    key: 'birthday',
    name: 'Anniversaire de naissance',
    recurrence: true,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'baptismbirthday',
    name: 'Anniversaire de baptème',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'weddingbirthday',
    name: 'Anniversaire de mariage',
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
    name: 'Cours',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'burial',
    name: 'Enterrement',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'exam',
    name: 'Examen',
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
    name: 'Défilé de mode',
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
    name: 'Fête',
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
    name: 'Jour religieux',
    recurrence: true,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'specialday',
    name: 'Jour spécial',
    recurrence: true,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'internationalday',
    name: 'Journée internationale',
    recurrence: true,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'nationalday',
    name: 'Journée nationale',
    recurrence: true,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'productlaunch',
    name: 'Lancement de Produit',
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
    name: 'Retrait de deuil',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'meeting',
    name: 'Reunion',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'tradeshow',
    name: 'Salon professionnel',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'seminar',
    name: 'Seminaire',
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
    name: 'Soirée de Gala',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'privateparty',
    name: 'Soirée privée',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'poll',
    name: 'Sondages',
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
    key: 'visioconference',
    name: 'Visioconférence',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'dot',
    name: 'Dot',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'predot',
    name: 'Pré-dot',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'wedding',
    name: 'Mariage',
    recurrence: false,
    iconPath: '',
    description: '',
  ),
  EventType(
    key: 'other',
    name: 'Autre',
    recurrence: true,
    iconPath: '',
    description: '',
  ),
];

// Event Available Colors
const eventAvailableColorsList = [
  Color.fromARGB(255, 239, 79, 133),
  Color.fromARGB(255, 15, 80, 134),
  Color.fromARGB(255, 19, 186, 64),
  Color.fromARGB(255, 147, 13, 220),
  Color.fromARGB(255, 2, 6, 9),
];

// Stories Text BackGround Available Colors
const storiesAvailableColorsList = [
  Color(0xFF1BBC9B),
  Color(0xFF50D78A),
  Color(0xFF2C96DC),
  Color(0xFF9C56B8),
  Color(0xFF34495E),
  Color(0xFF95A5A5),
  Color(0xFFF1C50E),
  Color(0xFFE77E21),
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
    title: "Bienvenue sur $appName",
    bodyWidget: const buildIntroductionPageContent(
      animationPath: 'assets/animations/97585-star.json',
      title: 'Créez vos évenements',
      description:
          'Alertez vos amis sur les dates qui comptent beaucoup pour vous comme votre date d\'anniversaire 🎉🎈',
    ),
  ),
  PageViewModel(
    title: "",
    bodyWidget: const buildIntroductionPageContent(
      animationPath: 'assets/animations/44822-selfie.json',
      title: 'Partagez les moments les plus forts dans votre Story',
      description: 'Montrez en direct à vos amis comment se déroule votre évenement 🔥',
    ),
  ),
  PageViewModel(
    title: "",
    bodyWidget: const buildIntroductionPageContent(
      animationPath: 'assets/animations/97611-smartphone-money-green.json',
      title: 'Discutez rapidement avec vos amis',
      description:
          'Recevez des cadeaux, des messages ou de l\'argent 💰 de la part de vos amis concernant votre évenement ',
    ),
  ),
];
