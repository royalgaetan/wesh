// import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart';
import 'package:wesh/google_provider.dart';
import 'package:wesh/pages/startPage.dart';
import 'package:wesh/providers/user.provider.dart';
import 'package:wesh/services/sharedpreferences.service.dart';
import 'pages/login.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await UserSimplePreferences.init();

  setLocaleMessages('fr', FrMessages());

  // await FirebaseAppCheck.instance.activate(
  //   webRecaptchaSiteKey:
  //       'recaptcha-v3-site-key', // <-- only needed for reCAPTCHA v3
  // );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<GoogleProvider>(create: (_) => GoogleProvider()),
      ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
    ],
    child: App(),
  ));
}

class App extends StatefulWidget {
  App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: const [
        Locale('fr'),
      ],
      localizationsDelegates: const [
        CountryLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData.light().copyWith(
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color>(
            (states) {
              if (states.contains(MaterialState.selected)) {
                return kSecondColor;
              }

              return Colors.white;
            },
          ),
          trackColor: MaterialStateProperty.resolveWith<Color>(
            (states) {
              if (states.contains(MaterialState.selected)) {
                return kSecondColor.withOpacity(.2);
              }
              return Colors.black26;
            },
          ),
        ),
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: kSecondColor,
          onPrimary: Colors.white,
          secondary: Colors.grey.shade600,
          onSecondary: Colors.grey.shade300.withOpacity(0.7),
          error: kSecondColor,
          onError: kSecondColor.withOpacity(0.7),
          background: Colors.white,
          onBackground: Colors.white.withOpacity(0.7),
          surface: Colors.white,
          onSurface: Colors.black,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }
            if (snapshot.hasData) {
              return const StartPage();
            } else if (snapshot.hasError) {
              return Scaffold(
                appBar: AppBar(),
                body: const Center(
                  child: Text("Une erreur s'est produite"),
                ),
              );
            } else {
              return LoginPage(
                redirectToAddEmailandPasswordPage: false,
                redirectToAddEmailPage: false,
                redirectToUpdatePasswordPage: false,
              );
            }
          },
        ),
      ),
    );
  }
}
