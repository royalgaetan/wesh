import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:timeago/timeago.dart';
import 'package:wesh/widgets/buildWidgets.dart';

import '../models/eventtype.dart';
import '../models/feedbacktype.dart';

// Links and ref
const String appName = 'Wesh';
const String appVersion = '0.1';
const String appEmail = 'app.wesh@gmail.com';
const String downloadAppUrl = 'https://wesh.grwebsite.com/';
const String privacyPolicyUrl =
    'https://wesh.grwebsite.com/politique-de-confidentialite-en';

// Colors
const kPrimaryColor = Color(0xFF68002C);
const kSecondColor = Color(0xFFE02F66);
final kSuccessColor = Colors.green.shade400;
const kGreyColor = Color(0xFFF0F0F0);

// Assets
const String weshLogoBlack = 'assets/images/wesh_logo_black.svg';
const String weshLogoColored = 'assets/images/wesh_logo_colored.svg';
const String googleLogo = 'assets/images/google_logo.svg';
const String phoneLogo = 'assets/images/phone_logo.svg';
const String facebookLogo = 'assets/images/facebook_logo.svg';
const String weshLogoPic = 'assets/images/wesh_logo.png';
const String weshFaviconPic = 'assets/images/wesh_favicon.png';

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
const remindersList = [
  Text(
    'dès qu\'il commence',
    style: TextStyle(color: Colors.black),
  ),
  Text(
    '1h avant',
    style: TextStyle(color: Colors.black),
  ),
  Text(
    '1 jour avant',
    style: TextStyle(color: Colors.black),
  ),
  Text(
    '1 semaine avant',
    style: TextStyle(color: Colors.black),
  ),
  Text(
    '1 mois avant',
    style: TextStyle(color: Colors.black),
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
  FeedBackType(emoji: '😞', title: 'Déçu'),
  FeedBackType(emoji: '😒', title: 'Pas cool'),
  FeedBackType(emoji: '🙄', title: 'Je sais pas'),
  FeedBackType(emoji: '😊', title: 'J\'aime bien'),
  FeedBackType(emoji: '🥰', title: 'Excellent'),
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
    recurrence: true,
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
    key: 'inauguration',
    name: 'Inauguration',
    recurrence: false,
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
    key: 'teambuilding',
    name: 'Team Building',
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
    recurrence: false,
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
      description:
          'Montrez en direct à vos amis comment se déroule votre évenement 🔥',
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
