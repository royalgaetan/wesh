import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:wesh/widgets/buildWidgets.dart';

const songurl =
    'https://storage.googleapis.com/synchedin-storage/public/tracks/GBSMU5167394/GBSMU5167394.mp3';

// Colors
const kPrimaryColor = Color(0xFF68002C);
const kSecondColor = Color(0xFFE02F66);
final kSuccessColor = Colors.green.shade400;
const kGreyColor = Color(0xFFF0F0F0);

// Assets
const String weehLogo = 'assets/images/weeh_logo.svg';
const String googleLogo = 'assets/images/google_logo.svg';
const String phoneLogo = 'assets/images/phone_logo.svg';
const String facebookLogo = 'assets/images/facebook_logo.svg';

// Reminders
const remindersList = [
  Text(
    'Aucun rappel',
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

// Event Available Colors
const eventAvailableColorsList = [
  Color.fromARGB(255, 239, 79, 133),
  Color.fromARGB(255, 15, 80, 134),
  Color.fromARGB(255, 19, 186, 64),
  Color.fromARGB(255, 147, 13, 220),
  Color.fromARGB(255, 2, 6, 9),
];

// Introduction Pages
List<PageViewModel> listPagesViewModel = [
  PageViewModel(
    title: "Bienvenue sur Wesh",
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
