// import 'package:firebase_app_check/firebase_app_check.dart';
import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:timeago/timeago.dart';
import 'package:wesh/pages/startPage.dart';
import 'package:wesh/providers/user.provider.dart';
import 'package:wesh/services/sharedpreferences.service.dart';
import 'package:wesh/widgets/buildWidgets.dart';
import 'pages/login.dart';
import 'utils/constants.dart';

// BACKGROUND DOWLOAD TASK HANDLER
class TestClass {
  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port_$id');
    send!.send([id, status, progress]);
  }
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await UserSimplePreferences.init();

  setLocaleMessages('fr', FrMessages());

  await FlutterDownloader.initialize(
      debug: true, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl: true // option: set to false to disable working with http links (default: false)
      );
  FlutterDownloader.registerCallback(TestClass.downloadCallback);

  // Build Error Widget
  ErrorWidget.builder = (details) {
    bool inDebug = false;
    assert(() {
      inDebug = true;
      return true;
    }());

    if (inDebug) {
      return Center(
        child: Text(
          'Une erreur s\'est produite !\n${details.exception}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: kSecondColor,
          ),
        ),
      );
    }

    return FittedBox(
      child: Container(
        margin: const EdgeInsets.all(40),
        height: 90,
        width: 200,
        child: const buildErrorWidget(
          onWhiteBackground: true,
        ),
      ),
    );
  };

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
    ],
    child: const App(),
  ));
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    //
    log('Ready to start...');
    FlutterNativeSplash.remove();
    //
    SystemChrome.setApplicationSwitcherDescription(
        const ApplicationSwitcherDescription(label: 'Wesh', primaryColor: 1));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return ScreenUtilInit(
        designSize: const Size(320, 568),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            supportedLocales: const [
              Locale('fr'),
            ],
            localizationsDelegates: const [
              CountryLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            theme: ThemeData.light().copyWith(
              primaryColor: const Color(0xFF242526),
              appBarTheme: AppBarTheme(
                iconTheme: IconThemeData(
                  size: 22.sp,
                  color: Colors.black87,
                ),
                toolbarHeight: 0.08.sh,
                titleTextStyle: TextStyle(
                  fontSize: 17.sp,
                  color: Colors.black,
                ),
              ),
              progressIndicatorTheme: ProgressIndicatorThemeData(linearMinHeight: 0.005.sh),
              checkboxTheme: CheckboxThemeData(
                fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                  const Set<MaterialState> interactiveStates = <MaterialState>{
                    MaterialState.pressed,
                    MaterialState.hovered,
                    MaterialState.focused,
                  };
                  if (states.any(interactiveStates.contains)) {
                    return kPrimaryColor;
                  }
                  return kSecondColor;
                }),
              ),
              radioTheme: RadioThemeData(
                fillColor: MaterialStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(MaterialState.selected)) {
                      return kSecondColor;
                    }

                    return Colors.white;
                  },
                ),
              ),
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
                    return Scaffold(
                      backgroundColor: Colors.white,
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            CircularProgressIndicator(
                              color: kSecondColor,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Chargement...',
                              style: TextStyle(color: Colors.black45),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    return StartPage(context: context);
                  } else if (snapshot.hasError) {
                    return Scaffold(
                      appBar: MorphingAppBar(
                        heroTag: 'mainPageAppBar',
                      ),
                      body: const Center(
                        child: Text("Une erreur s'est produite"),
                      ),
                    );
                  } else {
                    return const LoginPage(
                      redirectToAddEmailandPasswordPage: false,
                      redirectToAddEmailPage: false,
                      redirectToUpdatePasswordPage: false,
                    );
                  }
                },
              ),
            ),
          );
        });
  }
}
